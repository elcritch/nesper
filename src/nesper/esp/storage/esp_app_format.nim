##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
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

# import ../../consts
## *
##  @brief ESP chip ID
##
##

type
  esp_chip_id_t* {.size: sizeof(cint).} = enum
    ESP_CHIP_ID_ESP32 = 0x00000000, ## !< chip ID: ESP32
    ESP_CHIP_ID_INVALID = 0x0000FFFF


## *
##  @brief SPI flash mode, used in esp_image_header_t
##

type
  esp_image_spi_mode_t* {.size: sizeof(cint).} = enum
    ESP_IMAGE_SPI_MODE_QIO,   ## !< SPI mode QIO
    ESP_IMAGE_SPI_MODE_QOUT,  ## !< SPI mode QOUT
    ESP_IMAGE_SPI_MODE_DIO,   ## !< SPI mode DIO
    ESP_IMAGE_SPI_MODE_DOUT,  ## !< SPI mode DOUT
    ESP_IMAGE_SPI_MODE_FAST_READ, ## !< SPI mode FAST_READ
    ESP_IMAGE_SPI_MODE_SLOW_READ ## !< SPI mode SLOW_READ


## *
##  @brief SPI flash clock frequency
##

type
  esp_image_spi_freq_t* {.size: sizeof(cint).} = enum
    ESP_IMAGE_SPI_SPEED_40M,  ## !< SPI clock frequency 40 MHz
    ESP_IMAGE_SPI_SPEED_26M,  ## !< SPI clock frequency 26 MHz
    ESP_IMAGE_SPI_SPEED_20M,  ## !< SPI clock frequency 20 MHz
    ESP_IMAGE_SPI_SPEED_80M = 0x0000000F


## *
##  @brief Supported SPI flash sizes
##

type
  esp_image_flash_size_t* {.size: sizeof(cint).} = enum
    ESP_IMAGE_FLASH_SIZE_1MB = 0, ## !< SPI flash size 1 MB
    ESP_IMAGE_FLASH_SIZE_2MB, ## !< SPI flash size 2 MB
    ESP_IMAGE_FLASH_SIZE_4MB, ## !< SPI flash size 4 MB
    ESP_IMAGE_FLASH_SIZE_8MB, ## !< SPI flash size 8 MB
    ESP_IMAGE_FLASH_SIZE_16MB, ## !< SPI flash size 16 MB
    ESP_IMAGE_FLASH_SIZE_MAX  ## !< SPI flash size MAX


const
  ESP_IMAGE_HEADER_MAGIC* = 0x000000E9

## *
##  @brief Main header of binary image
##

type
  esp_image_header_t* {.importc: "esp_image_header_t", header: "esp_app_format.h",
                       bycopy.} = object
    magic* {.importc: "magic".}: uint8 ## !< Magic word ESP_IMAGE_HEADER_MAGIC
    segment_count* {.importc: "segment_count".}: uint8 ## !< Count of memory segments
    spi_mode* {.importc: "spi_mode".}: uint8 ## !< flash read mode (esp_image_spi_mode_t as uint8)
    spi_speed* {.importc: "spi_speed", bitsize: 4.}: uint8 ## !< flash frequency (esp_image_spi_freq_t as uint8)
    spi_size* {.importc: "spi_size", bitsize: 4.}: uint8 ## !< flash chip size (esp_image_flash_size_t as uint8)
    entry_addr* {.importc: "entry_addr".}: uint32 ## !< Entry address
    wp_pin* {.importc: "wp_pin".}: uint8 ## !< WP pin when SPI pins set via efuse (read by ROM bootloader,
                                       ##  the IDF bootloader uses software to configure the WP
                                       ##  pin and sets this field to 0xEE=disabled)
    spi_pin_drv* {.importc: "spi_pin_drv".}: array[3, uint8] ## !< Drive settings for the SPI flash pins (read by ROM bootloader)
    chip_id* {.importc: "chip_id".}: esp_chip_id_t ## !< Chip identification number
    min_chip_rev* {.importc: "min_chip_rev".}: uint8 ## !< Minimum chip revision supported by image
    reserved* {.importc: "reserved".}: array[8, uint8] ## !< Reserved bytes in additional header space, currently unused
    hash_appended* {.importc: "hash_appended".}: uint8 ## !< If 1, a SHA256 digest "simple hash" (of the entire image) is appended after the checksum.
                                                     ##  Included in image length. This digest
                                                     ##  is separate to secure boot and only used for detecting corruption.
                                                     ##  For secure boot signed images, the signature
                                                     ##  is appended after this (and the simple hash is included in the signed data).


type
  esp_image_segment_header_t* {.importc: "esp_image_segment_header_t",
                               header: "esp_app_format.h", bycopy.} = object
    load_addr* {.importc: "load_addr".}: uint32 ## !< Address of segment
    data_len* {.importc: "data_len".}: uint32 ## !< Length of data


const
  ESP_IMAGE_MAX_SEGMENTS* = 16
  ESP_APP_DESC_MAGIC_WORD* = 0xABCD5432

## *
##  @brief Description about application.
##

when defined(ESP_IDF_V4_0):
  const hdr = "esp_app_format.h"
else:
  const hdr = "esp_app_desc.h"

type
  esp_app_desc_t* {.importc: "esp_app_desc_t", header: hdr, bycopy.} = object
    magic_word* {.importc: "magic_word".}: uint32 ## !< Magic word ESP_APP_DESC_MAGIC_WORD
    secure_version* {.importc: "secure_version".}: uint32 ## !< Secure version
    reserv1* {.importc: "reserv1".}: array[2, uint32] ## !< reserv1
    version* {.importc: "version".}: array[32, char] ## !< Application version
    project_name* {.importc: "project_name".}: array[32, char] ## !< Project name
    time* {.importc: "time".}: array[16, char] ## !< Compile time
    date* {.importc: "date".}: array[16, char] ## !< Compile date
    idf_ver* {.importc: "idf_ver".}: array[32, char] ## !< Version IDF
    app_elf_sha256* {.importc: "app_elf_sha256".}: array[32, uint8] ## !< sha256 of elf file
    reserv2* {.importc: "reserv2".}: array[20, uint32] ## !< reserv2


