##  Copyright 2015-2018 Espressif Systems (Shanghai) PTE LTD
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


## * System event types enumeration
import ../consts
import net/esp_wifi_types
import net/tcpip_adapter

type
  system_event_id_t* {.size: sizeof(cint).} = enum
    SYSTEM_EVENT_WIFI_READY = 0, ## !< ESP32 WiFi ready
    SYSTEM_EVENT_SCAN_DONE,   ## !< ESP32 finish scanning AP
    SYSTEM_EVENT_STA_START,   ## !< ESP32 station start
    SYSTEM_EVENT_STA_STOP,    ## !< ESP32 station stop
    SYSTEM_EVENT_STA_CONNECTED, ## !< ESP32 station connected to AP
    SYSTEM_EVENT_STA_DISCONNECTED, ## !< ESP32 station disconnected from AP
    SYSTEM_EVENT_STA_AUTHMODE_CHANGE, ## !< the auth mode of AP connected by ESP32 station changed
    SYSTEM_EVENT_STA_GOT_IP,  ## !< ESP32 station got IP from connected AP
    SYSTEM_EVENT_STA_LOST_IP, ## !< ESP32 station lost IP and the IP is reset to 0
    SYSTEM_EVENT_STA_WPS_ER_SUCCESS, ## !< ESP32 station wps succeeds in enrollee mode
    SYSTEM_EVENT_STA_WPS_ER_FAILED, ## !< ESP32 station wps fails in enrollee mode
    SYSTEM_EVENT_STA_WPS_ER_TIMEOUT, ## !< ESP32 station wps timeout in enrollee mode
    SYSTEM_EVENT_STA_WPS_ER_PIN, ## !< ESP32 station wps pin code in enrollee mode
    SYSTEM_EVENT_STA_WPS_ER_PBC_OVERLAP, ## !< ESP32 station wps overlap in enrollee mode
    SYSTEM_EVENT_AP_START,    ## !< ESP32 soft-AP start
    SYSTEM_EVENT_AP_STOP,     ## !< ESP32 soft-AP stop
    SYSTEM_EVENT_AP_STACONNECTED, ## !< a station connected to ESP32 soft-AP
    SYSTEM_EVENT_AP_STADISCONNECTED, ## !< a station disconnected from ESP32 soft-AP
    SYSTEM_EVENT_AP_STAIPASSIGNED, ## !< ESP32 soft-AP assign an IP to a connected station
    SYSTEM_EVENT_AP_PROBEREQRECVED, ## !< Receive probe request packet in soft-AP interface
    SYSTEM_EVENT_GOT_IP6,     ## !< ESP32 station or ap or ethernet interface v6IP addr is preferred
    SYSTEM_EVENT_ETH_START,   ## !< ESP32 ethernet start
    SYSTEM_EVENT_ETH_STOP,    ## !< ESP32 ethernet stop
    SYSTEM_EVENT_ETH_CONNECTED, ## !< ESP32 ethernet phy link up
    SYSTEM_EVENT_ETH_DISCONNECTED, ## !< ESP32 ethernet phy link down
    SYSTEM_EVENT_ETH_GOT_IP,  ## !< ESP32 ethernet got IP from connected AP
    SYSTEM_EVENT_MAX          ## !< Number of members in this enum


##  add this macro define for compatible with old IDF version

when not defined(SYSTEM_EVENT_AP_STA_GOT_IP6):
  const
    SYSTEM_EVENT_AP_STA_GOT_IP6* = SYSTEM_EVENT_GOT_IP6
## * Argument structure of SYSTEM_EVENT_STA_WPS_ER_FAILED event

type
  system_event_sta_wps_fail_reason_t* = wifi_event_sta_wps_fail_reason_t

## * Argument structure of SYSTEM_EVENT_SCAN_DONE event

type
  system_event_sta_scan_done_t* = wifi_event_sta_scan_done_t

## * Argument structure of SYSTEM_EVENT_STA_CONNECTED event

type
  system_event_sta_connected_t* = wifi_event_sta_connected_t

## * Argument structure of SYSTEM_EVENT_STA_DISCONNECTED event

type
  system_event_sta_disconnected_t* = wifi_event_sta_disconnected_t

## * Argument structure of SYSTEM_EVENT_STA_AUTHMODE_CHANGE event

type
  system_event_sta_authmode_change_t* = wifi_event_sta_authmode_change_t

## * Argument structure of SYSTEM_EVENT_STA_WPS_ER_PIN event

type
  system_event_sta_wps_er_pin_t* = wifi_event_sta_wps_er_pin_t

## * Argument structure of  event

type
  system_event_ap_staconnected_t* = wifi_event_ap_staconnected_t

## * Argument structure of  event

type
  system_event_ap_stadisconnected_t* = wifi_event_ap_stadisconnected_t

## * Argument structure of  event

type
  system_event_ap_probe_req_rx_t* = wifi_event_ap_probe_req_rx_t

## * Argument structure of  event

type
  system_event_ap_staipassigned_t* = ip_event_ap_staipassigned_t

## * Argument structure of  event

type
  system_event_sta_got_ip_t* = ip_event_got_ip_t

## * Argument structure of  event

type
  system_event_got_ip6_t* = ip_event_got_ip6_t

## * Union of all possible system_event argument structures

type
  system_event_info_t* {.importc: "system_event_info_t",
                        header: "esp_event_legacy.h", bycopy.} = object {.union.}
    connected* {.importc: "connected".}: system_event_sta_connected_t ## !< ESP32 station connected to AP
    disconnected* {.importc: "disconnected".}: system_event_sta_disconnected_t ## !< ESP32 station disconnected to AP
    scan_done* {.importc: "scan_done".}: system_event_sta_scan_done_t ## !< ESP32 station scan (APs) done
    auth_change* {.importc: "auth_change".}: system_event_sta_authmode_change_t ## !< the auth mode of AP ESP32 station connected to changed
    got_ip* {.importc: "got_ip".}: system_event_sta_got_ip_t ## !< ESP32 station got IP, first time got IP or when IP is changed
    sta_er_pin* {.importc: "sta_er_pin".}: system_event_sta_wps_er_pin_t ## !< ESP32 station WPS enrollee mode PIN code received
    sta_er_fail_reason* {.importc: "sta_er_fail_reason".}: system_event_sta_wps_fail_reason_t ## !< ESP32 station WPS enrollee mode failed reason code received
    sta_connected* {.importc: "sta_connected".}: system_event_ap_staconnected_t ## !< a station connected to ESP32 soft-AP
    sta_disconnected* {.importc: "sta_disconnected".}: system_event_ap_stadisconnected_t ## !< a station disconnected to ESP32 soft-AP
    ap_probereqrecved* {.importc: "ap_probereqrecved".}: system_event_ap_probe_req_rx_t ## !< ESP32 soft-AP receive probe request packet
    ap_staipassigned* {.importc: "ap_staipassigned".}: system_event_ap_staipassigned_t ## *< ESP32 soft-AP assign an IP to the station
    got_ip6* {.importc: "got_ip6".}: system_event_got_ip6_t ## !< ESP32 station　or ap or ethernet ipv6 addr state change to preferred


## * Event, as a tagged enum

type
  system_event_t* {.importc: "system_event_t", header: "esp_event_legacy.h", bycopy.} = object
    event_id* {.importc: "event_id".}: system_event_id_t ## !< event ID
    event_info* {.importc: "event_info".}: system_event_info_t ## !< event information


## * Event handler function type

type
  system_event_handler_t* = proc (event: ptr system_event_t): esp_err_t

## *
##  @brief  Send a event to event task
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##  Other task/modules, such as the tcpip_adapter, can call this API to send an event to event task
##
##  @param event Event to send
##
##  @return ESP_OK : succeed
##  @return others : fail
##

proc esp_event_send*(event: ptr system_event_t): esp_err_t {.
    importc: "esp_event_send", header: "esp_event_legacy.h".}
## *
##  @brief  Default event handler for system events
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##  This function performs default handling of system events.
##  When using esp_event_loop APIs, it is called automatically before invoking the user-provided
##  callback function.
##
##  Applications which implement a custom event loop must call this function
##  as part of event processing.
##
##  @param  event   pointer to event to be handled
##  @return ESP_OK if an event was handled successfully
##

proc esp_event_process_default*(event: ptr system_event_t): esp_err_t {.
    importc: "esp_event_process_default", header: "esp_event_legacy.h".}
## *
##  @brief  Install default event handlers for Ethernet interface
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##

proc esp_event_set_default_eth_handlers*() {.
    importc: "esp_event_set_default_eth_handlers", header: "esp_event_legacy.h".}
## *
##  @brief  Install default event handlers for Wi-Fi interfaces (station and AP)
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##

proc esp_event_set_default_wifi_handlers*() {.
    importc: "esp_event_set_default_wifi_handlers", header: "esp_event_legacy.h".}
## *
##  @brief  Application specified event callback function
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##
##  @param  ctx    reserved for user
##  @param  event  event type defined in this file
##
##  @return
##     - ESP_OK: succeed
##     - others: fail
##

type
  system_event_cb_t* = proc (ctx: pointer; event: ptr system_event_t): esp_err_t

## *
##  @brief  Initialize event loop
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##  Create the event handler and task
##
##  @param  cb   application specified event callback, it can be modified by call esp_event_set_cb
##  @param  ctx  reserved for user
##
##  @return
##     - ESP_OK: succeed
##     - others: fail
##

proc esp_event_loop_init*(cb: system_event_cb_t; ctx: pointer): esp_err_t {.
    importc: "esp_event_loop_init", header: "esp_event_legacy.h".}
## *
##  @brief  Set application specified event callback function
##
##  @note This API is part of the legacy event system. New code should use event library API in esp_event.h
##
##  @attention 1. If cb is NULL, means application don't need to handle
##                If cb is not NULL, it will be call when an event is received, after the default event callback is completed
##
##  @param  cb   application callback function
##  @param  ctx  argument to be passed to callback
##
##
##  @return old callback
##

proc esp_event_loop_set_cb*(cb: system_event_cb_t; ctx: pointer): system_event_cb_t {.
    importc: "esp_event_loop_set_cb", header: "esp_event_legacy.h".}