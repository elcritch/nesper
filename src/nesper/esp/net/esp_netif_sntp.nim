##
##  SPDX-FileCopyrightText: 2022-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import std/posix
import ../../consts
import ./esp_netif_types

type

  esp_sntp_time_cb_t* = proc (tv: ptr TimeVal) {.cdecl.} ##
                              ##
                              ##  @defgroup ESP_NETIF_SNTP_API ESP-NETIF SNTP API
                              ##  @brief SNTP API for underlying TCP/IP stack
                              ##
                              ##
                              ##  @addtogroup ESP_NETIF_SNTP_API
                              ##  @{
                              ##
                              ##
                              ##  @brief Time sync notification function
                              ##

##
##  @brief Utility macro for providing multiple servers in parentheses
##

##
##  @brief Default configuration to init SNTP with multiple servers
##  @param servers_in_list Number of servers in the list
##  @param list_of_servers List of servers (use ESP_SNTP_SERVER_LIST(...))
##
##

##
##  @brief Default configuration with a single server
##

type

  esp_sntp_config_t* {.importc: "esp_sntp_config_t", header: "esp_netif_sntp.h",
                       bycopy.} = object ##
                                          ##  @brief SNTP configuration struct
                                          ##
    smooth_sync* {.importc: "smooth_sync".}: bool ## < set to true if smooth sync required
    server_from_dhcp* {.importc: "server_from_dhcp".}: bool ##
                              ## < set to true to request NTP server config from DHCP
    wait_for_sync* {.importc: "wait_for_sync".}: bool ##
                              ## < if true, we create a semaphore to signal time sync event
    start* {.importc: "start".}: bool ## < set to true to automatically start the SNTP service
    sync_cb* {.importc: "sync_cb".}: esp_sntp_time_cb_t ##
                              ## < optionally sets callback function on time sync event
    renew_servers_after_new_IP* {.importc: "renew_servers_after_new_IP".}: bool ##
                              ## < this is used to refresh server list if NTP provided by DHCP (which cleans other pre-configured servers)
    ip_event_to_renew* {.importc: "ip_event_to_renew".}: ip_event_t ##
                              ## < set the IP event id on which we refresh server list (if renew_servers_after_new_IP=true)
    index_of_first_server* {.importc: "index_of_first_server".}: csize_t ##
                              ## < refresh server list after this server (if renew_servers_after_new_IP=true)
    num_of_servers* {.importc: "num_of_servers".}: csize_t ##
                              ## < number of preconfigured NTP servers
    servers* {.importc: "servers".}: UncheckedArray[cstring]
    ## < list of servers


proc esp_netif_sntp_init*(config: ptr esp_sntp_config_t): esp_err_t {.cdecl,
    importc: "esp_netif_sntp_init", header: "esp_netif_sntp.h".}
  ##
                              ##
                              ##  @brief Initialize SNTP with supplied config struct
                              ##  @param config Config struct
                              ##  @return ESP_OK on success
                              ##

proc esp_netif_sntp_start*(): esp_err_t {.cdecl,
    importc: "esp_netif_sntp_start", header: "esp_netif_sntp.h".}
  ##
                              ##
                              ##  @brief Start SNTP service
                              ##           if it wasn't started during init (config.start = false)
                              ##           or restart it if already started
                              ##  @return ESP_OK on success
                              ##

proc esp_netif_sntp_deinit*() {.cdecl, importc: "esp_netif_sntp_deinit",
                                header: "esp_netif_sntp.h".}
  ##
                              ##
                              ##  @brief Deinitialize esp_netif SNTP module
                              ##

proc esp_netif_sntp_sync_wait*(tout: TickType_t): esp_err_t {.cdecl,
    importc: "esp_netif_sntp_sync_wait", header: "esp_netif_sntp.h".}
  ##
                              ##
                              ##  @brief Wait for time sync event
                              ##  @param tout Specified timeout in RTOS ticks
                              ##  @return ESP_TIMEOUT if sync event didn't came within the timeout
                              ##          ESP_ERR_NOT_FINISHED if the sync event came, but we're in smooth update mode and still in progress (SNTP_SYNC_STATUS_IN_PROGRESS)
                              ##          ESP_OK if time sync'ed
                              ##

proc esp_netif_sntp_reachability*(index: cuint; reachability: ptr cuint): esp_err_t {.
    cdecl, importc: "esp_netif_sntp_reachability", header: "esp_netif_sntp.h".}
  ##
                              ##
                              ##  @brief Returns SNTP server's reachability shift register as described in RFC 5905.
                              ##
                              ##  @param index Index of the SERVER
                              ##  @param reachability reachability shift register
                              ##  @return ESP_OK on success,
                              ##          ESP_ERR_INVALID_STATE if SNTP not initialized
                              ##          ESP_ERR_INVALID_ARG if invalid arguments
                              ##
##
##  @}
##
