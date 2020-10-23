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

## *
##  @brief Definition of ESP-NETIF based errors
##

import ../../consts
import esp_netif_ip_addr

const
  ESP_ERR_ESP_NETIF_BASE* = 0x00005000
  ESP_ERR_ESP_NETIF_INVALID_PARAMS* = ESP_ERR_ESP_NETIF_BASE + 0x00000001
  ESP_ERR_ESP_NETIF_IF_NOT_READY* = ESP_ERR_ESP_NETIF_BASE + 0x00000002
  ESP_ERR_ESP_NETIF_DHCPC_START_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x00000003
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STARTED* = ESP_ERR_ESP_NETIF_BASE + 0x00000004
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STOPPED* = ESP_ERR_ESP_NETIF_BASE + 0x00000005
  ESP_ERR_ESP_NETIF_NO_MEM* = ESP_ERR_ESP_NETIF_BASE + 0x00000006
  ESP_ERR_ESP_NETIF_DHCP_NOT_STOPPED* = ESP_ERR_ESP_NETIF_BASE + 0x00000007
  ESP_ERR_ESP_NETIF_DRIVER_ATTACH_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x00000008
  ESP_ERR_ESP_NETIF_INIT_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x00000009
  ESP_ERR_ESP_NETIF_DNS_NOT_CONFIGURED* = ESP_ERR_ESP_NETIF_BASE + 0x0000000A

## * @brief Type of esp_netif_object server

type
  esp_netif_obj* {.importc: "esp_netif_obj", header: "esp_netif_types.h", bycopy.} = object

  esp_netif_t* = esp_netif_obj

## * @brief Type of DNS server

type
  esp_netif_dns_type_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_DNS_MAIN = 0,     ## *< DNS main server address
    ESP_NETIF_DNS_BACKUP,     ## *< DNS backup server address (Wi-Fi STA and Ethernet only)
    ESP_NETIF_DNS_FALLBACK,   ## *< DNS fallback server address (Wi-Fi STA and Ethernet only)
    ESP_NETIF_DNS_MAX


## * @brief DNS server info

type
  esp_netif_dns_info_t* {.importc: "esp_netif_dns_info_t",
                         header: "esp_netif_types.h", bycopy.} = object
    ip* {.importc: "ip".}: esp_ip_addr_t ## *< IPV4 address of DNS server


## * @brief Status of DHCP client or DHCP server

type
  esp_netif_dhcp_status_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_DHCP_INIT = 0,    ## *< DHCP client/server is in initial state (not yet started)
    ESP_NETIF_DHCP_STARTED,   ## *< DHCP client/server has been started
    ESP_NETIF_DHCP_STOPPED,   ## *< DHCP client/server has been stopped
    ESP_NETIF_DHCP_STATUS_MAX


## * @brief Mode for DHCP client or DHCP server option functions

type
  esp_netif_dhcp_option_mode_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_OP_START = 0, ESP_NETIF_OP_SET, ## *< Set option
    ESP_NETIF_OP_GET,         ## *< Get option
    ESP_NETIF_OP_MAX


## * @brief Supported options for DHCP client or DHCP server

type
  esp_netif_dhcp_option_id_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_DOMAIN_NAME_SERVER = 6, ## *< Domain name server
    ESP_NETIF_ROUTER_SOLICITATION_ADDRESS = 32, ## *< Solicitation router address
    ESP_NETIF_REQUESTED_IP_ADDRESS = 50, ## *< Request specific IP address
    ESP_NETIF_IP_ADDRESS_LEASE_TIME = 51, ## *< Request IP address lease time
    ESP_NETIF_IP_REQUEST_RETRY_TIME = 52 ## *< Request IP address retry counter


## * IP event declarations

type
  ip_event_t* {.size: sizeof(cint).} = enum
    IP_EVENT_STA_GOT_IP,      ## !< station got IP from connected AP
    IP_EVENT_STA_LOST_IP,     ## !< station lost IP and the IP is reset to 0
    IP_EVENT_AP_STAIPASSIGNED, ## !< soft-AP assign an IP to a connected station
    IP_EVENT_GOT_IP6,         ## !< station or ap or ethernet interface v6IP addr is preferred
    IP_EVENT_ETH_GOT_IP,      ## !< ethernet got IP from connected AP
    IP_EVENT_PPP_GOT_IP,      ## !< PPP interface got IP
    IP_EVENT_PPP_LOST_IP      ## !< PPP interface lost IP


## * @brief IP event base declaration

# ESP_EVENT_DECLARE_BASE(IP_EVENT)
var IP_EVENT* {.importc: "$1", header: "esp_netif_types.h".}: esp_event_base_t 

## * Event structure for IP_EVENT_STA_GOT_IP, IP_EVENT_ETH_GOT_IP events

type
  esp_netif_ip_info_t* {.importc: "esp_netif_ip_info_t",
                        header: "esp_netif_types.h", bycopy.} = object
    ip* {.importc: "ip".}: esp_ip4_addr_t ## *< Interface IPV4 address
    netmask* {.importc: "netmask".}: esp_ip4_addr_t ## *< Interface IPV4 netmask
    gw* {.importc: "gw".}: esp_ip4_addr_t ## *< Interface IPV4 gateway address


## * @brief IPV6 IP address information
##

type
  esp_netif_ip6_info_t* {.importc: "esp_netif_ip6_info_t",
                         header: "esp_netif_types.h", bycopy.} = object
    ip* {.importc: "ip".}: esp_ip6_addr_t ## *< Interface IPV6 address

  ip_event_got_ip_t* {.importc: "ip_event_got_ip_t", header: "esp_netif_types.h",
                      bycopy.} = object
    if_index* {.importc: "if_index".}: cint ## !< Interface index for which the event is received (left for legacy compilation)
    esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ## !< Pointer to corresponding esp-netif object
    ip_info* {.importc: "ip_info".}: esp_netif_ip_info_t ## !< IP address, netmask, gatway IP address
    ip_changed* {.importc: "ip_changed".}: bool ## !< Whether the assigned IP has changed or not


## * Event structure for IP_EVENT_GOT_IP6 event

type
  ip_event_got_ip6_t* {.importc: "ip_event_got_ip6_t", header: "esp_netif_types.h",
                       bycopy.} = object
    if_index* {.importc: "if_index".}: cint ## !< Interface index for which the event is received (left for legacy compilation)
    esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ## !< Pointer to corresponding esp-netif object
    ip6_info* {.importc: "ip6_info".}: esp_netif_ip6_info_t ## !< IPv6 address of the interface


## * Event structure for IP_EVENT_AP_STAIPASSIGNED event

type
  ip_event_ap_staipassigned_t* {.importc: "ip_event_ap_staipassigned_t",
                                header: "esp_netif_types.h", bycopy.} = object
    ip* {.importc: "ip".}: esp_ip4_addr_t ## !< IP address which was assigned to the station

  esp_netif_flags_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_DHCP_CLIENT = 1 shl 0, ESP_NETIF_DHCP_SERVER = 1 shl 1,
    ESP_NETIF_FLAG_AUTOUP = 1 shl 2, ESP_NETIF_FLAG_GARP = 1 shl 3,
    ESP_NETIF_FLAG_EVENT_IP_MODIFIED = 1 shl 4, ESP_NETIF_FLAG_IS_PPP = 1 shl 5
  esp_netif_ip_event_type_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_IP_EVENT_GOT_IP = 1, ESP_NETIF_IP_EVENT_LOST_IP = 2



##
##     ESP-NETIF interface configuration:
##       1) general (behavioral) config (esp_netif_config_t)
##       2) (peripheral) driver specific config (esp_netif_driver_ifconfig_t)
##       3) network stack specific config (esp_netif_net_stack_ifconfig_t) -- no publicly available
##

type
  esp_netif_inherent_config_t* {.importc: "esp_netif_inherent_config_t",
                                header: "esp_netif_types.h", bycopy.} = object
    flags* {.importc: "flags".}: esp_netif_flags_t ## !< flags that define esp-netif behavior
    mac* {.importc: "mac".}: array[6, uint8] ## !< initial mac address for this interface
    ip_info* {.importc: "ip_info".}: ptr esp_netif_ip_info_t ## !< initial ip address for this interface
    get_ip_event* {.importc: "get_ip_event".}: uint32 ## !< event id to be raised when interface gets an IP
    lost_ip_event* {.importc: "lost_ip_event".}: uint32 ## !< event id to be raised when interface losts its IP
    if_key* {.importc: "if_key".}: cstring ## !< string identifier of the interface
    if_desc* {.importc: "if_desc".}: cstring ## !< textual description of the interface
    route_prio* {.importc: "route_prio".}: cint ## !< numeric priority of this interface to become a default
                                            ##                                           routing if (if other netifs are up)

  ##  @brief  IO driver handle type
  esp_netif_iodriver_handle* = pointer

  esp_netif_driver_base_t* {.importc: "esp_netif_driver_base_t",
                            header: "esp_netif_types.h", bycopy.} = object
    post_attach* {.importc: "post_attach".}: proc (netif: ptr esp_netif_t;
        h: esp_netif_iodriver_handle): esp_err_t
    netif* {.importc: "netif".}: ptr esp_netif_t

  ##  @brief  Specific IO driver configuration
  esp_netif_driver_ifconfig_t* {.importc: "esp_netif_driver_ifconfig_t",
                              header: "esp_netif_types.h", bycopy.} = object
    handle* {.importc: "handle".}: esp_netif_iodriver_handle
    transmit* {.importc: "transmit".}: proc (h: pointer; buffer: pointer; len: csize_t): esp_err_t
    driver_free_rx_buffer* {.importc: "driver_free_rx_buffer".}: proc (h: pointer;
        buffer: pointer)

  ##  @brief  Generic esp_netif configuration
  esp_netif_config_t* {.importc: "esp_netif_config_t", header: "esp_netif_types.h",
                     bycopy.} = object
    base* {.importc: "base".}: ptr esp_netif_inherent_config_t
    driver* {.importc: "driver".}: ptr esp_netif_driver_ifconfig_t
    stack* {.importc: "stack".}: ptr esp_netif_netstack_config_t

  esp_netif_netstack_config_t* {.importc: "$1", header: "esp_netif_types.h", bycopy.} = object


  ##  @brief  Specific L3 network stack configuration
  # esp_netif_config_t* = esp_netif_config


type

  ##  @brief  ESP-NETIF Receive function type
  esp_netif_receive_t* = proc (esp_netif: ptr esp_netif_t; buffer: pointer;
                            len: csize_t; eb: pointer): esp_err_t
