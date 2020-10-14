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

import ../consts

type
  esp_mac_type_t* {.size: sizeof(cint).} = enum
    ESP_MAC_WIFI_STA,
    ESP_MAC_WIFI_SOFTAP,
    ESP_MAC_BT, ESP_MAC_ETH


## * @cond

const
  TWO_UNIVERSAL_MAC_ADDR* = 2
  FOUR_UNIVERSAL_MAC_ADDR* = 4

## * @endcond
## *
##  @brief Reset reasons
##

type
  esp_reset_reason_t* {.size: sizeof(cint).} = enum
    ESP_RST_UNKNOWN,          ## !< Reset reason can not be determined
    ESP_RST_POWERON,          ## !< Reset due to power-on event
    ESP_RST_EXT,              ## !< Reset by external pin (not applicable for ESP32)
    ESP_RST_SW,               ## !< Software reset via esp_restart
    ESP_RST_PANIC,            ## !< Software reset due to exception/panic
    ESP_RST_INT_WDT,          ## !< Reset (software or hardware) due to interrupt watchdog
    ESP_RST_TASK_WDT,         ## !< Reset due to task watchdog
    ESP_RST_WDT,              ## !< Reset due to other watchdogs
    ESP_RST_DEEPSLEEP,        ## !< Reset after exiting deep sleep mode
    ESP_RST_BROWNOUT,         ## !< Brownout reset (software or hardware)
    ESP_RST_SDIO              ## !< Reset over SDIO


## *
##  Shutdown handler type
##

type
  shutdown_handler_t* = proc () {.cdecl.}

## *
##  @brief  Register shutdown handler
##
##  This function allows you to register a handler that gets invoked before
##  the application is restarted using esp_restart function.
##  @param handle function to execute on restart
##  @return
##    - ESP_OK on success
##    - ESP_ERR_INVALID_STATE if the handler has already been registered
##    - ESP_ERR_NO_MEM if no more shutdown handler slots are available
##

proc esp_register_shutdown_handler*(handle: shutdown_handler_t): esp_err_t {.
    importc: "esp_register_shutdown_handler", header: "esp_system.h".}


## *
##  @brief  Unregister shutdown handler
##
##  This function allows you to unregister a handler which was previously
##  registered using esp_register_shutdown_handler function.
##    - ESP_OK on success
##    - ESP_ERR_INVALID_STATE if the given handler hasn't been registered before
##

proc esp_unregister_shutdown_handler*(handle: shutdown_handler_t): esp_err_t {.
    importc: "esp_unregister_shutdown_handler", header: "esp_system.h".}


## *
##  @brief  Restart PRO and APP CPUs.
##
##  This function can be called both from PRO and APP CPUs.
##  After successful restart, CPU reset reason will be SW_CPU_RESET.
##  Peripherals (except for WiFi, BT, UART0, SPI1, and legacy timers) are not reset.
##  This function does not return.
##

proc esp_restart*() {.importc: "esp_restart", header: "esp_system.h".}


## *
##  @brief  Get reason of last reset
##  @return See description of esp_reset_reason_t for explanation of each value.
##

proc esp_reset_reason*(): esp_reset_reason_t {.importc: "esp_reset_reason",
    header: "esp_system.h".}


## *
##  @brief  Get the size of available heap.
##
##  Note that the returned value may be larger than the maximum contiguous block
##  which can be allocated.
##
##  @return Available heap size, in bytes.
##

proc esp_get_free_heap_size*(): uint32 {.importc: "esp_get_free_heap_size",
                                        header: "esp_system.h".}


## *
##  @brief Get the minimum heap that has ever been available
##
##  @return Minimum free heap ever available
##

proc esp_get_minimum_free_heap_size*(): uint32 {.
    importc: "esp_get_minimum_free_heap_size", header: "esp_system.h".}


## *
##  @brief  Get one random 32-bit word from hardware RNG
##
##  The hardware RNG is fully functional whenever an RF subsystem is running (ie Bluetooth or WiFi is enabled). For
##  random values, call this function after WiFi or Bluetooth are started.
##
##  If the RF subsystem is not used by the program, the function bootloader_random_enable() can be called to enable an
##  entropy source. bootloader_random_disable() must be called before RF subsystem or I2S peripheral are used. See these functions'
##  documentation for more details.
##
##  Any time the app is running without an RF subsystem (or bootloader_random) enabled, RNG hardware should be
##  considered a PRNG. A very small amount of entropy is available due to pre-seeding while the IDF
##  bootloader is running, but this should not be relied upon for any use.
##
##  @return Random value between 0 and UINT32_MAX
##

proc esp_random*(): uint32 {.importc: "esp_random", header: "esp_system.h".}


## *
##  @brief Fill a buffer with random bytes from hardware RNG
##
##  @note This function has the same restrictions regarding available entropy as esp_random()
##
##  @param buf Pointer to buffer to fill with random numbers.
##  @param len Length of buffer in bytes
##

proc esp_fill_random*(buf: pointer; len: csize_t) {.importc: "esp_fill_random",
    header: "esp_system.h".}


## *
##  @brief  Set base MAC address with the MAC address which is stored in BLK3 of EFUSE or
##          external storage e.g. flash and EEPROM.
##
##  Base MAC address is used to generate the MAC addresses used by the networking interfaces.
##  If using base MAC address stored in BLK3 of EFUSE or external storage, call this API to set base MAC
##  address with the MAC address which is stored in BLK3 of EFUSE or external storage before initializing
##  WiFi/BT/Ethernet.
##
##  @param  mac  base MAC address, length: 6 bytes.
##
##  @return ESP_OK on success
##
proc esp_base_mac_addr_set*(mac: ptr uint8): esp_err_t {.
    importc: "esp_base_mac_addr_set", header: "esp_system.h".}


## *
##  @brief  Return base MAC address which is set using esp_base_mac_addr_set.
##
##  @param  mac  base MAC address, length: 6 bytes.
##
##  @return ESP_OK on success
##          ESP_ERR_INVALID_MAC base MAC address has not been set
##
proc esp_base_mac_addr_get*(mac: ptr uint8): esp_err_t {.
    importc: "esp_base_mac_addr_get", header: "esp_system.h".}


## *
##  @brief  Return base MAC address which was previously written to BLK3 of EFUSE.
##
##  Base MAC address is used to generate the MAC addresses used by the networking interfaces.
##  This API returns the custom base MAC address which was previously written to BLK3 of EFUSE.
##  Writing this EFUSE allows setting of a different (non-Espressif) base MAC address. It is also
##  possible to store a custom base MAC address elsewhere, see esp_base_mac_addr_set() for details.
##
##  @param  mac  base MAC address, length: 6 bytes.
##
##  @return ESP_OK on success
##          ESP_ERR_INVALID_VERSION An invalid MAC version field was read from BLK3 of EFUSE
##          ESP_ERR_INVALID_CRC An invalid MAC CRC was read from BLK3 of EFUSE
##
proc esp_efuse_mac_get_custom*(mac: ptr uint8): esp_err_t {.
    importc: "esp_efuse_mac_get_custom", header: "esp_system.h".}


## *
##  @brief  Return base MAC address which is factory-programmed by Espressif in BLK0 of EFUSE.
##
##  @param  mac  base MAC address, length: 6 bytes.
##
##  @return ESP_OK on success
##
proc esp_efuse_mac_get_default*(mac: ptr uint8): esp_err_t {.
    importc: "esp_efuse_mac_get_default", header: "esp_system.h".}


## *
##  @brief  Read base MAC address and set MAC address of the interface.
##
##  This function first get base MAC address using esp_base_mac_addr_get or reads base MAC address
##  from BLK0 of EFUSE. Then set the MAC address of the interface including wifi station, wifi softap,
##  bluetooth and ethernet.
##
##  @param  mac  MAC address of the interface, length: 6 bytes.
##  @param  type  type of MAC address, 0:wifi station, 1:wifi softap, 2:bluetooth, 3:ethernet.
##
##  @return ESP_OK on success
##
proc esp_read_mac*(mac: ptr uint8; `type`: esp_mac_type_t): esp_err_t {.
    importc: "esp_read_mac", header: "esp_system.h".}


## *
##  @brief  Derive local MAC address from universal MAC address.
##
##  This function derives a local MAC address from an universal MAC address.
##  A `definition of local vs universal MAC address can be found on Wikipedia
##  <https://en.wikipedia.org/wiki/MAC_address#Universal_vs._local>`.
##  In ESP32, universal MAC address is generated from base MAC address in EFUSE or other external storage.
##  Local MAC address is derived from the universal MAC address.
##
##  @param  local_mac  Derived local MAC address, length: 6 bytes.
##  @param  universal_mac  Source universal MAC address, length: 6 bytes.
##
##  @return ESP_OK on success
##
proc esp_derive_local_mac*(local_mac: ptr uint8; universal_mac: ptr uint8): esp_err_t {.
    importc: "esp_derive_local_mac", header: "esp_system.h".}


## *
##  @brief Chip models
##
type
  esp_chip_model_t* {.size: sizeof(cint).} = enum
    CHIP_ESP32 = 1              ## !< ESP32


##  Chip feature flags, used in esp_chip_info_t
const
  CHIP_FEATURE_EMB_FLASH* = BIT(0) ## !< Chip has embedded flash memory
  CHIP_FEATURE_WIFI_BGN* = BIT(1) ## !< Chip has 2.4GHz WiFi
  CHIP_FEATURE_BLE* = BIT(4)    ## !< Chip has Bluetooth LE
  CHIP_FEATURE_BT* = BIT(5)     ## !< Chip has Bluetooth Classic

## *
##  @brief The structure represents information about the chip
##
type
  esp_chip_info_t* {.importc: "esp_chip_info_t", header: "esp_system.h", bycopy.} = object
    model* {.importc: "model".}: esp_chip_model_t ## !< chip model, one of esp_chip_model_t
    features* {.importc: "features".}: uint32 ## !< bit mask of CHIP_FEATURE_x feature flags
    cores* {.importc: "cores".}: uint8 ## !< number of CPU cores
    revision* {.importc: "revision".}: uint8 ## !< chip revision number


## *
##  @brief Fill an esp_chip_info_t structure with information about the chip
##  @param[out] out_info structure to be filled
##
proc esp_chip_info*(out_info: ptr esp_chip_info_t) {.importc: "esp_chip_info",
    header: "esp_system.h".}

