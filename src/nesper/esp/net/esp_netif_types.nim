##
##  SPDX-FileCopyrightText: 2015-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../../consts

import esp_netif_ip_addr

const hdr = "esp_netif_types.h"

const
  ESP_ERR_ESP_NETIF_BASE* = 0x5000 ##
                                   ##  @brief Definition of ESP-NETIF based errors
                                   ##
  ESP_ERR_ESP_NETIF_INVALID_PARAMS* = ESP_ERR_ESP_NETIF_BASE + 0x01
  ESP_ERR_ESP_NETIF_IF_NOT_READY* = ESP_ERR_ESP_NETIF_BASE + 0x02
  ESP_ERR_ESP_NETIF_DHCPC_START_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x03
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STARTED* = ESP_ERR_ESP_NETIF_BASE + 0x04
  ESP_ERR_ESP_NETIF_DHCP_ALREADY_STOPPED* = ESP_ERR_ESP_NETIF_BASE + 0x05
  ESP_ERR_ESP_NETIF_NO_MEM* = ESP_ERR_ESP_NETIF_BASE + 0x06
  ESP_ERR_ESP_NETIF_DHCP_NOT_STOPPED* = ESP_ERR_ESP_NETIF_BASE + 0x07
  ESP_ERR_ESP_NETIF_DRIVER_ATTACH_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x08
  ESP_ERR_ESP_NETIF_INIT_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x09
  ESP_ERR_ESP_NETIF_DNS_NOT_CONFIGURED* = ESP_ERR_ESP_NETIF_BASE + 0x0A
  ESP_ERR_ESP_NETIF_MLD6_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x0B
  ESP_ERR_ESP_NETIF_IP6_ADDR_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x0C
  ESP_ERR_ESP_NETIF_DHCPS_START_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x0D
  ESP_ERR_ESP_NETIF_TX_FAILED* = ESP_ERR_ESP_NETIF_BASE + 0x0E
  ESP_NETIF_BR_FLOOD* = -1   ##
                             ##  @brief Definition of ESP-NETIF bridge control
                             ##
  ESP_NETIF_BR_DROP* = 0
  ESP_NETIF_BR_FDW_CPU* = (1'u64 shl 63)

##  @brief Type of esp_netif_object server

type

  esp_netif_t* {.importc: "esp_netif_t", header: hdr, bycopy.} = object

  esp_netif_dns_type_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief Type of DNS server
    ESP_NETIF_DNS_MAIN = 0, ## < DNS main server address
    ESP_NETIF_DNS_BACKUP,   ## < DNS backup server address (Wi-Fi STA and Ethernet only)
    ESP_NETIF_DNS_FALLBACK, ## < DNS fallback server address (Wi-Fi STA and Ethernet only)
    ESP_NETIF_DNS_MAX


type

  esp_netif_dns_info_t* {.importc: "esp_netif_dns_info_t",
                          header: hdr, bycopy.} = object ##
                              ##  @brief DNS server info
    ip* {.importc: "ip".}: esp_ip_addr_t
    ## < IPV4 address of DNS server


  esp_netif_dhcp_status_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief Status of DHCP client or DHCP server
    ESP_NETIF_DHCP_INIT = 0, ## < DHCP client/server is in initial state (not yet started)
    ESP_NETIF_DHCP_STARTED, ## < DHCP client/server has been started
    ESP_NETIF_DHCP_STOPPED, ## < DHCP client/server has been stopped
    ESP_NETIF_DHCP_STATUS_MAX


type

  esp_netif_dhcp_option_mode_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief Mode for DHCP client or DHCP server option functions
    ESP_NETIF_OP_START = 0, ESP_NETIF_OP_SET, ## < Set option
    ESP_NETIF_OP_GET,       ## < Get option
    ESP_NETIF_OP_MAX


type

  esp_netif_dhcp_option_id_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief Supported options for DHCP client or DHCP server
    ESP_NETIF_SUBNET_MASK = 1, ## < Network mask
    ESP_NETIF_DOMAIN_NAME_SERVER = 6, ## < Domain name server
    ESP_NETIF_ROUTER_SOLICITATION_ADDRESS = 32, ## < Solicitation router address
    ESP_NETIF_VENDOR_SPECIFIC_INFO = 43, ## < Vendor Specific Information of a DHCP server
    ESP_NETIF_REQUESTED_IP_ADDRESS = 50, ## < Request specific IP address
    ESP_NETIF_IP_ADDRESS_LEASE_TIME = 51, ## < Request IP address lease time
    ESP_NETIF_IP_REQUEST_RETRY_TIME = 52, ## < Request IP address retry counter
    ESP_NETIF_VENDOR_CLASS_IDENTIFIER = 60, ## < Vendor Class Identifier of a DHCP client
    ESP_NETIF_CAPTIVEPORTAL_URI = 114 ## < Captive Portal Identification


type

  ip_event_t* {.size: sizeof(cint).} = enum ##  IP event declarations
    IP_EVENT_STA_GOT_IP,    ## !< station got IP from connected AP
    IP_EVENT_STA_LOST_IP,   ## !< station lost IP and the IP is reset to 0
    IP_EVENT_AP_STAIPASSIGNED, ## !< soft-AP assign an IP to a connected station
    IP_EVENT_GOT_IP6,       ## !< station or ap or ethernet interface v6IP addr is preferred
    IP_EVENT_ETH_GOT_IP,    ## !< ethernet got IP from connected AP
    IP_EVENT_ETH_LOST_IP,   ## !< ethernet lost IP and the IP is reset to 0
    IP_EVENT_PPP_GOT_IP,    ## !< PPP interface got IP
    IP_EVENT_PPP_LOST_IP,   ## !< PPP interface lost IP
    IP_EVENT_TX_RX           ## !< transmitting/receiving data packet


##  @brief IP event base declaration

# ESP_EVENT_DECLARE_BASE(IP_EVENT)

type

  esp_netif_ip_info_t* {.importc: "esp_netif_ip_info_t",
                         header: hdr, bycopy.} = object ##
                              ##  Event structure for IP_EVENT_STA_GOT_IP, IP_EVENT_ETH_GOT_IP events
    ip* {.importc: "ip".}: esp_ip4_addr_t ## < Interface IPV4 address
    netmask* {.importc: "netmask".}: esp_ip4_addr_t ##
                              ## < Interface IPV4 netmask
    gw* {.importc: "gw".}: esp_ip4_addr_t
    ## < Interface IPV4 gateway address


  esp_netif_ip6_info_t* {.importc: "esp_netif_ip6_info_t",
                          header: hdr, bycopy.} = object ##
                              ##  @brief IPV6 IP address information
                              ##
    ip* {.importc: "ip".}: esp_ip6_addr_t
    ## < Interface IPV6 address


  ip_event_got_ip_t* {.importc: "ip_event_got_ip_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Event structure for IP_EVENT_GOT_IP event
                              ##
                              ##
    esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ##
                              ## !< Pointer to corresponding esp-netif object
    ip_info* {.importc: "ip_info".}: esp_netif_ip_info_t ##
                              ## !< IP address, netmask, gateway IP address
    ip_changed* {.importc: "ip_changed".}: bool
    ## !< Whether the assigned IP has changed or not


  ip_event_got_ip6_t* {.importc: "ip_event_got_ip6_t",
                        header: hdr, bycopy.} = object ##
                              ##  Event structure for IP_EVENT_GOT_IP6 event
    esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ##
                              ## !< Pointer to corresponding esp-netif object
    ip6_info* {.importc: "ip6_info".}: esp_netif_ip6_info_t ##
                              ## !< IPv6 address of the interface
    ip_index* {.importc: "ip_index".}: cint
    ## !< IPv6 address index


  ip_event_add_ip6_t* {.importc: "ip_event_add_ip6_t",
                        header: hdr, bycopy.} = object ##
                              ##  Event structure for ADD_IP6 event
    `addr`* {.importc: "addr".}: esp_ip6_addr_t ## !< The address to be added to the interface
    preferred* {.importc: "preferred".}: bool
    ## !< The default preference of the address


  ip_event_ap_staipassigned_t* {.importc: "ip_event_ap_staipassigned_t",
                                 header: hdr, bycopy.} = object ##
                              ##  Event structure for IP_EVENT_AP_STAIPASSIGNED event
    esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ##
                              ## !< Pointer to the associated netif handle
    ip* {.importc: "ip".}: esp_ip4_addr_t ## !< IP address which was assigned to the station
    mac* {.importc: "mac".}: array[6, uint8]
    ## !< MAC address of the connected client


  esp_netif_tx_rx_direction_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_TX = 0,       ##  Data is being transmitted.
    ESP_NETIF_RX = 1         ##  Data is being received.


when defined(CONFIG_ESP_NETIF_REPORT_DATA_TRAFFIC):
  ##  Event structure for IP_EVENT_TRANSMIT and IP_EVENT_RECEIVE
  type

    ip_event_tx_rx_t* {.importc: "ip_event_tx_rx_t",
                        header: hdr, bycopy.} = object
      esp_netif* {.importc: "esp_netif".}: ptr esp_netif_t ##
                              ## !< Pointer to the associated netif handle
      len* {.importc: "len".}: csize_t ## !< Length of the data
      dir* {.importc: "dir".}: esp_netif_tx_rx_direction_t
      ## !< Directions for data transfer >

type

  esp_netif_flags_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_DHCP_CLIENT = 1 shl 0, ESP_NETIF_DHCP_SERVER = 1 shl 1,
    ESP_NETIF_FLAG_AUTOUP = 1 shl 2, ESP_NETIF_FLAG_GARP = 1 shl 3,
    ESP_NETIF_FLAG_EVENT_IP_MODIFIED = 1 shl 4, ESP_NETIF_FLAG_IS_PPP = 1 shl 5,
    ESP_NETIF_FLAG_IS_BRIDGE = 1 shl 6, ESP_NETIF_FLAG_MLDV6_REPORT = 1 shl 7,
    ESP_NETIF_FLAG_IPV6_AUTOCONFIG_ENABLED = 1 shl 8

  esp_netif_ip_event_type_t* {.size: sizeof(cint).} = enum
    ESP_NETIF_IP_EVENT_GOT_IP = 1, ESP_NETIF_IP_EVENT_LOST_IP = 2


type

  bridgeif_config_t* {.importc: "bridgeif_config_t",
                       header: hdr, bycopy.} = object ##
                              ##  LwIP bridge configuration
    max_fdb_dyn_entries* {.importc: "max_fdb_dyn_entries".}: uint16 ##
                              ## !< maximum number of entries in dynamic forwarding database
    max_fdb_sta_entries* {.importc: "max_fdb_sta_entries".}: uint16 ##
                              ## !< maximum number of entries in static forwarding database
    max_ports* {.importc: "max_ports".}: uint8
    ## !< maximum number of ports the bridge can consist of


  esp_netif_inherent_config_t* {.importc: "esp_netif_inherent_config_t",
                                 header: hdr, bycopy.} = object ##
                              ##
                              ##     ESP-NETIF interface configuration:
                              ##       1) general (behavioral) config (esp_netif_config_t)
                              ##       2) (peripheral) driver specific config (esp_netif_driver_ifconfig_t)
                              ##       3) network stack specific config (esp_netif_net_stack_ifconfig_t) -- no publicly available
                              ##
                              ##
                              ##  @brief ESP-netif inherent config parameters
                              ##
                              ##
    flags* {.importc: "flags".}: esp_netif_flags_t ##
                              ## !< flags that define esp-netif behavior
    mac* {.importc: "mac".}: array[6, uint8] ## !< initial mac address for this interface
    ip_info* {.importc: "ip_info".}: ptr esp_netif_ip_info_t ##
                              ## !< initial ip address for this interface
    get_ip_event* {.importc: "get_ip_event".}: uint32 ##
                              ## !< event id to be raised when interface gets an IP
    lost_ip_event* {.importc: "lost_ip_event".}: uint32 ##
                              ## !< event id to be raised when interface losts its IP
    if_key* {.importc: "if_key".}: cstring ## !< string identifier of the interface
    if_desc* {.importc: "if_desc".}: cstring ## !< textual description of the interface
    route_prio* {.importc: "route_prio".}: cint ## !< numeric priority of this interface to become a default
                                                ##                                           routing if (if other netifs are up).
                                                ##                                           A higher value of route_prio indicates
                                                ##                                           a higher priority
    bridge_info* {.importc: "bridge_info".}: ptr bridgeif_config_t
    ## !< LwIP bridge configuration


  esp_netif_config_t* = esp_netif_config

  esp_netif_iodriver_handle* = pointer ##
                                       ##  @brief  IO driver handle type
                                       ##

  esp_netif_driver_base_t* {.importc: "esp_netif_driver_base_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief ESP-netif driver base handle
                              ##
                              ##
    post_attach* {.importc: "post_attach".}: proc (netif: ptr esp_netif_t;
        h: esp_netif_iodriver_handle): esp_err_t {.cdecl.} ##
                              ## !< post attach function pointer
    netif* {.importc: "netif".}: ptr esp_netif_t
    ## !< netif handle


  esp_netif_driver_ifconfig* {.importc: "esp_netif_driver_ifconfig",
                               header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief  Specific IO driver configuration
                              ##
    handle* {.importc: "handle".}: esp_netif_iodriver_handle ##
                              ## !< io-driver handle
    transmit* {.importc: "transmit".}: proc (h: pointer; buffer: pointer;
        len: csize_t): esp_err_t {.cdecl.} ## !< transmit function pointer
    transmit_wrap* {.importc: "transmit_wrap".}: proc (h: pointer;
        buffer: pointer; len: csize_t; netstack_buffer: pointer): esp_err_t {.
        cdecl.}              ## !< transmit wrap function pointer
    driver_free_rx_buffer* {.importc: "driver_free_rx_buffer".}: proc (
        h: pointer; buffer: pointer) {.cdecl.} ## !< free rx buffer function pointer
    driver_set_mac_filter* {.importc: "driver_set_mac_filter".}: proc (
        h: pointer; mac: ptr uint8; mac_len: csize_t; add: bool): esp_err_t {.
        cdecl.}
    ## !< set mac filter function pointer


  esp_netif_driver_ifconfig_t* = esp_netif_driver_ifconfig

  esp_netif_netstack_config_t* = esp_netif_netstack_config ##
                              ##
                              ##  @brief  Specific L3 network stack configuration
                              ##

  esp_netif_config* {.importc: "esp_netif_config", header: hdr,
                      bycopy.} = object ##
                                         ##  @brief  Generic esp_netif configuration
                                         ##
    base* {.importc: "base".}: ptr esp_netif_inherent_config_t ##
                              ## !< base config
    driver* {.importc: "driver".}: ptr esp_netif_driver_ifconfig_t ##
                              ## !< driver config
    stack* {.importc: "stack".}: ptr esp_netif_netstack_config_t
    ## !< stack config


  esp_netif_pair_mac_ip_t* {.importc: "esp_netif_pair_mac_ip_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief DHCP client's addr info (pair of MAC and IP address)
                              ##
    mac* {.importc: "mac".}: array[6, uint8] ## < Clients MAC address
    ip* {.importc: "ip".}: esp_ip4_addr_t
    ## < Clients IP address


  esp_netif_receive_t* = proc (esp_netif: ptr esp_netif_t; buffer: pointer;
                               len: csize_t; eb: pointer): esp_err_t {.cdecl.} ##
                              ##
                              ##  @brief  ESP-NETIF Receive function type
                              ##
