##
##  SPDX-FileCopyrightText: 2019-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##
##

##  @brief PPP event base
import ../../consts
import esp_netif_types

type

  esp_netif_ppp_config_t* {.importc: "esp_netif_ppp_config_t",
                            header: "esp_netif_ppp.h", bycopy.} = object ##
                              ##  @brief Configuration structure for PPP network interface
                              ##
                              ##
    ppp_phase_event_enabled* {.importc: "ppp_phase_event_enabled".}: bool ##
                              ## < Enables events coming from PPP PHASE change
    ppp_error_event_enabled* {.importc: "ppp_error_event_enabled".}: bool ##
                              ## < Enables events from main PPP state machine producing errors
    when defined(CONFIG_LWIP_ENABLE_LCP_ECHO):
      ppp_lcp_echo_disabled* {.importc: "ppp_lcp_echo_disabled".}: bool ##
                                ##  #ifdef CONFIG_LWIP_ENABLE_LCP_ECHO
                                ## 
    when defined(CONFIG_LWIP_PPP_SERVER_SUPPORT):
      ppp_our_ip4_addr* {.importc: "ppp_our_ip4_addr".}: esp_ip4_addr_t ##
                                ##  #endif // CONFIG_LWIP_ENABLE_LCP_ECHO
                                ##  #ifdef CONFIG_LWIP_PPP_SERVER_SUPPORT
      ppp_their_ip4_addr* {.importc: "ppp_their_ip4_addr".}: esp_ip4_addr_t ##
                                ## < Set our preferred address, typically used when we're the PPP server
      ppp_dns1_addr* {.importc: "ppp_dns1_addr".}: esp_ip4_addr_t ##
                                ## < DNS to provide if peer asks for it, typically used when we're the PPP server
      ppp_dns2_addr* {.importc: "ppp_dns2_addr".}: esp_ip4_addr_t ##
                                ## < DNS to provide if peer asks for it, typically used when we're the PPP server
      ppp_passive* {.importc: "ppp_passive".}: bool ## < Try once to initiate connection, stay silent if it fails, typically used when we're the PPP server
    ##  #endif // CONFIG_LWIP_PPP_SERVER_SUPPORT

const
  NETIF_PP_PHASE_OFFSET* = (0x100) ##  @brief event id offset for PHASE related events
                                   ##
                                   ##  All PPP related events are produced from esp-netif under `NETIF_PPP_STATUS`, this offset defines
                                   ##  helps distinguish between error and phase events
                                   ##
  NETIF_PPP_INTERNAL_ERR_OFFSET* = (0x200) ##  @brief event id offset for internal errors
                                           ##
                                           ##

type

  esp_netif_ppp_status_event_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief event ids for different PPP related events
                              ##
                              ##
    NETIF_PPP_ERRORNONE = 0, ##  No error.
    NETIF_PPP_ERRORPARAM = 1, ##  Invalid parameter.
    NETIF_PPP_ERROROPEN = 2, ##  Unable to open PPP session.
    NETIF_PPP_ERRORDEVICE = 3, ##  Invalid I/O device for PPP.
    NETIF_PPP_ERRORALLOC = 4, ##  Unable to allocate resources.
    NETIF_PPP_ERRORUSER = 5, ##  User interrupt.
    NETIF_PPP_ERRORCONNECT = 6, ##  Connection lost.
    NETIF_PPP_ERRORAUTHFAIL = 7, ##  Failed authentication challenge.
    NETIF_PPP_ERRORPROTOCOL = 8, ##  Failed to meet protocol.
    NETIF_PPP_ERRORPEERDEAD = 9, ##  Connection timeout
    NETIF_PPP_ERRORIDLETIMEOUT = 10, ##  Idle Timeout
    NETIF_PPP_ERRORCONNECTTIME = 11, ##  Max connect time reached
    NETIF_PPP_ERRORLOOPBACK = 12, ##  Loopback detected

    NETIF_PPP_PHASE_DEAD = NETIF_PP_PHASE_OFFSET + 0,
    NETIF_PPP_PHASE_MASTER = NETIF_PP_PHASE_OFFSET + 1,
    NETIF_PPP_PHASE_HOLDOFF = NETIF_PP_PHASE_OFFSET + 2,
    NETIF_PPP_PHASE_INITIALIZE = NETIF_PP_PHASE_OFFSET + 3,
    NETIF_PPP_PHASE_SERIALCONN = NETIF_PP_PHASE_OFFSET + 4,
    NETIF_PPP_PHASE_DORMANT = NETIF_PP_PHASE_OFFSET + 5,
    NETIF_PPP_PHASE_ESTABLISH = NETIF_PP_PHASE_OFFSET + 6,
    NETIF_PPP_PHASE_AUTHENTICATE = NETIF_PP_PHASE_OFFSET + 7,
    NETIF_PPP_PHASE_CALLBACK = NETIF_PP_PHASE_OFFSET + 8,
    NETIF_PPP_PHASE_NETWORK = NETIF_PP_PHASE_OFFSET + 9,
    NETIF_PPP_PHASE_RUNNING = NETIF_PP_PHASE_OFFSET + 10,
    NETIF_PPP_PHASE_TERMINATE = NETIF_PP_PHASE_OFFSET + 11,
    NETIF_PPP_PHASE_DISCONNECT = NETIF_PP_PHASE_OFFSET + 12,

    NETIF_PPP_CONNECT_FAILED = NETIF_PPP_INTERNAL_ERR_OFFSET + 0

type

  esp_netif_auth_type_t* {.size: sizeof(cint).} = enum ##
                              ##  @brief definitions of different authorisation types
                              ##
                              ##
    NETIF_PPP_AUTHTYPE_NONE = 0x00,
    NETIF_PPP_AUTHTYPE_PAP = 0x01,
    NETIF_PPP_AUTHTYPE_CHAP = 0x02,
    NETIF_PPP_AUTHTYPE_MSCHAP = 0x04,
    NETIF_PPP_AUTHTYPE_MSCHAP_V2 = 0x08,
    NETIF_PPP_AUTHTYPE_EAP = 0x10



proc esp_netif_ppp_set_auth*(netif: ptr esp_netif_t;
                             authtype: esp_netif_auth_type_t; user: cstring;
                             passwd: cstring): esp_err_t {.cdecl,
    importc: "esp_netif_ppp_set_auth", header: "esp_netif_ppp.h".}
  ##
                              ##  @brief Sets the auth parameters for the supplied esp-netif.
                              ##
                              ##  @param[in]  esp_netif Handle to esp-netif instance
                              ##  @param[in]  authtype Authorisation type
                              ##  @param[in]  user User name
                              ##  @param[in]  passwd Password
                              ##
                              ##  @return     ESP_OK on success,
                              ##              ESP_ERR_ESP_NETIF_INVALID_PARAMS if the supplied netif is not of PPP type, or netif is null
                              ##

proc esp_netif_ppp_set_params*(netif: ptr esp_netif_t;
                               config: ptr esp_netif_ppp_config_t): esp_err_t {.
    cdecl, importc: "esp_netif_ppp_set_params", header: "esp_netif_ppp.h".}
  ##
                              ##  @brief Sets common parameters for the supplied esp-netif.
                              ##
                              ##  @param[in]  esp_netif Handle to esp-netif instance
                              ##  @param[in]  config Pointer to PPP netif configuration structure
                              ##
                              ##  @return     ESP_OK on success,
                              ##              ESP_ERR_ESP_NETIF_INVALID_PARAMS if the supplied netif is not of PPP type, or netif is null
                              ##

proc esp_netif_ppp_get_params*(netif: ptr esp_netif_t;
                               config: ptr esp_netif_ppp_config_t): esp_err_t {.
    cdecl, importc: "esp_netif_ppp_get_params", header: "esp_netif_ppp.h".}
  ##
                              ##  @brief Gets parameters configured in the supplied esp-netif.
                              ##
                              ##  @param[in]  esp_netif Handle to esp-netif instance
                              ##  @param[out]  config Pointer to PPP netif configuration structure
                              ##
                              ##  @return     ESP_OK on success,
                              ##              ESP_ERR_ESP_NETIF_INVALID_PARAMS if the supplied netif is not of PPP type, or netif is null
                              ## 