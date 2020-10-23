##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
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

import esp_netif

##
##  Macros to assemble master configs with partial configs from netif, stack and driver
##
##  /**
##   * @brief  Default configuration reference of ethernet interface
##   */
##  #define ESP_NETIF_DEFAULT_ETH()                  \
##      {                                            \
##          .base = ESP_NETIF_BASE_DEFAULT_ETH,      \
##          .driver = NULL,                          \
##          .stack = ESP_NETIF_NETSTACK_DEFAULT_ETH, \
##      }

const netif_def_headers = """#include "esp_netif.h" 
                             #include "esp_netif_defaults.h" """

proc ESP_NETIF_DEFAULT_ETH*(cfg: var esp_netif_config_t) =
  {.emit: """
  cfg->base = ESP_NETIF_BASE_DEFAULT_ETH;
  cfg->driver = NULL; 
  cfg->stack = ESP_NETIF_NETSTACK_DEFAULT_ETH; 
  """.}
  discard "ok"

##  /**
##   * @brief  Default configuration reference of WIFI AP
##   */
##  #define ESP_NETIF_DEFAULT_WIFI_AP()                  \
##  {                                                    \
##          .base = ESP_NETIF_BASE_DEFAULT_WIFI_AP,      \
##          .driver = NULL,                              \
##          .stack = ESP_NETIF_NETSTACK_DEFAULT_WIFI_AP, \
##      }
##  /**
##  * @brief  Default configuration reference of WIFI STA
##  */
##  #define ESP_NETIF_DEFAULT_WIFI_STA()                  \
##      {                                                 \
##          .base = ESP_NETIF_BASE_DEFAULT_WIFI_STA,      \
##          .driver = NULL,                               \
##          .stack = ESP_NETIF_NETSTACK_DEFAULT_WIFI_STA, \
##      }
##  /**
##  * @brief  Default configuration reference of PPP client
##  */
##  #define ESP_NETIF_DEFAULT_PPP()                       \
##      {                                                 \
##          .base = ESP_NETIF_BASE_DEFAULT_PPP,           \
##          .driver = NULL,                               \
##          .stack = ESP_NETIF_NETSTACK_DEFAULT_PPP,      \
##      }
## *

##
##  Include default network stacks configs
##   - Network stack configurations are provided in a specific network stack
##       implementation that is invisible to user API
##   - Here referenced only as opaque pointers
##

var gg_esp_netif_netstack_default_eth* {.importc: "_g_esp_netif_netstack_default_eth",
  header: netif_def_headers.}: ptr esp_netif_netstack_config_t

var gg_esp_netif_netstack_default_wifi_sta* {.
  importc: "_g_esp_netif_netstack_default_wifi_sta",
  header: netif_def_headers.}: ptr esp_netif_netstack_config_t

var gg_esp_netif_netstack_default_wifi_ap* {.
    importc: "_g_esp_netif_netstack_default_wifi_ap",
    header: netif_def_headers.}: ptr esp_netif_netstack_config_t

var gg_esp_netif_netstack_default_ppp* {.importc: "_g_esp_netif_netstack_default_ppp",
                                       header: netif_def_headers.}: ptr esp_netif_netstack_config_t

##
##  Include default common configs inherent to esp-netif
##   - These inherent configs are defined in esp_netif_defaults.c and describe
##     common behavioural patters for common interfaces such as STA, AP, ETH
##

var gg_esp_netif_inherent_sta_config* {.importc: "_g_esp_netif_inherent_sta_config",
                                      header: netif_def_headers.}: esp_netif_inherent_config_t

var gg_esp_netif_inherent_ap_config* {.importc: "_g_esp_netif_inherent_ap_config",
                                     header: netif_def_headers.}: esp_netif_inherent_config_t

var gg_esp_netif_inherent_eth_config* {.importc: "_g_esp_netif_inherent_eth_config",
                                      header: netif_def_headers.}: esp_netif_inherent_config_t

var gg_esp_netif_inherent_ppp_config* {.importc: "_g_esp_netif_inherent_ppp_config",
                                      header: netif_def_headers.}: esp_netif_inherent_config_t

##  @brief  Default base config (esp-netif inherent) of WIFI STA
##

var
  ESP_NETIF_BASE_DEFAULT_WIFI_STA* = addr(gg_esp_netif_inherent_sta_config)

## *
##  @brief  Default base config (esp-netif inherent) of WIFI AP
##

var
  ESP_NETIF_BASE_DEFAULT_WIFI_AP* = addr(gg_esp_netif_inherent_ap_config)

## *
##  @brief  Default base config (esp-netif inherent) of ethernet interface
##

var
  ESP_NETIF_BASE_DEFAULT_ETH* = addr(gg_esp_netif_inherent_eth_config)

## *
##  @brief  Default base config (esp-netif inherent) of ppp interface
##

var
  ESP_NETIF_BASE_DEFAULT_PPP* = addr(gg_esp_netif_inherent_ppp_config)
  ESP_NETIF_NETSTACK_DEFAULT_ETH* = gg_esp_netif_netstack_default_eth
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_STA* = gg_esp_netif_netstack_default_wifi_sta
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_AP* = gg_esp_netif_netstack_default_wifi_ap
  ESP_NETIF_NETSTACK_DEFAULT_PPP* = gg_esp_netif_netstack_default_ppp
