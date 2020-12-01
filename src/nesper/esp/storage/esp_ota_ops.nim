##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

# import
#   esp_err, esp_partition, esp_image_format, esp_flash_partitions
import ../../consts

import esp_app_format
import esp_partition

const
    chdr = "<esp_https_ota.h>"

# var portMAX_DELAY* {.importc: "portMAX_DELAY", header: "<freertos/FreeRTOS.h>".}: TickType_t

var
  OTA_SIZE_UNKNOWN* {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_BASE* {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_PARTITION_CONFLICT* {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_SELECT_INFO_INVALID*  {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_VALIDATE_FAILED*  {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_SMALL_SEC_VER*  {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_ROLLBACK_FAILED*  {.importc: "$1", header: chdr.}: uint32
  ESP_ERR_OTA_ROLLBACK_INVALID_STATE* {.importc: "$1", header: chdr.}: uint32



## \*
##  @brief Opaque handle for an application OTA update
##
##  esp_ota_begin() returns a handle which is then used for subsequent
##  calls to esp_ota_write() and esp_ota_end().
##

type
  esp_ota_handle_t* = distinct uint32



## \*
##  @brief   Return esp_app_desc structure. This structure includes app version.
##
##  Return description for running app.
##  @return Pointer to esp_app_desc structure.
##

proc esp_ota_get_app_description*(): ptr esp_app_desc_t {.
    importc: "esp_ota_get_app_description", header: "esp_ota_ops.h".}


## \*
##  @brief   Fill the provided buffer with SHA256 of the ELF file, formatted as hexadecimal, null-terminated.
##  If the buffer size is not sufficient to fit the entire SHA256 in hex plus a null terminator,
##  the largest possible number of bytes will be written followed by a null.
##  @param dst   Destination buffer
##  @param size  Size of the buffer
##  @return      Number of bytes written to dst (including null terminator)
##

proc esp_ota_get_app_elf_sha256*(dst: cstring; size: csize_t): cint {.
    importc: "esp_ota_get_app_elf_sha256", header: "esp_ota_ops.h".}




## \*
##  @brief   Commence an OTA update writing to the specified partition.
##
##  The specified partition is erased to the specified image size.
##
##  If image size is not yet known, pass OTA_SIZE_UNKNOWN which will
##  cause the entire partition to be erased.
##
##  On success, this function allocates memory that remains in use
##  until esp_ota_end() is called with the returned handle.
##
##  Note: If the rollback option is enabled and the running application has the ESP_OTA_IMG_PENDING_VERIFY state then
##  it will lead to the ESP_ERR_OTA_ROLLBACK_INVALID_STATE error. Confirm the running app before to run download a new app,
##  use esp_ota_mark_app_valid_cancel_rollback() function for it (this should be done as early as possible when you first download a new application).
##
##  @param partition Pointer to info for partition which will receive the OTA update. Required.
##  @param image_size Size of new OTA app image. Partition will be erased in order to receive this size of image. If 0 or OTA_SIZE_UNKNOWN, the entire partition is erased.
##  @param out_handle On success, returns a handle which should be used for subsequent esp_ota_write() and esp_ota_end() calls.
##
##  @return
##     - ESP_OK: OTA operation commenced successfully.
##     - ESP_ERR_INVALID_ARG: partition or out_handle arguments were NULL, or partition doesn't point to an OTA app partition.
##     - ESP_ERR_NO_MEM: Cannot allocate memory for OTA operation.
##     - ESP_ERR_OTA_PARTITION_CONFLICT: Partition holds the currently running firmware, cannot update in place.
##     - ESP_ERR_NOT_FOUND: Partition argument not found in partition table.
##     - ESP_ERR_OTA_SELECT_INFO_INVALID: The OTA data partition contains invalid data.
##     - ESP_ERR_INVALID_SIZE: Partition doesn't fit in configured flash size.
##     - ESP_ERR_FLASH_OP_TIMEOUT or ESP_ERR_FLASH_OP_FAIL: Flash write failed.
##     - ESP_ERR_OTA_ROLLBACK_INVALID_STATE: If the running app has not confirmed state. Before performing an update, the application must be valid.
##

proc esp_ota_begin*(partition: ptr esp_partition_t; image_size: csize_t;
                   out_handle: ptr esp_ota_handle_t): esp_err_t {.
    importc: "esp_ota_begin", header: "esp_ota_ops.h".}


## \*
##  @brief   Write OTA update data to partition
##
##  This function can be called multiple times as
##  data is received during the OTA operation. Data is written
##  sequentially to the partition.
##
##  @param handle  Handle obtained from esp_ota_begin
##  @param data    Data buffer to write
##  @param size    Size of data buffer in bytes.
##
##  @return
##     - ESP_OK: Data was written to flash successfully.
##     - ESP_ERR_INVALID_ARG: handle is invalid.
##     - ESP_ERR_OTA_VALIDATE_FAILED: First byte of image contains invalid app image magic byte.
##     - ESP_ERR_FLASH_OP_TIMEOUT or ESP_ERR_FLASH_OP_FAIL: Flash write failed.
##     - ESP_ERR_OTA_SELECT_INFO_INVALID: OTA data partition has invalid contents
##

proc esp_ota_write*(handle: esp_ota_handle_t; data: pointer; size: csize_t): esp_err_t {.
    importc: "esp_ota_write", header: "esp_ota_ops.h".}


## \*
##  @brief Finish OTA update and validate newly written app image.
##
##  @param handle  Handle obtained from esp_ota_begin().
##
##  @note After calling esp_ota_end(), the handle is no longer valid and any memory associated with it is freed (regardless of result).
##
##  @return
##     - ESP_OK: Newly written OTA app image is valid.
##     - ESP_ERR_NOT_FOUND: OTA handle was not found.
##     - ESP_ERR_INVALID_ARG: Handle was never written to.
##     - ESP_ERR_OTA_VALIDATE_FAILED: OTA image is invalid (either not a valid app image, or - if secure boot is enabled - signature failed to verify.)
##     - ESP_ERR_INVALID_STATE: If flash encryption is enabled, this result indicates an internal error writing the final encrypted bytes to flash.
##

proc esp_ota_end*(handle: esp_ota_handle_t): esp_err_t {.importc: "esp_ota_end",
    header: "esp_ota_ops.h".}


## \*
##  @brief Configure OTA data for a new boot partition
##
##  @note If this function returns ESP_OK, calling esp_restart() will boot the newly configured app partition.
##
##  @param partition Pointer to info for partition containing app image to boot.
##
##  @return
##     - ESP_OK: OTA data updated, next reboot will use specified partition.
##     - ESP_ERR_INVALID_ARG: partition argument was NULL or didn't point to a valid OTA partition of type "app".
##     - ESP_ERR_OTA_VALIDATE_FAILED: Partition contained invalid app image. Also returned if secure boot is enabled and signature validation failed.
##     - ESP_ERR_NOT_FOUND: OTA data partition not found.
##     - ESP_ERR_FLASH_OP_TIMEOUT or ESP_ERR_FLASH_OP_FAIL: Flash erase or write failed.
##

proc esp_ota_set_boot_partition*(partition: ptr esp_partition_t): esp_err_t {.
    importc: "esp_ota_set_boot_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Get partition info of currently configured boot app
##
##  If esp_ota_set_boot_partition() has been called, the partition which was set by that function will be returned.
##
##  If esp_ota_set_boot_partition() has not been called, the result is usually the same as esp_ota_get_running_partition().
##  The two results are not equal if the configured boot partition does not contain a valid app (meaning that the running partition
##  will be an app that the bootloader chose via fallback).
##
##  If the OTA data partition is not present or not valid then the result is the first app partition found in the
##  partition table. In priority order, this means: the factory app, the first OTA app slot, or the test app partition.
##
##  Note that there is no guarantee the returned partition is a valid app. Use esp_image_verify(ESP_IMAGE_VERIFY, ...) to verify if the
##  returned partition contains a bootable image.
##
##  @return Pointer to info for partition structure, or NULL if partition table is invalid or a flash read operation failed. Any returned pointer is valid for the lifetime of the application.
##

proc esp_ota_get_boot_partition*(): ptr esp_partition_t {.
    importc: "esp_ota_get_boot_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Get partition info of currently running app
##
##  This function is different to esp_ota_get_boot_partition() in that
##  it ignores any change of selected boot partition caused by
##  esp_ota_set_boot_partition(). Only the app whose code is currently
##  running will have its partition information returned.
##
##  The partition returned by this function may also differ from esp_ota_get_boot_partition() if the configured boot
##  partition is somehow invalid, and the bootloader fell back to a different app partition at boot.
##
##  @return Pointer to info for partition structure, or NULL if no partition is found or flash read operation failed. Returned pointer is valid for the lifetime of the application.
##

proc esp_ota_get_running_partition*(): ptr esp_partition_t {.
    importc: "esp_ota_get_running_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Return the next OTA app partition which should be written with a new firmware.
##
##  Call this function to find an OTA app partition which can be passed to esp_ota_begin().
##
##  Finds next partition round-robin, starting from the current running partition.
##
##  @param start_from If set, treat this partition info as describing the current running partition. Can be NULL, in which case esp_ota_get_running_partition() is used to find the currently running partition. The result of this function is never the same as this argument.
##
##  @return Pointer to info for partition which should be updated next. NULL result indicates invalid OTA data partition, or that no eligible OTA app slot partition was found.
##
##

proc esp_ota_get_next_update_partition*(start_from: ptr esp_partition_t): ptr esp_partition_t {.
    importc: "esp_ota_get_next_update_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Returns esp_app_desc structure for app partition. This structure includes app version.
##
##  Returns a description for the requested app partition.
##  @param[in] partition     Pointer to app partition. (only app partition)
##  @param[out] app_desc     Structure of info about app.
##  @return
##   - ESP_OK                Successful.
##   - ESP_ERR_NOT_FOUND     app_desc structure is not found. Magic word is incorrect.
##   - ESP_ERR_NOT_SUPPORTED Partition is not application.
##   - ESP_ERR_INVALID_ARG   Arguments is NULL or if partition's offset exceeds partition size.
##   - ESP_ERR_INVALID_SIZE  Read would go out of bounds of the partition.
##   - or one of error codes from lower-level flash driver.
##

proc esp_ota_get_partition_description*(partition: ptr esp_partition_t;
                                       app_desc: ptr esp_app_desc_t): esp_err_t {.
    importc: "esp_ota_get_partition_description", header: "esp_ota_ops.h".}


## \*
##  @brief This function is called to indicate that the running app is working well.
##
##  @return
##   - ESP_OK: if successful.
##

proc esp_ota_mark_app_valid_cancel_rollback*(): esp_err_t {.
    importc: "esp_ota_mark_app_valid_cancel_rollback", header: "esp_ota_ops.h".}


## \*
##  @brief This function is called to roll back to the previously workable app with reboot.
##
##  If rollback is successful then device will reset else API will return with error code.
##  Checks applications on a flash drive that can be booted in case of rollback.
##  If the flash does not have at least one app (except the running app) then rollback is not possible.
##  @return
##   - ESP_FAIL: if not successful.
##   - ESP_ERR_OTA_ROLLBACK_FAILED: The rollback is not possible due to flash does not have any apps.
##

proc esp_ota_mark_app_invalid_rollback_and_reboot*(): esp_err_t {.
    importc: "esp_ota_mark_app_invalid_rollback_and_reboot",
    header: "esp_ota_ops.h".}


## \*
##  @brief Returns last partition with invalid state (ESP_OTA_IMG_INVALID or ESP_OTA_IMG_ABORTED).
##
##  @return partition.
##

proc esp_ota_get_last_invalid_partition*(): ptr esp_partition_t {.
    importc: "esp_ota_get_last_invalid_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Returns state for given partition.
##
##  @param[in] partition  Pointer to partition.
##  @param[out] ota_state state of partition (if this partition has a record in otadata).
##  @return
##         - ESP_OK:                 Successful.
##         - ESP_ERR_INVALID_ARG:    partition or ota_state arguments were NULL.
##         - ESP_ERR_NOT_SUPPORTED:  partition is not ota.
##         - ESP_ERR_NOT_FOUND:      Partition table does not have otadata or state was not found for given partition.
##

proc esp_ota_get_state_partition*(partition: ptr esp_partition_t;
                                 ota_state: ptr esp_ota_img_states_t): esp_err_t {.
    importc: "esp_ota_get_state_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Erase previous boot app partition and corresponding otadata select for this partition.
##
##  When current app is marked to as valid then you can erase previous app partition.
##  @return
##         - ESP_OK:   Successful, otherwise ESP_ERR.
##

proc esp_ota_erase_last_boot_app_partition*(): esp_err_t {.
    importc: "esp_ota_erase_last_boot_app_partition", header: "esp_ota_ops.h".}


## \*
##  @brief Checks applications on the slots which can be booted in case of rollback.
##
##  These applications should be valid (marked in otadata as not UNDEFINED, INVALID or ABORTED and crc is good) and be able booted,
##  and secure_version of app >= secure_version of efuse (if anti-rollback is enabled).
##
##  @return
##         - True: Returns true if the slots have at least one app (except the running app).
##         - False: The rollback is not possible.
##

proc esp_ota_check_rollback_is_possible*(): bool {.
    importc: "esp_ota_check_rollback_is_possible", header: "esp_ota_ops.h".}