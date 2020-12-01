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

##  @brief Flash encryption mode based on efuse values
##

type
  esp_flash_enc_mode_t* {.size: sizeof(cint).} = enum
    ESP_FLASH_ENC_MODE_DISABLED, ##  flash encryption is not enabled (flash crypt cnt=0)
    ESP_FLASH_ENC_MODE_DEVELOPMENT, ##  flash encryption is enabled but for Development (reflash over UART allowed)
    ESP_FLASH_ENC_MODE_RELEASE ##  flash encryption is enabled for Release (reflash over UART disabled)


## \*
##  @file esp_partition.h
##  @brief Support functions for flash encryption features
##
##  Can be compiled as part of app or bootloader code.
##


## \* @brief Is flash encryption currently enabled in hardware?
##
##  Flash encryption is enabled if the FLASH_CRYPT_CNT efuse has an odd number of bits set.
##
##  @return true if flash encryption is enabled.
##

proc esp_flash_encryption_enabled*(): bool {.
    importc: "esp_flash_encryption_enabled", header: "esp_flash_encrypt.h".}
##  @brief Update on-device flash encryption
##
##  Intended to be called as part of the bootloader process if flash
##  encryption is enabled in device menuconfig.
##
##  If FLASH_CRYPT_CNT efuse parity is 1 (ie odd number of bits set),
##  then return ESP_OK immediately (indicating flash encryption is enabled
##  and functional).
##
##  If FLASH_CRYPT_CNT efuse parity is 0 (ie even number of bits set),
##  assume the flash has just been written with plaintext that needs encrypting.
##
##  The following regions of flash are encrypted in place:
##
##  - The bootloader image, if a valid plaintext image is found.[*]
##  - The partition table, if a valid plaintext table is found.
##  - Any app partition that contains a valid plaintext app image.
##  - Any other partitions with the "encrypt" flag set. [**]
##
##  After the re-encryption process completes, a '1' bit is added to the
##  FLASH_CRYPT_CNT value (setting the parity to 1) and the EFUSE is re-burned.
##
##  [*] If reflashing bootloader with secure boot enabled, pre-encrypt
##  the bootloader before writing it to flash or secure boot will fail.
##
##  [**] For this reason, if serial re-flashing a previous flashed
##  device with secure boot enabled and using FLASH_CRYPT_CNT to
##  trigger re-encryption, you must simultaneously re-flash plaintext
##  content to all partitions with the "encrypt" flag set or this
##  data will be corrupted (encrypted twice).
##
##  @note The post-condition of this function is that all
##  partitions that should be encrypted are encrypted.
##
##  @note Take care not to power off the device while this function
##  is running, or the partition currently being encrypted will be lost.
##
##  @note RTC_WDT will reset while encryption operations will be performed (if RTC_WDT is configured).
##
##  @return ESP_OK if all operations succeeded, ESP_ERR_INVALID_STATE
##  if a fatal error occured during encryption of all partitions.
##

proc esp_flash_encrypt_check_and_update*(): esp_err_t {.
    importc: "esp_flash_encrypt_check_and_update", header: "esp_flash_encrypt.h".}


## \* @brief Encrypt-in-place a block of flash sectors
##
##  @note This function resets RTC_WDT between operations with sectors.
##  @param src_addr Source offset in flash. Should be multiple of 4096 bytes.
##  @param data_length Length of data to encrypt in bytes. Will be rounded up to next multiple of 4096 bytes.
##
##  @return ESP_OK if all operations succeeded, ESP_ERR_FLASH_OP_FAIL
##  if SPI flash fails, ESP_ERR_FLASH_OP_TIMEOUT if flash times out.
##

proc esp_flash_encrypt_region*(src_addr: uint32; data_length: csize_t): esp_err_t {.
    importc: "esp_flash_encrypt_region", header: "esp_flash_encrypt.h".}


## \* @brief Write protect FLASH_CRYPT_CNT
##
##  Intended to be called as a part of boot process if flash encryption
##  is enabled but secure boot is not used. This should protect against
##  serial re-flashing of an unauthorised code in absence of secure boot.
##
##

proc esp_flash_write_protect_crypt_cnt*() {.
    importc: "esp_flash_write_protect_crypt_cnt", header: "esp_flash_encrypt.h".}


## \* @brief Return the flash encryption mode
##
##  The API is called during boot process but can also be called by
##  application to check the current flash encryption mode of ESP32
##
##  @return
##

proc esp_get_flash_encryption_mode*(): esp_flash_enc_mode_t {.
    importc: "esp_get_flash_encryption_mode", header: "esp_flash_encrypt.h".}


## \* @brief Check the flash encryption mode during startup
##
##  @note This function is called automatically during app startup,
##  it doesn't need to be called from the app.
##
##  Verifies the flash encryption config during startup:
##
##  - Correct any insecure flash encryption settings if hardware
##    Secure Boot is enabled.
##  - Log warnings if the efuse config doesn't match the project
##   config in any way
##

proc esp_flash_encryption_init_checks*() {.
    importc: "esp_flash_encryption_init_checks", header: "esp_flash_encrypt.h".}

