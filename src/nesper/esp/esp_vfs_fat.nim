##  Copyright 2015-2017 Espressif Systems (Shanghai) PTE LTD
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

import ../consts
import driver/sdmmc_types, driver/sdmmc_host, fatfs/ff

const theader = """esp_vfs_fat.h"""

# From wear leveling

type
    wl_handle_t* = int32 


const
    WL_INVALID_HANDLE* = -1


##
## @brief Register FATFS with VFS component
##
## This function registers given FAT drive in VFS, at the specified base path.
## If only one drive is used, fat_drive argument can be an empty string.
## Refer to FATFS library documentation on how to specify FAT drive.
## This function also allocates FATFS structure which should be used for f_mount
## call.
##
## @note This function doesn't mount the drive into FATFS, it just connects
##       POSIX and C standard library IO function with FATFS. You need to mount
##       desired drive into FATFS separately.
##
## @param base_path  path prefix where FATFS should be registered
## @param fat_drive  FATFS drive specification; if only one drive is used, can be an empty string
## @param max_files  maximum number of files which can be open at the same time
## @param[out] out_fs  pointer to FATFS structure which can be used for FATFS f_mount call is returned via this argument.
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_register was already called
##      - ESP_ERR_NO_MEM if not enough memory or too many VFSes already registered
##

proc esp_vfs_fat_register*(base_path : cstring, fat_drive : cstring,
        max_files : uint32, out_fs : ptr ptr FATFS ) : esp_err_t {.cdecl, importc: "esp_vfs_fat_register", header: theader.}


##
## @brief Un-register FATFS from VFS
##
## @note FATFS structure returned by esp_vfs_fat_register is destroyed after
##       this call. Make sure to call f_mount function to unmount it before
##       calling esp_vfs_fat_unregister_ctx.
##       Difference between this function and the one above is that this one
##       will release the correct drive, while the one above will release
##       the last registered one
##
## @param base_path     path prefix where FATFS is registered. This is the same
##                      used when esp_vfs_fat_register was called
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if FATFS is not registered in VFS
##

proc esp_vfs_fat_unregister_path*(base_path : cstring) : esp_err_t {.cdecl, importc: "esp_vfs_fat_unregister_path", header: theader.}


##
## @brief Configuration arguments for esp_vfs_fat_sdmmc_mount and esp_vfs_fat_spiflash_mount functions
##

type
    esp_vfs_fat_mount_config_t*  {.importc: "esp_vfs_fat_mount_config_t", header: theader, bycopy.} = object 
        ##
        ## If FAT partition can not be mounted, and this parameter is true,
        ## create partition table and format the filesystem.
        ##
        format_if_mount_failed  : bool
        max_files               : int32 # Max number of open files
        ##
        ## If format_if_mount_failed is set, and mount fails, format the card
        ## with given allocation unit size. Must be a power of 2, between sector
        ## size and 128 * sector size.
        ## For SD cards, sector size is always 512 bytes. For wear_levelling,
        ## sector size is determined by CONFIG_WL_SECTOR_SIZE option.
        ## 
        ## Using larger allocation unit size will result in higher read/write
        ## performance and higher overhead when storing small files.
        ##  
        ## Setting this field to 0 will result in allocation unit set to the
        ## sector size.
        ##
        allocation_unit_size    : uint32
    
    # compatibility definition
    esp_vfs_fat_sdmmc_mount_config_t* = esp_vfs_fat_mount_config_t


##
## @brief Convenience function to get FAT filesystem on SD card registered in VFS
##
## This is an all-in-one function which does the following:
## - initializes SDMMC driver or SPI driver with configuration in host_config
## - initializes SD card with configuration in slot_config
## - mounts FAT partition on SD card using FATFS library, with configuration in mount_config
## - registers FATFS library with VFS, with prefix given by base_prefix variable
##
## This function is intended to make example code more compact.
## For real world applications, developers should implement the logic of
## probing SD card, locating and mounting partition, and registering FATFS in VFS,
## with proper error checking and handling of exceptional conditions.
##
## @param base_path     path where partition should be registered (e.g. "/sdcard")
## @param host_config   Pointer to structure describing SDMMC host. When using
##                      SDMMC peripheral, this structure can be initialized using
##                      SDMMC_HOST_DEFAULT() macro. When using SPI peripheral,
##                      this structure can be initialized using SDSPI_HOST_DEFAULT()
##                      macro.
## @param slot_config   Pointer to structure with slot configuration.
##                      For SDMMC peripheral, pass a pointer to sdmmc_slot_config_t
##                      structure initialized using SDMMC_SLOT_CONFIG_DEFAULT.
##                      For SPI peripheral, pass a pointer to sdspi_slot_config_t
##                      structure initialized using SDSPI_SLOT_CONFIG_DEFAULT.
## @param mount_config  pointer to structure with extra parameters for mounting FATFS
## @param[out] out_card  if not NULL, pointer to the card information structure will be returned via this argument
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_sdmmc_mount was already called
##      - ESP_ERR_NO_MEM if memory can not be allocated
##      - ESP_FAIL if partition can not be mounted
##      - other error codes from SDMMC or SPI drivers, SDMMC protocol, or FATFS drivers
##

proc esp_vfs_fat_sdmmc_mount*(base_path : cstring,
                            host_config : ptr sdmmc_host_t,
                            slot_config : pointer,
                            mount_config : ptr esp_vfs_fat_mount_config_t,
                            out_card : ptr ptr sdmmc_card_t ) : esp_err_t
    {.cdecl, importc: "esp_vfs_fat_sdmmc_mount", header: theader.}


##
## @brief Unmount FAT filesystem and release resources acquired using esp_vfs_fat_sdmmc_mount
##
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_sdmmc_mount hasn't been called
##

proc esp_vfs_fat_sdmmc_unmount*() : esp_err_t {.cdecl, importc: "esp_vfs_fat_sdmmc_unmount", header: theader.}


##
## @brief Convenience function to initialize FAT filesystem in SPI flash and register it in VFS
##
## This is an all-in-one function which does the following:
##
## - finds the partition with defined partition_label. Partition label should be
##   configured in the partition table.
## - initializes flash wear levelling library on top of the given partition
## - mounts FAT partition using FATFS library on top of flash wear levelling
##   library
## - registers FATFS library with VFS, with prefix given by base_prefix variable
##
## This function is intended to make example code more compact.
##
## @param base_path        path where FATFS partition should be mounted (e.g. "/spiflash")
## @param partition_label  label of the partition which should be used
## @param mount_config     pointer to structure with extra parameters for mounting FATFS
## @param[out] wl_handle   wear levelling driver handle
## @return
##      - ESP_OK on success
##      - ESP_ERR_NOT_FOUND if the partition table does not contain FATFS partition with given label
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_spiflash_mount was already called
##      - ESP_ERR_NO_MEM if memory can not be allocated
##      - ESP_FAIL if partition can not be mounted
##      - other error codes from wear levelling library, SPI flash driver, or FATFS drivers
##

proc esp_vfs_fat_spiflash_mount*(base_path : cstring,
                                partition_label : cstring,
                                mount_config : ptr esp_vfs_fat_mount_config_t,
                                wl_handle: ptr wl_handle_t) : esp_err_t
    {.cdecl, importc: "esp_vfs_fat_spiflash_mount", header: theader.}


##
## @brief Unmount FAT filesystem and release resources acquired using esp_vfs_fat_spiflash_mount
##
## @param base_path  path where partition should be registered (e.g. "/spiflash")
## @param wl_handle  wear levelling driver handle returned by esp_vfs_fat_spiflash_mount
##
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_spiflash_mount hasn't been called
##

proc esp_vfs_fat_spiflash_unmount*(base_path : cstring, wl_handle: ptr wl_handle_t) : esp_err_t {.cdecl, importc: "esp_vfs_fat_spiflash_unmount", header: theader.}


##
## @brief Convenience function to initialize read-only FAT filesystem and register it in VFS
##
## This is an all-in-one function which does the following:
##
## - finds the partition with defined partition_label. Partition label should be
##   configured in the partition table.
## - mounts FAT partition using FATFS library
## - registers FATFS library with VFS, with prefix given by base_prefix variable
##
## @note Wear levelling is not used when FAT is mounted in read-only mode using this function.
##
## @param base_path        path where FATFS partition should be mounted (e.g. "/spiflash")
## @param partition_label  label of the partition which should be used
## @param mount_config     pointer to structure with extra parameters for mounting FATFS
## @return
##      - ESP_OK on success
##      - ESP_ERR_NOT_FOUND if the partition table does not contain FATFS partition with given label
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_rawflash_mount was already called for the same partition
##      - ESP_ERR_NO_MEM if memory can not be allocated
##      - ESP_FAIL if partition can not be mounted
##      - other error codes from SPI flash driver, or FATFS drivers
##

proc esp_vfs_fat_rawflash_mount*(base_path : cstring,
                                cpartition_label : cstring,
                                mount_config : ptr esp_vfs_fat_mount_config_t) : esp_err_t
    {.cdecl, importc: "esp_vfs_fat_rawflash_mount", header: theader.}


##
## @brief Unmount FAT filesystem and release resources acquired using esp_vfs_fat_rawflash_mount
##
## @param base_path  path where partition should be registered (e.g. "/spiflash")
## @param partition_label label of partition to be unmounted
##
## @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE if esp_vfs_fat_spiflash_mount hasn't been called
##

proc esp_vfs_fat_rawflash_unmount*(base_path : cstring, cpartition_label : cstring) : esp_err_t {.cdecl, importc: "esp_vfs_fat_rawflash_unmount", header: theader.}

