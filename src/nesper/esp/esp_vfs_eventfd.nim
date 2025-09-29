import ../consts

const
  EFD_SUPPORT_ISR* = (1 shl 4) ##
                               ##  SPDX-FileCopyrightText: 2021-2024 Espressif Systems (Shanghai) CO LTD
                               ##
                               ##  SPDX-License-Identifier: Apache-2.0
                               ##

type

  esp_vfs_eventfd_config_t* {.importc: "esp_vfs_eventfd_config_t",
                              header: "esp_vfs_eventfd.h", bycopy.} = object ##
                              ##
                              ##  @brief Eventfd vfs initialization settings
                              ##
    max_fds* {.importc: "max_fds".}: csize_t
    ## !< The maximum number of eventfds supported



proc ESP_VFS_EVENTD_CONFIG_DEFAULT*(): esp_vfs_eventfd_config_t =
  {.emit: """
  esp_vfs_eventfd_config_t cfg = ESP_VFS_EVENTD_CONFIG_DEFAULT();
  `result` = cfg;
  """.}

proc esp_vfs_eventfd_register*(config: ptr esp_vfs_eventfd_config_t): esp_err_t {.
    cdecl, importc: "esp_vfs_eventfd_register", header: "esp_vfs_eventfd.h".}
  ##
                              ##
                              ##  @brief  Registers the event vfs.
                              ##
                              ##  @return  ESP_OK if successful, ESP_ERR_NO_MEM if too many VFSes are
                              ##           registered.
                              ##

proc esp_vfs_eventfd_unregister*(): esp_err_t {.cdecl,
    importc: "esp_vfs_eventfd_unregister", header: "esp_vfs_eventfd.h".}
  ##
                              ##
                              ##  @brief  Unregisters the event vfs.
                              ##
                              ##  @return ESP_OK if successful, ESP_ERR_INVALID_STATE if VFS for given prefix
                              ##          hasn't been registered
                              ##

proc eventfd*(initval: cuint; flags: cint): cint {.cdecl, importc: "eventfd",
    header: "esp_vfs_eventfd.h".}
  ##
                                 ##  @brief Creates an event file descriptor.
                                 ##
                                 ##  The behavior of read, write and select is the same as man(2) eventfd with
                                 ##  EFD_SEMAPHORE **NOT** specified. A new flag EFD_SUPPORT_ISR has been added.
                                 ##  This flag is required to write to event fds in interrupt handlers. Accessing
                                 ##  the control blocks of event fds with EFD_SUPPORT_ISR will cause interrupts to
                                 ##  be temporarily blocked (e.g. during read, write and beginning and ending of
                                 ##  the * select).
                                 ##
                                 ##  @return The file descriptor if successful, -1 if error happens.
                                 ## 