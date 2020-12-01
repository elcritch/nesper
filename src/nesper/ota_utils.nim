
import consts
import general
import esp/storage/esp_ota_ops

const TAG = "OTAUTL"

const
  BUFFSIZE* = 1024
  HASH_LEN* = 32

type
  OtaUpdateHandle* = ref object
    handle*: esp_ota_handle_t
    update*: ptr esp_partition_t
    configured*: ptr esp_partition_t
    running*: ptr esp_partition_t

  OtaError* = object of OSError
    code*: esp_err_t

  OtaUpdateStatus* = enum
    VersionNewer,
    VersionUnchecked,
    VersionMatchesPreviousInvalid
    VersionSameAsCurrent

proc `=destroy`(ota: var typeof(OtaUpdateHandle()[])) =
  if ota.handle.uint32 != 0:
    let err = esp_ota_end(ota.handle)
    if err != ESP_OK:
      raise newEspError[OtaError]("Error ota end ", err)


proc newOtaUpdateHandle*(startFrom: ptr esp_partition_t = nil): OtaUpdateHandle =
  result = new(OtaUpdateHandle)

  result.handle = esp_ota_handle_t(0)
  result.update = esp_ota_get_next_update_partition(startFrom)
  result.configured = esp_ota_get_boot_partition()
  result.running = esp_ota_get_running_partition()


proc printPartionInfo*(ota: OtaUpdateHandle) =
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
    raise newEspError[OtaError]("Error ota begin: %s" & $esp_err_to_name(err), err)

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

    TAG.logi("New firmware version: %s", new_app_info.version)
    if not version_check:
      return (status: VersionUnchecked, info: new_app_info)

    var running_app_info: esp_app_desc_t

    if ota.running.esp_ota_get_partition_description(addr running_app_info) == ESP_OK:
      TAG.logi("Running firmware version: %s", running_app_info.version)

    var last_invalid_app: ptr esp_partition_t = esp_ota_get_last_invalid_partition()
    var invalid_app_info: esp_app_desc_t

    if last_invalid_app.esp_ota_get_partition_description(addr invalid_app_info) == ESP_OK:
      TAG.logi("Last invalid firmware version: %s", invalid_app_info.version)

    if last_invalid_app != nil and invalid_app_info.version == new_app_info.version:
      TAG.logw("New version is the same as invalid version.")
      TAG.logw("Previously, there was an attempt to launch the firmware with %s version, but it failed.",
                invalid_app_info.version)
      TAG.logw("The firmware has been rolled back to the previous version.")
      return (status: VersionMatchesPreviousInvalid, info: new_app_info)

    if new_app_info.version == running_app_info.version:
      return (status: VersionSameAsCurrent, info: new_app_info)

    return (status: VersionNewer, info: new_app_info)
