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

import consts

const
  NVS_KEY_SIZE* = 32

## *
##  @brief Key for encryption and decryption
##

type
  nvs_sec_cfg_t* {.importc: "nvs_sec_cfg_t", header: "nvs_flash.h", bycopy.} = object
    eky* {.importc: "eky".}: array[NVS_KEY_SIZE, uint8] ## !<  XTS encryption and decryption key
    tky* {.importc: "tky".}: array[NVS_KEY_SIZE, uint8] ## !<  XTS tweak key


## *
##  @brief Initialize the default NVS partition.
##
##  This API initialises the default NVS partition. The default NVS partition
##  is the one that is labeled "nvs" in the partition table.
##
##  @return
##       - ESP_OK if storage was successfully initialized.
##       - ESP_ERR_NVS_NO_FREE_PAGES if the NVS storage contains no empty pages
##         (which may happen if NVS partition was truncated)
##       - ESP_ERR_NOT_FOUND if no partition with label "nvs" is found in the partition table
##       - one of the error codes from the underlying flash storage driver
##

proc nvs_flash_init*(): esp_err_t {.cdecl, importc: "nvs_flash_init",
                                 header: "nvs_flash.h".}
## *
##  @brief Initialize NVS flash storage for the specified partition.
##
##  @param[in]  partition_label   Label of the partition. Note that internally a reference to
##                                passed value is kept and it should be accessible for future operations
##
##  @return
##       - ESP_OK if storage was successfully initialized.
##       - ESP_ERR_NVS_NO_FREE_PAGES if the NVS storage contains no empty pages
##         (which may happen if NVS partition was truncated)
##       - ESP_ERR_NOT_FOUND if specified partition is not found in the partition table
##       - one of the error codes from the underlying flash storage driver
##

proc nvs_flash_init_partition*(partition_label: cstring): esp_err_t {.cdecl,
    importc: "nvs_flash_init_partition", header: "nvs_flash.h".}
## *
##  @brief Deinitialize NVS storage for the default NVS partition
##
##  Default NVS partition is the partition with "nvs" label in the partition table.
##
##  @return
##       - ESP_OK on success (storage was deinitialized)
##       - ESP_ERR_NVS_NOT_INITIALIZED if the storage was not initialized prior to this call
##

proc nvs_flash_deinit*(): esp_err_t {.cdecl, importc: "nvs_flash_deinit",
                                   header: "nvs_flash.h".}
## *
##  @brief Deinitialize NVS storage for the given NVS partition
##
##  @param[in]  partition_label   Label of the partition
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_NVS_NOT_INITIALIZED if the storage for given partition was not
##         initialized prior to this call
##

proc nvs_flash_deinit_partition*(partition_label: cstring): esp_err_t {.cdecl,
    importc: "nvs_flash_deinit_partition", header: "nvs_flash.h".}
## *
##  @brief Erase the default NVS partition
##
##  This function erases all contents of the default NVS partition (one with label "nvs")
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_NOT_FOUND if there is no NVS partition labeled "nvs" in the
##         partition table
##

proc nvs_flash_erase*(): esp_err_t {.cdecl, importc: "nvs_flash_erase",
                                  header: "nvs_flash.h".}
## *
##  @brief Erase specified NVS partition
##
##  This function erases all contents of specified NVS partition
##
##  @param[in]  part_name    Name (label) of the partition to be erased
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_NOT_FOUND if there is no NVS partition with the specified name
##         in the partition table
##

proc nvs_flash_erase_partition*(part_name: cstring): esp_err_t {.cdecl,
    importc: "nvs_flash_erase_partition", header: "nvs_flash.h".}
## *
##  @brief Initialize the default NVS partition.
##
##  This API initialises the default NVS partition. The default NVS partition
##  is the one that is labeled "nvs" in the partition table.
##
##  @param[in]  cfg Security configuration (keys) to be used for NVS encryption/decryption.
##                               If cfg is NULL, no encryption is used.
##
##  @return
##       - ESP_OK if storage was successfully initialized.
##       - ESP_ERR_NVS_NO_FREE_PAGES if the NVS storage contains no empty pages
##         (which may happen if NVS partition was truncated)
##       - ESP_ERR_NOT_FOUND if no partition with label "nvs" is found in the partition table
##       - one of the error codes from the underlying flash storage driver
##

proc nvs_flash_secure_init*(cfg: ptr nvs_sec_cfg_t): esp_err_t {.cdecl,
    importc: "nvs_flash_secure_init", header: "nvs_flash.h".}
## *
##  @brief Initialize NVS flash storage for the specified partition.
##
##  @param[in]  partition_label   Label of the partition. Note that internally a reference to
##                                passed value is kept and it should be accessible for future operations
##
##  @param[in]  cfg Security configuration (keys) to be used for NVS encryption/decryption.
##                               If cfg is null, no encryption/decryption is used.
##  @return
##       - ESP_OK if storage was successfully initialized.
##       - ESP_ERR_NVS_NO_FREE_PAGES if the NVS storage contains no empty pages
##         (which may happen if NVS partition was truncated)
##       - ESP_ERR_NOT_FOUND if specified partition is not found in the partition table
##       - one of the error codes from the underlying flash storage driver
##

proc nvs_flash_secure_init_partition*(partition_label: cstring;
                                     cfg: ptr nvs_sec_cfg_t): esp_err_t {.cdecl,
    importc: "nvs_flash_secure_init_partition", header: "nvs_flash.h".}
## *
##  @brief Generate and store NVS keys in the provided esp partition
##
##  @param[in]  partition Pointer to partition structure obtained using
##                        esp_partition_find_first or esp_partition_get.
##                        Must be non-NULL.
##  @param[out] cfg       Pointer to nvs security configuration structure.
##                        Pointer must be non-NULL.
##                        Generated keys will be populated in this structure.
##
##
##  @return
##       -ESP_OK, if cfg was read successfully;
##       -or error codes from esp_partition_write/erase APIs.
##

# proc nvs_flash_generate_keys*(partition: ptr esp_partition_t; cfg: ptr nvs_sec_cfg_t): esp_err_t {.
    # cdecl, importc: "nvs_flash_generate_keys", header: "nvs_flash.h".}
## *
##  @brief Read NVS security configuration from a partition.
##
##  @param[in]  partition Pointer to partition structure obtained using
##                        esp_partition_find_first or esp_partition_get.
##                        Must be non-NULL.
##  @param[out] cfg       Pointer to nvs security configuration structure.
##                        Pointer must be non-NULL.
##
##  @note  Provided parition is assumed to be marked 'encrypted'.
##
##  @return
##       -ESP_OK, if cfg was read successfully;
##       -ESP_ERR_NVS_KEYS_NOT_INITIALIZED, if the partition is not yet written with keys.
##       -ESP_ERR_NVS_CORRUPT_KEY_PART, if the partition containing keys is found to be corrupt
##       -or error codes from esp_partition_read API.
##

# proc nvs_flash_read_security_cfg*(partition: ptr esp_partition_t;
                                #  cfg: ptr nvs_sec_cfg_t): esp_err_t {.cdecl,
    # importc: "nvs_flash_read_security_cfg", header: "nvs_flash.h".}

