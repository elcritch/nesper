const
  VFS_TUSB_MAX_PATH* = 16 ##
                          ##  SPDX-FileCopyrightText: 2020-2022 Espressif Systems (Shanghai) CO LTD
                          ##
                          ##  SPDX-License-Identifier: Apache-2.0
                          ##
  VFS_TUSB_PATH_DEFAULT* = "/dev/tusb_cdc"


proc esp_vfs_tusb_cdc_register*(cdc_intf: cint; path: cstring): esp_err_t {.
    cdecl, importc: "esp_vfs_tusb_cdc_register", header: "vfs_tinyusb.h".}
  ##
                              ##
                              ##  @brief Register TinyUSB CDC at VFS with path
                              ##  @param cdc_intf - interface number of TinyUSB's CDC
                              ##  @param path - path where the CDC will be registered, `/dev/tusb_cdc` will be used if left NULL.
                              ##
                              ##  @return esp_err_t ESP_OK or ESP_FAIL
                              ##

proc esp_vfs_tusb_cdc_unregister*(path: cstring): esp_err_t {.cdecl,
    importc: "esp_vfs_tusb_cdc_unregister", header: "vfs_tinyusb.h".}
  ##
                              ##
                              ##  @brief Unregister TinyUSB CDC from VFS
                              ##  @param path - path where the CDC will be unregistered if NULL will be used `/dev/tusb_cdc`
                              ##
                              ##  @return esp_err_t ESP_OK or ESP_FAIL
                              ## 