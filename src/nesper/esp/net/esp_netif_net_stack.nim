##
##  SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

const hdr = "esp_netif_net_stack.h"

import esp_netif_types

proc ethernetif_init*(netif: ptr netif): err_t {.cdecl,
    importc, header: hdr.}
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