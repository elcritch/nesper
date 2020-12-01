
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
    UpdateInvalidLength,
    UpdateOk,
    UpdateMatchesPreviousInvalid
    UpdateSameAsCurrent

proc `=destroy`(ota: var typeof(OtaUpdateHandle()[])) =
  # TAG.logi("i2c port finalize")
  let err = esp_ota_end(ota.handle)
  if err != ESP_OK:
    raise newEspError[OtaError]("Error ota end ", err)


proc newOtaUpdateHandle*(startFrom: ptr esp_partition_t = nil): OtaUpdateHandle =
  result = new(OtaUpdateHandle)

  result.handle = esp_ota_handle_t(0)
  result.update = esp_ota_get_next_update_partition(startFrom)
  result.configured = esp_ota_get_boot_partition()
  result.running = esp_ota_get_running_partition()


proc begin*(ota: OtaUpdateHandle) =
  let err = esp_ota_begin(ota.update, OTA_SIZE_UNKNOWN, addr(ota.handle))
  if err != ESP_OK:
    TAG.loge("esp_ota_begin failed (%s)", repr(ota.update))
    raise newEspError[OtaError]("Error ota begin: %s" & $esp_err_to_name(err), err)

proc checkImageHeader*(ota: OtaUpdateHandle, data: var string):
      tuple[status: OtaUpdateStatus, desc: esp_app_desc_t] =

    var new_app_info: esp_app_desc_t
    let
      sz_image_hdr = sizeof(esp_image_header_t) 
      sz_image_seg_hdr = sizeof(esp_image_segment_header_t) 
      sz_app_desc = sizeof(esp_app_desc_t)

    let header_sz = sz_image_hdr + sz_image_seg_hdr + sz_app_desc

    if data.len() < header_sz:
      raise newException(ValueError, "received package is not fit len")

    ##  check current version with downloading
    copyMem(addr new_app_info,
            addr data[sz_image_hdr + sz_image_seg_hdr],
            sizeof(esp_app_desc_t))

    TAG.logi("New firmware version: %s", new_app_info.version)

    var running_app_info: esp_app_desc_t

    if esp_ota_get_partition_description(ota.running, addr(running_app_info)) == ESP_OK:
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

    if new_app_info.version == running_app_info.version:
      raise newException(OtaError, "Current running version is the same as a new.")
