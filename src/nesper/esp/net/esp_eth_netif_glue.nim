##  Copyright 2019 Espressif Systems (Shanghai) PTE LTD
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

import ../../consts
import esp_eth

## *
##  @brief Create a netif glue for Ethernet driver
##  @note netif glue is used to attach io driver to TCP/IP netif
##
##  @param eth_hdl Ethernet driver handle
##  @return glue object, which inherits esp_netif_driver_base_t
##

proc esp_eth_new_netif_glue*(eth_hdl: esp_eth_handle_t): pointer {.
    importc: "esp_eth_new_netif_glue", header: "esp_eth_netif_glue.h".}
## *
##  @brief Delete netif glue of Ethernet driver
##
##  @param glue netif glue
##  @return -ESP_OK: delete netif glue successfully
##

proc esp_eth_del_netif_glue*(glue: pointer): esp_err_t {.
    importc: "esp_eth_del_netif_glue", header: "esp_eth_netif_glue.h".}
## *
##  @brief Register default IP layer handlers for Ethernet
##
##  @note: Ethernet handle might not yet properly initialized when setting up these default handlers
##
##  @param[in] esp_netif esp network interface handle created for Ethernet driver
##  @return
##       - ESP_ERR_INVALID_ARG: invalid parameter (esp_netif is NULL)
##       - ESP_OK: set default IP layer handlers successfully
##       - others: other failure occurred during register esp_event handler
##

proc esp_eth_set_default_handlers*(esp_netif: pointer): esp_err_t {.
    importc: "esp_eth_set_default_handlers", header: "esp_eth_netif_glue.h".}
## *
##  @brief Unregister default IP layer handlers for Ethernet
##
##  @param[in] esp_netif esp network interface handle created for Ethernet driver
##  @return
##       - ESP_ERR_INVALID_ARG: invalid parameter (esp_netif is NULL)
##       - ESP_OK: clear default IP layer handlers successfully
##       - others: other failure occurred during unregister esp_event handler
##

proc esp_eth_clear_default_handlers*(esp_netif: pointer): esp_err_t {.
    importc: "esp_eth_clear_default_handlers", header: "esp_eth_netif_glue.h".}