##
##  SPDX-FileCopyrightText: 2015-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

const hdr = "esp_netif_defaults.h"

import ./esp_netif_types

let
  ESP_NETIF_DEFAULT_ARP_FLAGS* {.importc: "ESP_NETIF_DEFAULT_ARP_FLAGS", header: hdr.}: cint ##
                              ##
                              ##  Macros to assemble master configs with partial configs from netif, stack and driver
                              ##
                              ##  If GARP enabled in menuconfig (default), make it also a default config for common netifs

##
##  @brief  Default configuration reference of ethernet interface
##

proc ESP_NETIF_INHERENT_DEFAULT_WIFI_STA*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_WIFI_STA", header: hdr.}

proc ESP_NETIF_INHERENT_DEFAULT_WIFI_AP*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_WIFI_AP", header: hdr.}

proc ESP_NETIF_INHERENT_DEFAULT_WIFI_NAN*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_WIFI_NAN", header: hdr.}

proc ESP_NETIF_INHERENT_DEFAULT_ETH*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_ETH", header: hdr.}

proc ESP_NETIF_INHERENT_DEFAULT_PPP*(): esp_netif_inherent_config_t =
  {.emit: """
  esp_netif_inherent_config_t cfg = ESP_NETIF_INHERENT_DEFAULT_PPP();
  `result` = cfg;
  """.}


proc ESP_NETIF_INHERENT_DEFAULT_BR*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_BR", header: hdr.}

proc ESP_NETIF_INHERENT_DEFAULT_BR_DHCPS*(): esp_netif_inherent_config_t {.importc: "ESP_NETIF_INHERENT_DEFAULT_BR_DHCPS", header: hdr.}

proc ESP_NETIF_DEFAULT_ETH*(): esp_netif_config_t {.importc: "ESP_NETIF_DEFAULT_ETH", header: hdr.}

proc ESP_NETIF_DEFAULT_WIFI_AP*(): esp_netif_config_t {.importc: "ESP_NETIF_DEFAULT_WIFI_AP", header: hdr.}

proc ESP_NETIF_DEFAULT_WIFI_NAN*(): esp_netif_config_t {.importc: "ESP_NETIF_DEFAULT_WIFI_NAN", header: hdr.}

proc ESP_NETIF_DEFAULT_WIFI_STA*(): esp_netif_config_t {.importc: "ESP_NETIF_DEFAULT_WIFI_STA", header: hdr.}

proc ESP_NETIF_DEFAULT_PPP*(): esp_netif_config_t {.importc: "ESP_NETIF_DEFAULT_PPP", header: hdr.}


let
  ESP_NETIF_BASE_DEFAULT_WIFI_STA* {.importc: "ESP_NETIF_BASE_DEFAULT_WIFI_STA", header: hdr.}: ptr esp_netif_inherent_config_t ##
                              ##
                              ##  @brief  Default base config (esp-netif inherent) of WIFI STA
                              ##
  ESP_NETIF_BASE_DEFAULT_WIFI_AP* {.importc: "ESP_NETIF_BASE_DEFAULT_WIFI_AP", header: hdr.}: ptr esp_netif_inherent_config_t ##
                              ##
                              ##  @brief  Default base config (esp-netif inherent) of WIFI AP
                              ##
  ESP_NETIF_BASE_DEFAULT_WIFI_NAN* {.importc: "ESP_NETIF_BASE_DEFAULT_WIFI_NAN", header: hdr.}: ptr esp_netif_inherent_config_t ##
                              ##
                              ##  @brief  Default base config (esp-netif inherent) of WIFI NAN
                              ##
  ESP_NETIF_BASE_DEFAULT_ETH* {.importc: "ESP_NETIF_BASE_DEFAULT_ETH", header: hdr.}: ptr esp_netif_inherent_config_t ##
                              ##
                              ##  @brief  Default base config (esp-netif inherent) of ethernet interface
                              ##
  ESP_NETIF_BASE_DEFAULT_PPP* {.importc: "ESP_NETIF_BASE_DEFAULT_PPP", header: hdr.}: ptr esp_netif_inherent_config_t ##
                              ##
                              ##  @brief  Default base config (esp-netif inherent) of ppp interface
                              ##

let
  ESP_NETIF_NETSTACK_DEFAULT_ETH* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_ETH", header: hdr.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_BR* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_BR", header: hdr.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_STA* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_WIFI_STA", header: hdr.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_AP* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_WIFI_AP", header: hdr.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_NAN* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_WIFI_NAN", header: hdr.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_PPP* {.importc: "ESP_NETIF_NETSTACK_DEFAULT_PPP", header: hdr.}: ptr esp_netif_netstack_config_t
