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

import
  lwip/ip_addr, dhcpserver/dhcpserver, esp_netif_sta_list

##
##  Define compatible types if tcpip_adapter interface used
##

const
  TCPIP_ADAPTER_DHCP_STARTED* = ESP_NETIF_DHCP_STARTED
  TCPIP_ADAPTER_DHCP_STOPPED* = ESP_NETIF_DHCP_STOPPED
  TCPIP_ADAPTER_DHCP_INIT* = ESP_NETIF_DHCP_INIT
  TCPIP_ADAPTER_OP_SET* = ESP_NETIF_OP_SET
  TCPIP_ADAPTER_OP_GET* = ESP_NETIF_OP_GET
  TCPIP_ADAPTER_DOMAIN_NAME_SERVER* = ESP_NETIF_DOMAIN_NAME_SERVER
  TCPIP_ADAPTER_ROUTER_SOLICITATION_ADDRESS* = ESP_NETIF_ROUTER_SOLICITATION_ADDRESS
  TCPIP_ADAPTER_REQUESTED_IP_ADDRESS* = ESP_NETIF_REQUESTED_IP_ADDRESS
  TCPIP_ADAPTER_IP_ADDRESS_LEASE_TIME* = ESP_NETIF_IP_ADDRESS_LEASE_TIME
  TCPIP_ADAPTER_IP_REQUEST_RETRY_TIME* = ESP_NETIF_IP_REQUEST_RETRY_TIME

## * @brief Legacy error code definitions
##
##

const
  ESP_ERR_TCPIP_ADAPTER_INVALID_PARAMS* = ESP_ERR_ESP_NETIF_INVALID_PARAMS
  ESP_ERR_TCPIP_ADAPTER_IF_NOT_READY* = ESP_ERR_ESP_NETIF_IF_NOT_READY
  ESP_ERR_TCPIP_ADAPTER_DHCPC_START_FAILED* = ESP_ERR_ESP_NETIF_DHCPC_START_FAILED
  ESP_ERR_TCPIP_ADAPTER_DHCP_ALREADY_STARTED* = ESP_ERR_ESP_NETIF_DHCP_ALREADY_STARTED
  ESP_ERR_TCPIP_ADAPTER_DHCP_ALREADY_STOPPED* = ESP_ERR_ESP_NETIF_DHCP_ALREADY_STOPPED
  ESP_ERR_TCPIP_ADAPTER_NO_MEM* = ESP_ERR_ESP_NETIF_NO_MEM
  ESP_ERR_TCPIP_ADAPTER_DHCP_NOT_STOPPED* = ESP_ERR_ESP_NETIF_DHCP_NOT_STOPPED

type
  tcpip_adapter_if_t* {.size: sizeof(cint).} = enum
    TCPIP_ADAPTER_IF_STA = 0,   ## *< Wi-Fi STA (station) interface
    TCPIP_ADAPTER_IF_AP,      ## *< Wi-Fi soft-AP interface
    TCPIP_ADAPTER_IF_ETH,     ## *< Ethernet interface
    TCPIP_ADAPTER_IF_TEST,    ## *< tcpip stack test interface
    TCPIP_ADAPTER_IF_MAX


## * @brief legacy ip_info type
##

type
  tcpip_adapter_ip_info_t* {.importc: "tcpip_adapter_ip_info_t",
                            header: "tcpip_adapter_types.h", bycopy.} = object
    ip* {.importc: "ip".}: ip4_addr_t ## *< Interface IPV4 address
    netmask* {.importc: "netmask".}: ip4_addr_t ## *< Interface IPV4 netmask
    gw* {.importc: "gw".}: ip4_addr_t ## *< Interface IPV4 gateway address


## * @brief legacy typedefs
##

type
  tcpip_adapter_dhcp_status_t* = esp_netif_dhcp_status_t
  tcpip_adapter_dhcps_lease_t* = dhcps_lease_t
  tcpip_adapter_dhcp_option_mode_t* = esp_netif_dhcp_option_mode_t
  tcpip_adapter_dhcp_option_id_t* = esp_netif_dhcp_option_id_t
  tcpip_adapter_dns_type_t* = esp_netif_dns_type_t
  tcpip_adapter_dns_info_t* = esp_netif_dns_info_t
  tcpip_adapter_sta_list_t* = esp_netif_sta_list_t
  tcpip_adapter_sta_info_t* = esp_netif_sta_info_t
