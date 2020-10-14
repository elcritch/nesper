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
import ../../general
import esp_eth_com

## *
##  @brief Ethernet PHY
##
##

type
  ##  @brief Ethernet PHY
  ##   @brief Set mediator for PHY
  ##   @param[in] phy: Ethernet PHY instance
  ##   @param[in] mediator: mediator of Ethernet driver
  ##   @return
  ##        - ESP_OK: set mediator for Ethernet PHY instance successfully
  ##        - ESP_ERR_INVALID_ARG: set mediator for Ethernet PHY instance failed because of some invalid arguments
  set_mediator*: proc (phy: ptr esp_eth_phy_t; mediator: ptr esp_eth_mediator_t): esp_err_t {.cdecl.}
  ## *
  ##  @brief Software Reset Ethernet PHY
  ##  @param[in] phy: Ethernet PHY instance
  ##  @return
  ##       - ESP_OK: reset Ethernet PHY successfully
  ##       - ESP_FAIL: reset Ethernet PHY failed because some error occurred
  ##
  ##
  reset_cb_t* {.importc: "reset".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Hardware Reset Ethernet PHY
  ##   @note Hardware reset is mostly done by pull down and up PHY's nRST pin
  ##   @param[in] phy: Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: reset Ethernet PHY successfully
  ##        - ESP_FAIL: reset Ethernet PHY failed because some error occurred
  reset_hw_cb_t* {.importc: "reset_hw".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Initialize Ethernet PHY
  ##   @param[in] phy: Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: initialize Ethernet PHY successfully
  ##        - ESP_FAIL: initialize Ethernet PHY failed because some error occurred
  init_cb_t* {.importc: "init".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Deinitialize Ethernet PHY
  ##   @param[in] phyL Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: deinitialize Ethernet PHY successfully
  ##        - ESP_FAIL: deinitialize Ethernet PHY failed because some error occurred
  deinit_cb_t* {.importc: "deinit".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Start auto negotiation
  ##   @param[in] phy: Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: restart auto negotiation successfully
  ##        - ESP_FAIL: restart auto negotiation failed because some error occurred
  negotiate_cb_t* {.importc: "negotiate".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Get Ethernet PHY link status
  ##   @param[in] phy: Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: get Ethernet PHY link status successfully
  ##        - ESP_FAIL: get Ethernet PHY link status failed because some error occurred
  get_link_cb_t* {.importc: "get_link".}: proc (phy: ptr esp_eth_phy_t): esp_err_t {.cdecl.}
  ##   @brief Power control of Ethernet PHY
  ##   @param[in] phy: Ethernet PHY instance
  ##   @param[in] enable: set true to power on Ethernet PHY; ser false to power off Ethernet PHY
  ##   @return
  ##        - ESP_OK: control Ethernet PHY power successfully
  ##        - ESP_FAIL: control Ethernet PHY power failed because some error occurred
  pwrctl_cb_t* {.importc: "pwrctl".}: proc (phy: ptr esp_eth_phy_t; enable: bool): esp_err_t {.cdecl.}
  ##   @brief Set PHY chip address
  ##   @param[in] phy: Ethernet PHY instance
  ##   @param[in] addr: PHY chip address
  ##   @return
  ##        - ESP_OK: set Ethernet PHY address successfully
  ##        - ESP_FAIL: set Ethernet PHY address failed because some error occurred
  set_addr_cb_t* {.importc: "set_addr".}: proc (phy: ptr esp_eth_phy_t; `addr`: uint32): esp_err_t {.cdecl.}
  ##   @brief Get PHY chip address
  ##   @param[in] phy: Ethernet PHY instance
  ##   @param[out] addr: PHY chip address
  ##   @return
  ##        - ESP_OK: get Ethernet PHY address successfully
  ##        - ESP_ERR_INVALID_ARG: get Ethernet PHY address failed because of invalid argument
  get_addr_cb_t* {.importc: "get_addr".}: proc (phy: ptr esp_eth_phy_t;
      `addr`: ptr uint32): esp_err_t {.cdecl.}
  ##   @brief Free memory of Ethernet PHY instance
  ##   @param[in] phy: Ethernet PHY instance
  ##   @return
  ##        - ESP_OK: free PHY instance successfully
  ##        - ESP_FAIL: free PHY instance failed because some error occurred
  del_cb_t* {.importc: "del".}: proc (phy: ptr esp_eth_phy_t): esp_err_t

  ##  @brief Ethernet PHY
  esp_eth_phy_t* {.importc: "esp_eth_phy_s", header: "esp_eth_phy.h", bycopy.} = object
    set_mediator_cb_t* {.importc: "set_mediator".}: set_mediator_cb_t
    reset_cb_t* {.importc: "reset".}: reset_cb_t
    reset_hw_cb_t* {.importc: "reset_hw".}: reset_hw_cb_t
    init_cb_t* {.importc: "init".}: init_cb_t
    deinit_cb_t* {.importc: "deinit".}: deinit_cb_t
    negotiate_cb_t* {.importc: "negotiate".}: negotiate_cb_t
    get_link_cb_t* {.importc: "get_link".}: get_link_cb_t
    pwrctl_cb_t* {.importc: "pwrctl".}: pwrctl_cb_t
    set_addr_cb_t* {.importc: "set_addr".}: set_addr_cb_t
    get_addr_cb_t* {.importc: "get_addr".}: get_addr_cb_t
    del_cb_t* {.importc: "del".}: del_cb_t


## *
##  @brief Ethernet PHY configuration
##
##

type
  eth_phy_config_t* {.importc: "eth_phy_config_t", header: "esp_eth_phy.h", bycopy.} = object
    phy_addr* {.importc: "phy_addr".}: uint32 ## !< PHY address
    reset_timeout_ms* {.importc: "reset_timeout_ms".}: uint32 ## !< Reset timeout value (Unit: ms)
    autonego_timeout_ms* {.importc: "autonego_timeout_ms".}: uint32 ## !< Auto-negotiation timeout value (Unit: ms)
    reset_gpio_num* {.importc: "reset_gpio_num".}: cint ## !< Reset GPIO number, -1 means no hardware reset


## *
##  @brief Default configuration for Ethernet PHY object
##
##
##  #define ETH_PHY_DEFAULT_CONFIG()     \
##      {                                \
##          .phy_addr = 1,               \
##          .reset_timeout_ms = 100,     \
##          .autonego_timeout_ms = 4000, \
##          .reset_gpio_num = 5,         \
##      }
## *
##  @brief Create a PHY instance of IP101
##
##  @param[in] config: configuration of PHY
##
##  @return
##       - instance: create PHY instance successfully
##       - NULL: create PHY instance failed because some error occurred
##

proc esp_eth_phy_new_ip101*(config: ptr eth_phy_config_t): ptr esp_eth_phy_t {.
    importc: "esp_eth_phy_new_ip101", header: "esp_eth_phy.h".}
## *
##  @brief Create a PHY instance of RTL8201
##
##  @param[in] config: configuration of PHY
##
##  @return
##       - instance: create PHY instance successfully
##       - NULL: create PHY instance failed because some error occurred
##

proc esp_eth_phy_new_rtl8201*(config: ptr eth_phy_config_t): ptr esp_eth_phy_t {.
    importc: "esp_eth_phy_new_rtl8201", header: "esp_eth_phy.h".}
## *
##  @brief Create a PHY instance of LAN8720
##
##  @param[in] config: configuration of PHY
##
##  @return
##       - instance: create PHY instance successfully
##       - NULL: create PHY instance failed because some error occurred
##

proc esp_eth_phy_new_lan8720*(config: ptr eth_phy_config_t): ptr esp_eth_phy_t {.
    importc: "esp_eth_phy_new_lan8720", header: "esp_eth_phy.h".}
## *
##  @brief Create a PHY instance of DP83848
##
##  @param[in] config: configuration of PHY
##
##  @return
##       - instance: create PHY instance successfully
##       - NULL: create PHY instance failed because some error occurred
##

proc esp_eth_phy_new_dp83848*(config: ptr eth_phy_config_t): ptr esp_eth_phy_t {.
    importc: "esp_eth_phy_new_dp83848", header: "esp_eth_phy.h".}

## *
##  @brief Create a PHY instance of DM9051
##
##  @param[in] config: configuration of PHY
##
##  @return
##       - instance: create PHY instance successfully
##       - NULL: create PHY instance failed because some error occurred
##
proc esp_eth_phy_new_dm9051*(config: ptr eth_phy_config_t): ptr esp_eth_phy_t {.
    importc: "esp_eth_phy_new_dm9051", header: "esp_eth_phy.h".}