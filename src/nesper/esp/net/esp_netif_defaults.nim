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

import esp_netif_types

const netif_def_headers = """#include "esp_netif.h" 
                             #include "esp_netif_defaults.h" """

##  @brief  Default base config (esp-netif inherent) of WIFI STA
##

var
  ESP_NETIF_BASE_DEFAULT_WIFI_STA* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_inherent_config_t
  ESP_NETIF_BASE_DEFAULT_WIFI_AP* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_inherent_config_t
  ESP_NETIF_BASE_DEFAULT_ETH* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_inherent_config_t
  ESP_NETIF_BASE_DEFAULT_PPP* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_inherent_config_t

  ESP_NETIF_NETSTACK_DEFAULT_ETH* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_STA* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_WIFI_AP* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_netstack_config_t
  ESP_NETIF_NETSTACK_DEFAULT_PPP* {.importc: "$1", header: netif_def_headers.}: ptr esp_netif_netstack_config_t

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

proc ESP_NETIF_DEFAULT_ETH*(): esp_netif_config_t =
  return esp_netif_config_t(
        base: ESP_NETIF_BASE_DEFAULT_ETH,
        driver: nil,
        stack: ESP_NETIF_NETSTACK_DEFAULT_ETH,
  )

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

##
## *
##  @brief  Default base config (esp-netif inherent) of WIFI AP
##
