##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

import ../../consts

type
  spi_flash_chip_t* {.importc: "spi_flash_chip_t", header: "esp_flash.h", bycopy.} = object


## * @brief Structure for describing a region of flash

type
  esp_flash_region_t* {.importc: "esp_flash_region_t", header: "esp_flash.h", bycopy.} = object
    offset* {.importc: "offset".}: uint32 ## /< Start address of this region
    size* {.importc: "size".}: uint32 ## /< Size of the region


## * OS-level integration hooks for accessing flash chips inside a running OS

type
  esp_flash_os_functions_t* {.importc: "esp_flash_os_functions_t",
                             header: "esp_flash.h", bycopy.} = object
    start* {.importc: "start".}: proc (arg: pointer): esp_err_t ## *
                                                         ##  Called before commencing any flash operation. Does not need to be
                                                         ##  recursive (ie is called at most once for each call to 'end').
                                                         ##
    ## * Called after completing any flash operation.
    `end`* {.importc: "end".}: proc (arg: pointer): esp_err_t ## * Called before any erase/write operations to check whether the region is limited by the OS
    region_protected* {.importc: "region_protected".}: proc (arg: pointer;
        start_addr: csize_t; size: csize_t): esp_err_t ## * Delay for at least 'us' microseconds. Called in between 'start' and 'end'.
    delay_us* {.importc: "delay_us".}: proc (arg: pointer; us: cuint): esp_err_t ## * Yield to other tasks. Called during erase
                                                                        ## operations.
    `yield`* {.importc: "yield".}: proc (arg: pointer): esp_err_t


## * @brief Structure to describe a SPI flash chip connected to the system.
##
##     Structure must be initialized before use (passed to esp_flash_init()).
##

type
  esp_flash_t* {.importc: "esp_flash_t", header: "esp_flash.h", bycopy.} = object
    # host* {.importc: "host".}: ptr spi_flash_host_driver_t ## /< Pointer to hardware-specific "host_driver" structure. Must be initialized before used.
    # chip_drv* {.importc: "chip_drv".}: ptr spi_flash_chip_t ## /< Pointer to chip-model-specific "adapter" structure. If NULL, will be detected during initialisation.
    # os_func* {.importc: "os_func".}: ptr esp_flash_os_functions_t ## /< Pointer to os-specific hook structure. Call ``esp_flash_init_os_functions()`` to setup this field, after the host is properly initialized.
    # os_func_data* {.importc: "os_func_data".}: pointer ## /< Pointer to argument for os-specific hooks. Left NULL and will be initialized with ``os_func``.
    # read_mode* {.importc: "read_mode".}: esp_flash_io_mode_t ## /< Configured SPI flash read mode. Set before ``esp_flash_init`` is called.
    # size* {.importc: "size".}: uint32 ## /< Size of SPI flash in bytes. If 0, size will be detected during initialisation.
    # chip_id* {.importc: "chip_id".}: uint32 ## /< Detected chip id.


## * @brief Initialise SPI flash chip interface.
##
##  This function must be called before any other API functions are called for this chip.
##
##  @note Only the ``host`` and ``read_mode`` fields of the chip structure must
##        be initialised before this function is called. Other fields may be
##        auto-detected if left set to zero or NULL.
##
##  @note If the chip->drv pointer is NULL, chip chip_drv will be auto-detected
##        based on its manufacturer & product IDs. See
##        ``esp_flash_registered_flash_drivers`` pointer for details of this process.
##
##  @param chip Pointer to SPI flash chip to use. If NULL, esp_flash_default_chip is substituted.
##  @return ESP_OK on success, or a flash error code if initialisation fails.
##

proc esp_flash_init*(chip: ptr esp_flash_t): esp_err_t {.importc: "esp_flash_init",
    header: "esp_flash.h".}
## *
##  Check if appropriate chip driver is set.
##
##  @param chip Pointer to SPI flash chip to use. If NULL, esp_flash_default_chip is substituted.
##
##  @return true if set, otherwise false.
##

proc esp_flash_chip_driver_initialized*(chip: ptr esp_flash_t): bool {.
    importc: "esp_flash_chip_driver_initialized", header: "esp_flash.h".}
## * @brief Read flash ID via the common "RDID" SPI flash command.
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param[out] out_id Pointer to receive ID value.
##
##  ID is a 24-bit value. Lower 16 bits of 'id' are the chip ID, upper 8 bits are the manufacturer ID.
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_read_id*(chip: ptr esp_flash_t; out_id: ptr uint32): esp_err_t {.
    importc: "esp_flash_read_id", header: "esp_flash.h".}
## * @brief Detect flash size based on flash ID.
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param[out] out_size Detected size in bytes.
##
##  @note Most flash chips use a common format for flash ID, where the lower 4 bits specify the size as a power of 2. If
##  the manufacturer doesn't follow this convention, the size may be incorrectly detected.
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_get_size*(chip: ptr esp_flash_t; out_size: ptr uint32): esp_err_t {.
    importc: "esp_flash_get_size", header: "esp_flash.h".}
## * @brief Erase flash chip contents
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_erase_chip*(chip: ptr esp_flash_t): esp_err_t {.
    importc: "esp_flash_erase_chip", header: "esp_flash.h".}
## * @brief Erase a region of the flash chip
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param start Address to start erasing flash. Must be sector aligned.
##  @param len Length of region to erase. Must also be sector aligned.
##
##  Sector size is specifyed in chip->drv->sector_size field (typically 4096 bytes.) ESP_ERR_INVALID_ARG will be
##  returned if the start & length are not a multiple of this size.
##
##  Erase is performed using block (multi-sector) erases where possible (block size is specified in
##  chip->drv->block_erase_size field, typically 65536 bytes). Remaining sectors are erased using individual sector erase
##  commands.
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_erase_region*(chip: ptr esp_flash_t; start: uint32; len: uint32): esp_err_t {.
    importc: "esp_flash_erase_region", header: "esp_flash.h".}
## * @brief Read if the entire chip is write protected
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param[out] write_protected Pointer to boolean, set to the value of the write protect flag.
##
##  @note A correct result for this flag depends on the SPI flash chip model and chip_drv in use (via the 'chip->drv'
##  field).
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_get_chip_write_protect*(chip: ptr esp_flash_t;
                                      write_protected: ptr bool): esp_err_t {.
    importc: "esp_flash_get_chip_write_protect", header: "esp_flash.h".}
## * @brief Set write protection for the SPI flash chip
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param write_protect Boolean value for the write protect flag
##
##  @note Correct behaviour of this function depends on the SPI flash chip model and chip_drv in use (via the 'chip->drv'
##  field).
##
##  Some SPI flash chips may require a power cycle before write protect status can be cleared. Otherwise,
##  write protection can be removed via a follow-up call to this function.
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_set_chip_write_protect*(chip: ptr esp_flash_t; write_protect: bool): esp_err_t {.
    importc: "esp_flash_set_chip_write_protect", header: "esp_flash.h".}
## * @brief Read the list of individually protectable regions of this SPI flash chip.
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param[out] out_regions Pointer to receive a pointer to the array of protectable regions of the chip.
##  @param[out] out_num_regions Pointer to an integer receiving the count of protectable regions in the array returned in 'regions'.
##
##  @note Correct behaviour of this function depends on the SPI flash chip model and chip_drv in use (via the 'chip->drv'
##  field).
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_get_protectable_regions*(chip: ptr esp_flash_t;
                                       out_regions: ptr ptr esp_flash_region_t;
                                       out_num_regions: ptr uint32): esp_err_t {.
    importc: "esp_flash_get_protectable_regions", header: "esp_flash.h".}
## * @brief Detect if a region of the SPI flash chip is protected
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param region Pointer to a struct describing a protected region. This must match one of the regions returned from esp_flash_get_protectable_regions(...).
##  @param[out] out_protected Pointer to a flag which is set based on the protected status for this region.
##
##  @note It is possible for this result to be false and write operations to still fail, if protection is enabled for the entire chip.
##
##  @note Correct behaviour of this function depends on the SPI flash chip model and chip_drv in use (via the 'chip->drv'
##  field).
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_get_protected_region*(chip: ptr esp_flash_t;
                                    region: ptr esp_flash_region_t;
                                    out_protected: ptr bool): esp_err_t {.
    importc: "esp_flash_get_protected_region", header: "esp_flash.h".}
## * @brief Update the protected status for a region of the SPI flash chip
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param region Pointer to a struct describing a protected region. This must match one of the regions returned from esp_flash_get_protectable_regions(...).
##  @param protect Write protection flag to set.
##
##  @note It is possible for the region protection flag to be cleared and write operations to still fail, if protection is enabled for the entire chip.
##
##  @note Correct behaviour of this function depends on the SPI flash chip model and chip_drv in use (via the 'chip->drv'
##  field).
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_set_protected_region*(chip: ptr esp_flash_t;
                                    region: ptr esp_flash_region_t; protect: bool): esp_err_t {.
    importc: "esp_flash_set_protected_region", header: "esp_flash.h".}
## * @brief Read data from the SPI flash chip
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param buffer Pointer to a buffer where the data will be read. To get better performance, this should be in the DRAM and word aligned.
##  @param address Address on flash to read from. Must be less than chip->size field.
##  @param length Length (in bytes) of data to read.
##
##  There are no alignment constraints on buffer, address or length.
##
##  @note If on-chip flash encryption is used, this function returns raw (ie encrypted) data. Use the flash cache
##  to transparently decrypt data.
##
##  @return
##       - ESP_OK: success
##       - ESP_ERR_NO_MEM: Buffer is in external PSRAM which cannot be concurrently accessed, and a temporary internal buffer could not be allocated.
##       - or a flash error code if operation failed.
##

proc esp_flash_read*(chip: ptr esp_flash_t; buffer: pointer; address: uint32;
                    length: uint32): esp_err_t {.importc: "esp_flash_read",
    header: "esp_flash.h".}
## * @brief Write data to the SPI flash chip
##
##  @param chip Pointer to identify flash chip. Must have been successfully initialised via esp_flash_init()
##  @param address Address on flash to write to. Must be previously erased (SPI NOR flash can only write bits 1->0).
##  @param buffer Pointer to a buffer with the data to write. To get better performance, this should be in the DRAM and word aligned.
##  @param length Length (in bytes) of data to write.
##
##  There are no alignment constraints on buffer, address or length.
##
##  @return ESP_OK on success, or a flash error code if operation failed.
##

proc esp_flash_write*(chip: ptr esp_flash_t; buffer: pointer; address: uint32;
                     length: uint32): esp_err_t {.importc: "esp_flash_write",
    header: "esp_flash.h".}
## * @brief Encrypted and write data to the SPI flash chip using on-chip hardware flash encryption
##
##  @param chip Pointer to identify flash chip. Must be NULL (the main flash chip). For other chips, encrypted write is not supported.
##  @param address Address on flash to write to. 16 byte aligned. Must be previously erased (SPI NOR flash can only write bits 1->0).
##  @param buffer Pointer to a buffer with the data to write.
##  @param length Length (in bytes) of data to write. 16 byte aligned.
##
##  @note Both address & length must be 16 byte aligned, as this is the encryption block size
##
##  @return
##   - ESP_OK: on success
##   - ESP_ERR_NOT_SUPPORTED: encrypted write not supported for this chip.
##   - ESP_ERR_INVALID_ARG: Either the address, buffer or length is invalid.
##   - or other flash error code from spi_flash_write_encrypted().
##

proc esp_flash_write_encrypted*(chip: ptr esp_flash_t; address: uint32;
                               buffer: pointer; length: uint32): esp_err_t {.
    importc: "esp_flash_write_encrypted", header: "esp_flash.h".}
## * @brief Read and decrypt data from the SPI flash chip using on-chip hardware flash encryption
##
##  @param chip Pointer to identify flash chip. Must be NULL (the main flash chip). For other chips, encrypted read is not supported.
##  @param address Address on flash to read from.
##  @param out_buffer Pointer to a buffer for the data to read to.
##  @param length Length (in bytes) of data to read.
##
##  @return
##   - ESP_OK: on success
##   - ESP_ERR_NOT_SUPPORTED: encrypted read not supported for this chip.
##   - or other flash error code from spi_flash_read_encrypted().
##

proc esp_flash_read_encrypted*(chip: ptr esp_flash_t; address: uint32;
                              out_buffer: pointer; length: uint32): esp_err_t {.
    importc: "esp_flash_read_encrypted", header: "esp_flash.h".}
## * @brief Pointer to the "default" SPI flash chip, ie the main chip attached to the MCU.
##
##    This chip is used if the 'chip' argument pass to esp_flash_xxx API functions is ever NULL.
##

var esp_flash_default_chip* {.importc: "esp_flash_default_chip",
                            header: "esp_flash.h".}: ptr esp_flash_t

## ******************************************************************************
##  Utility Functions
## ****************************************************************************
## *
##  @brief Returns true if chip is configured for Quad I/O or Quad Fast Read.
##
##  @param chip Pointer to SPI flash chip to use. If NULL, esp_flash_default_chip is substituted.
##
##  @return true if flash works in quad mode, otherwise false
##

proc esp_flash_is_quad_mode*(chip: ptr esp_flash_t): bool {.importc: "$1", header: "esp_flash.h".}
