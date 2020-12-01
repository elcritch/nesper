##  OTA example
##
##    This example code is in the Public Domain (or CC0 licensed, at your option.)
##
##    Unless required by applicable law or agreed to in writing, this
##    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.
##

import nesper/consts
import nesper/general
import nesper/esp/storage/esp_ota_ops


const
  BUFFSIZE* = 1024
  HASH_LEN* = 32

var TAG*: cstring = "native_ota_example"

## an ota data write buffer ready to write to the flash

var ota_write_data*: array[BUFFSIZE + 1, char]

# var server_cert_pem_start*: UncheckedArray[uint8]
# var server_cert_pem_end*: UncheckedArray[uint8]

const
  OTA_URL_SIZE* = 256

proc ota_example_task*(pvParameter: pointer) {.cdecl.} =
  var err: esp_err_t
  ##  update handle : set by esp_ota_begin(), must be freed via esp_ota_end()
  var update_handle = esp_ota_handle_t(0)

  TAG.logi("Starting OTA example")
  var configured: ptr esp_partition_t = esp_ota_get_boot_partition()
  var running: ptr esp_partition_t = esp_ota_get_running_partition()
  
  if configured != running:
    TAG.logw("Configured OTA boot partition at offset 0x%08x, but running from offset 0x%08x",
             configured.address, running.address)
    TAG.logw("(This can happen if either the OTA boot data or preferred boot image become corrupted somehow.)")
    
  TAG.logi("Running partition type %d subtype %d (offset 0x%08x)",
           running.`type`, running.subtype, running.address)

  # var config: esp_http_client_config_t
  # config.url = "localhost.local"
  # config.cert_pem = nil
  # config.timeout_ms = 10

  update_partition = esp_ota_get_next_update_partition(nil)

  TAG.logi("Writing to partition subtype %d at offset 0x%x",
           update_partition.subtype, update_partition.address)

  assert(update_partition != nil)
  var binary_file_length: cint = 0
  ## deal with all receive packet
  var image_header_was_checked: bool = false
  while 1:
    var data_read: cint = esp_http_client_read(client, ota_write_data, BUFFSIZE)
    if data_read < 0:
      TAG.loge("Error: SSL data read error")
      http_cleanup(client)
      task_fatal_error()
    elif data_read > 0:

      if image_header_was_checked == false:
        var new_app_info: esp_app_desc_t
        if data_read >
            sizeof((esp_image_header_t)) + sizeof((esp_image_segment_header_t)) +
            sizeof((esp_app_desc_t)):
          ##  check current version with downloading
          memcpy(addr(new_app_info), addr(ota_write_data[sizeof(
              (esp_image_header_t)) + sizeof((esp_image_segment_header_t))]),
                 sizeof((esp_app_desc_t)))
          TAG.logi("New firmware version: %s", new_app_info.version)
          var running_app_info: esp_app_desc_t
          if esp_ota_get_partition_description(running, addr(running_app_info)) ==
              ESP_OK:
            TAG.logi("Running firmware version: %s", running_app_info.version)
          var last_invalid_app: ptr esp_partition_t = esp_ota_get_last_invalid_partition()
          var invalid_app_info: esp_app_desc_t
          if esp_ota_get_partition_description(last_invalid_app,
              addr(invalid_app_info)) == ESP_OK:
            TAG.logi("Last invalid firmware version: %s",
                     invalid_app_info.version)
          if last_invalid_app != nil:
            if memcmp(invalid_app_info.version, new_app_info.version,
                     sizeof((new_app_info.version))) == 0:
              TAG.logw("New version is the same as invalid version.")
              TAG.logw("Previously, there was an attempt to launch the firmware with %s version, but it failed.",
                       invalid_app_info.version)
              TAG.logw("The firmware has been rolled back to the previous version.")
              http_cleanup(client)
              infinite_loop()


          if memcmp(new_app_info.version, running_app_info.version,
                    sizeof((new_app_info.version))) == 0:
            raise newException(OSError, "Current running version is the same as a new. We will not continue the update.")

          image_header_was_checked = true
          err = esp_ota_begin(update_partition, OTA_SIZE_UNKNOWN,
                            addr(update_handle))
          if err != ESP_OK:
            TAG.loge("esp_ota_begin failed (%s)", esp_err_to_name(err))
            http_cleanup(client)
            task_fatal_error()
          TAG.logi("esp_ota_begin succeeded")
        else:
          TAG.loge("received package is not fit len")
          http_cleanup(client)
          task_fatal_error()

      err = esp_ota_write(update_handle, cast[pointer](ota_write_data), data_read)
      if err != ESP_OK:
        http_cleanup(client)
        task_fatal_error()
      inc(binary_file_length, data_read)
      ESP_LOGD(TAG, "Written image length %d", binary_file_length)
    ###################################
    elif data_read == 0:
      ##
      ##  As esp_http_client_read never returns negative error code, we rely on
      ##  `errno` to check for underlying transport connectivity closure if any
      ##
      if errno == ECONNRESET or errno == ENOTCONN:
        TAG.loge("Connection closed, errno = %d", errno)
        break
      if esp_http_client_is_complete_data_received(client) == true:
        TAG.logi("Connection closed")
        break
  TAG.logi("Total Write binary data length: %d", binary_file_length)
  if esp_http_client_is_complete_data_received(client) != true:
    TAG.loge("Error in receiving complete file")
    http_cleanup(client)
    task_fatal_error()
  err = esp_ota_end(update_handle)
  if err != ESP_OK:
    if err == ESP_ERR_OTA_VALIDATE_FAILED:
      TAG.loge("Image validation failed, image is corrupted")
    TAG.loge("esp_ota_end failed (%s)!", esp_err_to_name(err))
    http_cleanup(client)
    task_fatal_error()
  err = esp_ota_set_boot_partition(update_partition)
  if err != ESP_OK:
    TAG.loge("esp_ota_set_boot_partition failed (%s)!", esp_err_to_name(err))
    http_cleanup(client)
    task_fatal_error()
  TAG.logi("Prepare to restart system!")
  esp_restart()
  return

proc diagnostic*(): bool {.cdecl.} =
  var io_conf: gpio_config_t
  io_conf.intr_type = GPIO_PIN_INTR_DISABLE
  io_conf.mode = GPIO_MODE_INPUT
  io_conf.pin_bit_mask = (1 shl CONFIG_EXAMPLE_GPIO_DIAGNOSTIC)
  io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE
  io_conf.pull_up_en = GPIO_PULLUP_ENABLE
  gpio_config(addr(io_conf))
  TAG.logi("Diagnostics (5 sec)...")
  vTaskDelay(5000 div portTICK_PERIOD_MS)
  var diagnostic_is_ok: bool = gpio_get_level(CONFIG_EXAMPLE_GPIO_DIAGNOSTIC)
  gpio_reset_pin(CONFIG_EXAMPLE_GPIO_DIAGNOSTIC)
  return diagnostic_is_ok

proc app_main*() {.cdecl.} =
  var sha_256: array[HASH_LEN, uint8] = [0]
  var partition: esp_partition_t
  ##  get sha256 digest for the partition table
  partition.address = ESP_PARTITION_TABLE_OFFSET
  partition.size = ESP_PARTITION_TABLE_MAX_LEN
  partition.`type` = ESP_PARTITION_TYPE_DATA
  esp_partition_get_sha256(addr(partition), sha_256)
  print_sha256(sha_256, "SHA-256 for the partition table: ")
  ##  get sha256 digest for bootloader
  partition.address = ESP_BOOTLOADER_OFFSET
  partition.size = ESP_PARTITION_TABLE_OFFSET
  partition.`type` = ESP_PARTITION_TYPE_APP
  esp_partition_get_sha256(addr(partition), sha_256)
  print_sha256(sha_256, "SHA-256 for bootloader: ")
  ##  get sha256 digest for running partition
  esp_partition_get_sha256(esp_ota_get_running_partition(), sha_256)
  print_sha256(sha_256, "SHA-256 for current firmware: ")
  var running: ptr esp_partition_t = esp_ota_get_running_partition()
  var ota_state: esp_ota_img_states_t
  if esp_ota_get_state_partition(running, addr(ota_state)) == ESP_OK:
    if ota_state == ESP_OTA_IMG_PENDING_VERIFY:
      ##  run diagnostic function ...
      var diagnostic_is_ok: bool = diagnostic()
      if diagnostic_is_ok:
        TAG.logi(
                 "Diagnostics completed successfully! Continuing execution ...")
        esp_ota_mark_app_valid_cancel_rollback()
      else:
        TAG.loge("Diagnostics failed! Start rollback to the previous version ...")
        esp_ota_mark_app_invalid_rollback_and_reboot()

  var err: esp_err_t = nvs_flash_init()
  if err == ESP_ERR_NVS_NO_FREE_PAGES or err == ESP_ERR_NVS_NEW_VERSION_FOUND:
    ##  OTA app partition table has a smaller NVS partition size than the non-OTA
    ##  partition table. This size mismatch may cause NVS initialization to fail.
    ##  If this happens, we erase NVS partition and initialize NVS again.
    ESP_ERROR_CHECK(nvs_flash_erase())
    err = nvs_flash_init()
  ESP_ERROR_CHECK(err)
  tcpip_adapter_init()
  ESP_ERROR_CHECK(esp_event_loop_create_default())
  ##  This helper function configures Wi-Fi or Ethernet, as selected in menuconfig.
  ##  Read "Establishing Wi-Fi or Ethernet Connection" section in
  ##  examples/protocols/README.md for more information about this function.
  ##
  ESP_ERROR_CHECK(example_connect())
  when CONFIG_EXAMPLE_CONNECT_WIFI:
    ##  Ensure to disable any WiFi power save mode, this allows best throughput
    ##  and hence timings for overall OTA operation.
    ##
    esp_wifi_set_ps(WIFI_PS_NONE)
  xTaskCreate(addr(ota_example_task), "ota_example_task", 8192, nil, 5, nil)

proc handleData*() =
  if image_header_was_checked == false:
    var new_app_info: esp_app_desc_t
    if data_read >
        sizeof((esp_image_header_t)) + sizeof((esp_image_segment_header_t)) +
        sizeof((esp_app_desc_t)):
      ##  check current version with downloading
      memcpy(addr(new_app_info), addr(ota_write_data[sizeof(
          (esp_image_header_t)) + sizeof((esp_image_segment_header_t))]),
              sizeof((esp_app_desc_t)))
      TAG.logi("New firmware version: %s", new_app_info.version)
      var running_app_info: esp_app_desc_t
      if esp_ota_get_partition_description(running, addr(running_app_info)) ==
          ESP_OK:
        TAG.logi("Running firmware version: %s", running_app_info.version)
      var last_invalid_app: ptr esp_partition_t = esp_ota_get_last_invalid_partition()
      var invalid_app_info: esp_app_desc_t
      if esp_ota_get_partition_description(last_invalid_app,
          addr(invalid_app_info)) == ESP_OK:
        TAG.logi("Last invalid firmware version: %s",
                  invalid_app_info.version)
      if last_invalid_app != nil:
        if memcmp(invalid_app_info.version, new_app_info.version,
                  sizeof((new_app_info.version))) == 0:
          TAG.logw("New version is the same as invalid version.")
          TAG.logw("Previously, there was an attempt to launch the firmware with %s version, but it failed.",
                    invalid_app_info.version)
          TAG.logw("The firmware has been rolled back to the previous version.")
          http_cleanup(client)
          infinite_loop()


      if memcmp(new_app_info.version, running_app_info.version,
                sizeof((new_app_info.version))) == 0:
        raise newException(OSError, "Current running version is the same as a new. We will not continue the update.")

      image_header_was_checked = true
      err = esp_ota_begin(update_partition, OTA_SIZE_UNKNOWN,
                        addr(update_handle))
      if err != ESP_OK:
        TAG.loge("esp_ota_begin failed (%s)", esp_err_to_name(err))
        http_cleanup(client)
        task_fatal_error()
      TAG.logi("esp_ota_begin succeeded")
    else:
      TAG.loge("received package is not fit len")
      http_cleanup(client)
      task_fatal_error()
  err = esp_ota_write(update_handle, cast[pointer](ota_write_data), data_read)
  if err != ESP_OK:
    http_cleanup(client)
    task_fatal_error()
  inc(binary_file_length, data_read)
  ESP_LOGD(TAG, "Written image length %d", binary_file_length)