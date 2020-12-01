import strutils
import sequtils
import options

import consts
import general
import esp/storage/esp_ota_ops

const TAG = "OTAUTL"

const
  BUFFSIZE* = 1024
  HASH_LEN* = 32

type
  OtaSha256* = ref object
    data: array[HASH_LEN, uint8]

  OtaUpdateHandle* = ref object
    handle*: esp_ota_handle_t
    update*: ptr esp_partition_t
    configured*: ptr esp_partition_t
    running*: ptr esp_partition_t
    total_written*: int

  OtaError* = object of OSError
    code*: esp_err_t

  OtaUpdateStatus* = enum
    VersionNewer,
    VersionUnchecked,
    VersionMatchesPreviousInvalid
    VersionSameAsCurrent


proc versionStr*(info: esp_app_desc_t): string =
  return info.version.join()
proc projectNameStr*(info: esp_app_desc_t): string =
  return info.project_name.join()
proc timeStr*(info: esp_app_desc_t): string =
  return info.time.join()
proc dateStr*(info: esp_app_desc_t): string =
  return info.date.join()
proc idfVerStr*(info: esp_app_desc_t): string =
  return info.idf_ver.join()

proc currentFirmwareInfo*(): esp_app_desc_t =
  let running: ptr esp_partition_t = esp_ota_get_running_partition()
  var info: esp_app_desc_t
  let err = running.esp_ota_get_partition_description(addr info)
  if err != ESP_OK:
    raise newEspError[OtaError]("failed to read current firmware info " & $esp_err_to_name(err), err)
  return info

proc lastInvalidFirmwareInfo*(): Option[esp_app_desc_t] =
  var last_invalid_app: ptr esp_partition_t = esp_ota_get_last_invalid_partition()

  var info: esp_app_desc_t
  let err = last_invalid_app.esp_ota_get_partition_description(addr info)
  if err != ESP_OK:
    return none[esp_app_desc_t]()
  else:
    return some(info)


proc newOtaUpdateHandle*(startFrom: ptr esp_partition_t = nil): OtaUpdateHandle =
  result = new(OtaUpdateHandle)

  result.handle = esp_ota_handle_t(0)
  result.update = esp_ota_get_next_update_partition(startFrom)
  result.configured = esp_ota_get_boot_partition()
  result.running = esp_ota_get_running_partition()
  result.total_written = 0

proc get_sha256*(partition: ptr esp_partition_t): OtaSha256 =
  result = new(OtaSha256)
  let err = esp_partition_get_sha256(partition, addr result.data[0])
  if err != ESP_OK:
    raise newEspError[OtaError]("parition sha256 failed: " & $esp_err_to_name(err), err)

proc get_sha256*(partition: var esp_partition_t): OtaSha256 =
  get_sha256(addr partition)

proc `$`*(ota_sha256: OtaSha256): string =
  ota_sha256.data.mapIt(it.toHex(2)).join()

proc logPartionInfo*(ota: OtaUpdateHandle) =
  if ota.configured != ota.running:
    TAG.logw("Configured OTA boot partition at offset 0x%08x, but running from offset 0x%08x",
             ota.configured.address, ota.running.address)
    TAG.logw("(This can happen if either the OTA boot data or preferred boot image become corrupted somehow.)")
    
  TAG.logi("Running partition type %d subtype %d (offset 0x%08x)",
           ota.running.`type`, ota.running.subtype, ota.running.address)

  TAG.logi("Writing to partition subtype %d at offset 0x%x",
           ota.update.subtype, ota.update.address)

proc begin*(ota: OtaUpdateHandle) =
  let err = esp_ota_begin(ota.update, OTA_SIZE_UNKNOWN, addr(ota.handle))
  if err != ESP_OK:
    TAG.loge("esp_ota_begin failed (%s)", repr(ota.update))
    raise newEspError[OtaError]("Error ota begin: " & $esp_err_to_name(err), err)

proc checkImageHeader*(ota: OtaUpdateHandle, data: var string; version_check = true):
      tuple[status: OtaUpdateStatus, info: esp_app_desc_t] =

    var new_app_info: esp_app_desc_t
    let
      sz_image_hdr = sizeof(esp_image_header_t) 
      sz_image_seg_hdr = sizeof(esp_image_segment_header_t) 
      sz_app_desc = sizeof(esp_app_desc_t)

    let header_sz = sz_image_hdr + sz_image_seg_hdr + sz_app_desc

    if data.len() < header_sz:
      raise newException(ValueError, "insufficient update image size: " & $data.len() & "/" & $header_sz)

    ##  check current version with downloading
    copyMem(addr new_app_info,
            addr data[sz_image_hdr + sz_image_seg_hdr],
            sizeof(esp_app_desc_t))

    TAG.logw("Writing New firmware version: %s", new_app_info.versionStr())
    if not version_check:
      return (status: VersionUnchecked, info: new_app_info)

    var currApp: esp_app_desc_t = currentFirmwareInfo()
    TAG.logi("Running firmware version: %s on date: %s at %s", currApp.versionStr(), currApp.dateStr(), currApp.timeStr())

    var lastInvApp: Option[esp_app_desc_t] = lastInvalidFirmwareInfo()
    if lastInvApp.isSome():
      TAG.logi("Last invalid firmware version: %s", lastInvApp.get().versionStr())

    if lastInvApp.isSome() and lastInvApp.get().version == currApp.version:
      TAG.logw("New version is the same as invalid version.")
      TAG.logw("Previously, there was an attempt to launch the firmware with %s version, but it failed.",
                lastInvApp.get().versionStr())
      TAG.logw("The firmware has been rolled back to the previous version.")
      return (status: VersionMatchesPreviousInvalid, info: new_app_info)

    if new_app_info.version == currApp.version:
      return (status: VersionSameAsCurrent, info: new_app_info)

    return (status: VersionNewer, info: new_app_info)

proc write*(ota: var OtaUpdateHandle, write_data: var string) =
  let err = esp_ota_write(ota.handle, addr write_data[0], write_data.len().csize_t)
  if err != ESP_OK:
    raise newEspError[OtaError]("Error ota write: " & $esp_err_to_name(err), err)
  ota.total_written.inc(write_data.len())

proc finish*(ota: var OtaUpdateHandle) =
  if ota.handle.uint32 != 0:
    let err = esp_ota_end(ota.handle)
    if err.uint32 == ESP_ERR_OTA_VALIDATE_FAILED:
      raise newEspError[OtaError]("Image validation failed, image is corrupted", err)
    if err != ESP_OK:
      raise newEspError[OtaError]("Error ota end: " & $esp_err_to_name(err), err)

proc set_as_boot_partition*(ota: var OtaUpdateHandle) =
  let err = esp_ota_set_boot_partition(ota.update)
  if err != ESP_OK:
    raise newEspError[OtaError]("esp_ota_set_boot_partition failed (%s)!" & $esp_err_to_name(err), err)

proc firmware_verify*(diagnostic_callback: proc (): bool) =
  var sha_256: OtaSha256

  ##  get sha256 digest for the partition table
  var partition: esp_partition_t
  partition.address = ESP_PARTITION_TABLE_OFFSET
  partition.size = ESP_PARTITION_TABLE_MAX_LEN
  partition.`type` = ESP_PARTITION_TYPE_DATA

  sha_256 = partition.get_sha256()
  TAG.logi("SHA-256 for the partition table: %s", $sha_256)

  ##  get sha256 digest for bootloader
  partition.address = ESP_BOOTLOADER_OFFSET
  partition.size = ESP_PARTITION_TABLE_OFFSET
  partition.`type` = ESP_PARTITION_TYPE_APP

  sha_256 = partition.get_sha256()
  TAG.logi("SHA-256 for bootloader: %s", $sha_256)

  ##  get sha257 digest for running partition
  sha_256 = esp_ota_get_running_partition().get_sha256()
  TAG.logi("SHA-256 for current firmware: %s", $sha_256)


  var running: ptr esp_partition_t = esp_ota_get_running_partition()
  var ota_state: esp_ota_img_states_t
  if esp_ota_get_state_partition(running, addr(ota_state)) == ESP_OK:
    if ota_state == ESP_OTA_IMG_PENDING_VERIFY:
      ##  run diagnostic function ...
      var diagnostic_is_ok: bool = diagnostic_callback()
      if diagnostic_is_ok:
        TAG.logi("Diagnostics completed successfully! Continuing execution ...")
        check: esp_ota_mark_app_valid_cancel_rollback()
      else:
        TAG.loge("Diagnostics failed! Start rollback to the previous version ...")
        check: esp_ota_mark_app_invalid_rollback_and_reboot()

