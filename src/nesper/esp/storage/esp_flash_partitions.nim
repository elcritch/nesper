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

import ../../consts

var ESP_PARTITION_MAGIC* {.importc: "ESP_PARTITION_MAGIC",
                         header: "esp_flash_partitions.h".}: uint8

var ESP_PARTITION_MAGIC_MD5* {.importc: "ESP_PARTITION_MAGIC_MD5",
                             header: "esp_flash_partitions.h".}: uint8

var PART_TYPE_APP* {.importc: "PART_TYPE_APP", header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_FACTORY* {.importc: "PART_SUBTYPE_FACTORY",
                          header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_OTA_FLAG* {.importc: "PART_SUBTYPE_OTA_FLAG",
                           header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_OTA_MASK* {.importc: "PART_SUBTYPE_OTA_MASK",
                           header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_TEST* {.importc: "PART_SUBTYPE_TEST",
                       header: "esp_flash_partitions.h".}: uint8

var PART_TYPE_DATA* {.importc: "PART_TYPE_DATA", header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_DATA_OTA* {.importc: "PART_SUBTYPE_DATA_OTA",
                           header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_DATA_RF* {.importc: "PART_SUBTYPE_DATA_RF",
                          header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_DATA_WIFI* {.importc: "PART_SUBTYPE_DATA_WIFI",
                            header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_DATA_NVS_KEYS* {.importc: "PART_SUBTYPE_DATA_NVS_KEYS",
                                header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_DATA_EFUSE_EM* {.importc: "PART_SUBTYPE_DATA_EFUSE_EM",
                                header: "esp_flash_partitions.h".}: uint8

var PART_TYPE_END* {.importc: "PART_TYPE_END", header: "esp_flash_partitions.h".}: uint8

var PART_SUBTYPE_END* {.importc: "PART_SUBTYPE_END",
                      header: "esp_flash_partitions.h".}: uint8

var PART_FLAG_ENCRYPTED* {.importc: "PART_FLAG_ENCRYPTED",
                         header: "esp_flash_partitions.h".}: uint8

##  Pre-partition table fixed flash offsets

var ESP_BOOTLOADER_DIGEST_OFFSET* {.importc: "ESP_BOOTLOADER_DIGEST_OFFSET",
                                  header: "esp_flash_partitions.h".}: uint8

var ESP_BOOTLOADER_OFFSET* {.importc: "ESP_BOOTLOADER_OFFSET",
                           header: "esp_flash_partitions.h".}: uint8

##  Offset of bootloader image. Has matching value in bootloader KConfig.projbuild file.

var ESP_PARTITION_TABLE_OFFSET* {.importc: "ESP_PARTITION_TABLE_OFFSET",
                                header: "esp_flash_partitions.h".}: uint8

##  Offset of partition table. Backwards-compatible name.

var ESP_PARTITION_TABLE_MAX_LEN* {.importc: "ESP_PARTITION_TABLE_MAX_LEN",
                                 header: "esp_flash_partitions.h".}: uint8

##  Maximum length of partition table data

var ESP_PARTITION_TABLE_MAX_ENTRIES* {.importc: "ESP_PARTITION_TABLE_MAX_ENTRIES",
                                     header: "esp_flash_partitions.h".}: uint8

##  Maximum length of partition table data, including terminating entry
## / OTA_DATA states for checking operability of the app.

type
  esp_ota_img_states_t* {.size: sizeof(cint).} = enum
    ESP_OTA_IMG_NEW = 0x00000000, ## !< Monitor the first boot. In bootloader this state is changed to ESP_OTA_IMG_PENDING_VERIFY.
    ESP_OTA_IMG_PENDING_VERIFY = 0x00000001, ## !< First boot for this app was. If while the second boot this state is then it will be changed to ABORTED.
    ESP_OTA_IMG_VALID = 0x00000002, ## !< App was confirmed as workable. App can boot and work without limits.
    ESP_OTA_IMG_INVALID = 0x00000003, ## !< App was confirmed as non-workable. This app will not selected to boot at all.
    ESP_OTA_IMG_ABORTED = 0x00000004, ## !< App could not confirm the workable or non-workable. In bootloader IMG_PENDING_VERIFY state will be changed to IMG_ABORTED. This app will not selected to boot at all.
    ESP_OTA_IMG_UNDEFINED = 0xFFFFFFFF ## !< Undefined. App can boot and work without limits.


##  OTA selection structure (two copies in the OTA data partition.)
##    Size of 32 bytes is friendly to flash encryption

type
  esp_ota_select_entry_t* {.importc: "esp_ota_select_entry_t",
                           header: "esp_flash_partitions.h", bycopy.} = object
    ota_seq* {.importc: "ota_seq".}: uint32
    seq_label* {.importc: "seq_label".}: array[20, uint8]
    ota_state* {.importc: "ota_state".}: uint32
    crc* {.importc: "crc".}: uint32 ##  CRC32 of ota_seq field only

  esp_partition_pos_t* {.importc: "esp_partition_pos_t",
                        header: "esp_flash_partitions.h", bycopy.} = object
    offset* {.importc: "offset".}: uint32
    size* {.importc: "size".}: uint32


##  Structure which describes the layout of partition table entry.
##  See docs/partition_tables.rst for more information about individual fields.
##

type
  esp_partition_info_t* {.importc: "esp_partition_info_t",
                         header: "esp_flash_partitions.h", bycopy.} = object
    magic* {.importc: "magic".}: uint16
    `type`* {.importc: "type".}: uint8
    subtype* {.importc: "subtype".}: uint8
    pos* {.importc: "pos".}: esp_partition_pos_t
    label* {.importc: "label".}: array[16, uint8]
    flags* {.importc: "flags".}: uint32


##  @brief Verify the partition table
##
##  @param partition_table Pointer to at least ESP_PARTITION_TABLE_MAX_ENTRIES of potential partition table data. (ESP_PARTITION_TABLE_MAX_LEN bytes.)
##  @param log_errors Log errors if the partition table is invalid.
##  @param num_partitions If result is ESP_OK, num_partitions is updated with total number of partitions (not including terminating entry).
##
##  @return ESP_OK on success, ESP_ERR_INVALID_STATE if partition table is not valid.
##

proc esp_partition_table_verify*(partition_table: ptr esp_partition_info_t;
                                log_errors: bool; num_partitions: ptr cint): esp_err_t {.
    importc: "esp_partition_table_verify", header: "esp_flash_partitions.h".}


## \*
##  Check whether the region on the main flash is safe to write.
##
##  @param addr Start address of the region
##  @param size Size of the region
##
##  @return true if the region is safe to write, otherwise false.
##

proc esp_partition_main_flash_region_safe*(`addr`: csize_t; size: csize_t): bool {.
    importc: "esp_partition_main_flash_region_safe",
    header: "esp_flash_partitions.h".}

