##
##  SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

const hdr = "lwip/esp_netif_net_stack.h"

when defined(CONFIG_ESP_NETIF_RECEIVE_REPORT_ERRORS):
  type
    esp_netif_recv_ret_t* = esp_err_t
else:
  type
    esp_netif_recv_ret_t* = void

type

  err_t* = distinct int8
  net_if* {.importc: "netif", header: hdr, bycopy.} = object

  init_fn_t* = proc (a1: ptr netif): err_t {.cdecl.}

  input_fn_t* = proc (netif: pointer; buffer: pointer; len: csize_t; eb: pointer): esp_netif_recv_ret_t {.
      cdecl.}

  esp_netif_netstack_lwip_vanilla_config* {.
      importc: "esp_netif_netstack_lwip_vanilla_config",
      header: hdr, bycopy.} = object
    init_fn* {.importc: "init_fn".}: init_fn_t
    input_fn* {.importc: "input_fn".}: input_fn_t


  esp_netif_netstack_lwip_ppp_config* {.importc: "esp_netif_netstack_lwip_ppp_config",
                                        header: hdr, bycopy.} = object
    input_fn* {.importc: "input_fn".}: input_fn_t
    ppp_events* {.importc: "ppp_events".}: esp_netif_ppp_config_t


  esp_netif_netstack_config* {.importc: "esp_netif_netstack_config",
                               header: hdr, bycopy.} = object ##
                              ##  LWIP netif specific network stack configuration
    lwip* {.importc: "lwip".}: esp_netif_netstack_lwip_vanilla_config
    lwip_ppp* {.importc: "lwip_ppp".}: esp_netif_netstack_lwip_ppp_config



proc ethernetif_init*(netif: ptr netif): err_t {.cdecl,
    importc: "ethernetif_init", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack init function for Ethernet
                              ##  @param netif LWIP's network interface handle
                              ##  @return ERR_OK on success
                              ##

proc ethernetif_input*(h: pointer; buffer: pointer; len: csize_t;
                       l2_buff: pointer): esp_netif_recv_ret_t {.cdecl,
    importc: "ethernetif_input", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack input packet function for Ethernet
                              ##  @param h LWIP's network interface handle
                              ##  @param buffer Input buffer pointer
                              ##  @param len Input buffer size
                              ##  @param l2_buff External buffer pointer (to be passed to custom input-buffer free)
                              ##

proc wlanif_init_ap*(netif: ptr netif): err_t {.cdecl,
    importc: "wlanif_init_ap", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack init function for WiFi (AP)
                              ##  @param netif LWIP's network interface handle
                              ##  @return ERR_OK on success
                              ##

proc wlanif_init_sta*(netif: ptr netif): err_t {.cdecl,
    importc: "wlanif_init_sta", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack init function for WiFi (Station)
                              ##  @param netif LWIP's network interface handle
                              ##  @return ERR_OK on success
                              ##

proc wlanif_init_nan*(netif: ptr netif): err_t {.cdecl,
    importc: "wlanif_init_nan", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack init function for WiFi Aware interface (NAN)
                              ##  @param netif LWIP's network interface handle
                              ##  @return ERR_OK on success
                              ##

proc wlanif_input*(h: pointer; buffer: pointer; len: csize_t; l2_buff: pointer): esp_netif_recv_ret_t {.
    cdecl, importc: "wlanif_input", header: hdr.}
  ##
                              ##
                              ##  @brief   LWIP's network stack input packet function for WiFi (both STA/AP)
                              ##  @param h LWIP's network interface handle
                              ##  @param buffer Input buffer pointer
                              ##  @param len Input buffer size
                              ##  @param l2_buff External buffer pointer (to be passed to custom input-buffer free)
                              ## 