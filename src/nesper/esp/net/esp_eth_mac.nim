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
import ../spi
import esp_eth_com

const
  ETH_MAC_FLAG_WORK_WITH_CACHE_DISABLE* = (1 shl 0) ## !< MAC driver can work when cache is disabled

type
  ##  @brief Ethernet MAC
  esp_eth_mac_t* {.importc: "esp_eth_mac_t", header: "esp_eth_mac.h", bycopy.} = object
    set_mediator_cb* {.importc: "set_mediator_cb".}: set_mediator_cb_t
    init_cb* {.importc: "init_cb".}: init_cb_t
    deinit_cb* {.importc: "deinit_cb".}: deinit_cb_t
    transmit_cb* {.importc: "transmit_cb".}: transmit_cb_t
    read_phy_reg_cb* {.importc: "read_phy_reg_cb".}: read_phy_reg_cb_t
    write_phy_reg_cb* {.importc: "write_phy_reg_cb".}: write_phy_reg_cb_t
    set_addr_cb* {.importc: "set_addr_cb".}: set_addr_cb_t
    get_addr_cb* {.importc: "get_addr_cb".}: get_addr_cb_t
    set_speed_cb* {.importc: "set_speed_cb".}: set_speed_cb_t
    set_duplex_cb* {.importc: "set_duplex_cb".}: set_duplex_cb_t
    set_link_cb* {.importc: "set_link_cb".}: set_link_cb_t
    set_promiscuous_cb* {.importc: "set_promiscuous_cb".}: set_promiscuous_cb_t
    del_cb* {.importc: "del_cb".}: del_cb_t

  ##  @brief Set mediator for Ethernet MAC
  ##  @param[in] mac: Ethernet MAC instance
  ##  @param[in] eth: Ethernet mediator
  ##  @return
  ##       - ESP_OK: set mediator for Ethernet MAC successfully
  ##       - ESP_ERR_INVALID_ARG: set mediator for Ethernet MAC failed because of invalid argument
  set_mediator_cb_t* = proc (mac: ptr esp_eth_mac_t; eth: ptr esp_eth_mediator_t): esp_err_t {.cdecl.} 

  ##  @brief Initialize Ethernet MAC
  ##  @param[in] mac: Ethernet MAC instance
  ##  @return
  ##       - ESP_OK: initialize Ethernet MAC successfully
  ##       - ESP_ERR_TIMEOUT: initialize Ethernet MAC failed because of timeout
  ##       - ESP_FAIL: initialize Ethernet MAC failed because some other error occurred
  init_cb_t* = proc (mac: ptr esp_eth_mac_t): esp_err_t {.cdecl.} 

  ##   @brief Deinitialize Ethernet MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @return
  ##        - ESP_OK: deinitialize Ethernet MAC successfully
  ##        - ESP_FAIL: deinitialize Ethernet MAC failed because some error occurred
  deinit_cb_t* = proc (mac: ptr esp_eth_mac_t): esp_err_t {.cdecl.} ## *

  ##   @brief Transmit packet from Ethernet MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] buf: packet buffer to transmit
  ##   @param[in] length: length of packet
  ##   @return
  ##        - ESP_OK: transmit packet successfully
  ##        - ESP_ERR_INVALID_ARG: transmit packet failed because of invalid argument
  ##        - ESP_ERR_INVALID_STATE: transmit packet failed because of wrong state of MAC
  ##        - ESP_FAIL: transmit packet failed because some other error occurred
  transmit_cb_t* = proc (mac: ptr esp_eth_mac_t; buf: ptr uint8; length: uint32): esp_err_t {.cdecl.} ## *

  ##   @brief Receive packet from Ethernet MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[out] buf: packet buffer which will preserve the received frame
  ##   @param[out] length: length of the received packet
  ##   @note Memory of buf is allocated in the Layer2, make sure it get free after process.
  ##   @return
  ##        - ESP_OK: receive packet successfully
  ##        - ESP_ERR_INVALID_ARG: receive packet failed because of invalid argument
  ##        - ESP_FAIL: receive packet failed because some other error occurred
  receive_cb_t* = proc (mac: ptr esp_eth_mac_t; buf: ptr uint8; length: ptr uint32): esp_err_t {.cdecl.} ## *

  ##   @brief Read PHY register
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] phy_addr: PHY chip address (0~31)
  ##   @param[in] phy_reg: PHY register index code
  ##   @param[out] reg_value: PHY register value
  ##   @return
  ##        - ESP_OK: read PHY register successfully
  ##        - ESP_ERR_INVALID_ARG: read PHY register failed because of invalid argument
  ##        - ESP_ERR_INVALID_STATE: read PHY register failed because of wrong state of MAC
  ##        - ESP_ERR_TIMEOUT: read PHY register failed because of timeout
  ##        - ESP_FAIL: read PHY register failed because some other error occurred
  read_phy_reg_cb_t* = proc (mac: ptr esp_eth_mac_t;
      phy_addr: uint32; phy_reg: uint32; reg_value: ptr uint32): esp_err_t {.cdecl.} ## *

  ##   @brief Write PHY register
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] phy_addr: PHY chip address (0~31)
  ##   @param[in] phy_reg: PHY register index code
  ##   @param[in] reg_value: PHY register value
  ##   @return
  ##        - ESP_OK: write PHY register successfully
  ##        - ESP_ERR_INVALID_STATE: write PHY register failed because of wrong state of MAC
  ##        - ESP_ERR_TIMEOUT: write PHY register failed because of timeout
  ##        - ESP_FAIL: write PHY register failed because some other error occurred
  write_phy_reg_cb_t* = proc (mac: ptr esp_eth_mac_t;
      phy_addr: uint32; phy_reg: uint32; reg_value: uint32): esp_err_t {.cdecl.} ## *

  ##   @brief Set MAC address
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] addr: MAC address
  ##   @return
  ##        - ESP_OK: set MAC address successfully
  ##        - ESP_ERR_INVALID_ARG: set MAC address failed because of invalid argument
  ##        - ESP_FAIL: set MAC address failed because some other error occurred
  set_addr_cb_t* = proc (mac: ptr esp_eth_mac_t;
      `addr`: ptr uint8): esp_err_t {.cdecl.} ## *

  ##   @brief Get MAC address
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[out] addr: MAC address
  ##   @return
  ##        - ESP_OK: get MAC address successfully
  ##        - ESP_ERR_INVALID_ARG: get MAC address failed because of invalid argument
  ##        - ESP_FAIL: get MAC address failed because some other error occurred
  get_addr_cb_t* = proc (mac: ptr esp_eth_mac_t;
      `addr`: ptr uint8): esp_err_t {.cdecl.} ## *

  ##   @brief Set speed of MAC
  ##   @param[in] ma:c Ethernet MAC instance
  ##   @param[in] speed: MAC speed
  ##   @return
  ##        - ESP_OK: set MAC speed successfully
  ##        - ESP_ERR_INVALID_ARG: set MAC speed failed because of invalid argument
  ##        - ESP_FAIL: set MAC speed failed because some other error occurred
  set_speed_cb_t* = proc (mac: ptr esp_eth_mac_t;
      speed: eth_speed_t): esp_err_t {.cdecl.} ## *

  ##   @brief Set duplex mode of MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] duplex: MAC duplex
  ##   @return
  ##        - ESP_OK: set MAC duplex mode successfully
  ##        - ESP_ERR_INVALID_ARG: set MAC duplex failed because of invalid argument
  ##        - ESP_FAIL: set MAC duplex failed because some other error occurred
  set_duplex_cb_t* = proc (mac: ptr esp_eth_mac_t;
      duplex: eth_duplex_t): esp_err_t {.cdecl.} ## *

  ##   @brief Set link status of MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] link: Link status
  ##   @return
  ##        - ESP_OK: set link status successfully
  ##        - ESP_ERR_INVALID_ARG: set link status failed because of invalid argument
  ##        - ESP_FAIL: set link status failed because some other error occurred
  set_link_cb_t* = proc (mac: ptr esp_eth_mac_t; link: eth_link_t): esp_err_t {.cdecl.} ## *

  ##   @brief Set promiscuous of MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @param[in] enable: set true to enable promiscuous mode; set false to disable promiscuous mode
  ##   @return
  ##        - ESP_OK: set promiscuous mode successfully
  ##        - ESP_FAIL: set promiscuous mode failed because some error occurred
  set_promiscuous_cb_t* = proc (mac: ptr esp_eth_mac_t;
      enable: bool): esp_err_t {.cdecl.} ## *

  ##   @brief Free memory of Ethernet MAC
  ##   @param[in] mac: Ethernet MAC instance
  ##   @return
  ##        - ESP_OK: free Ethernet MAC instance successfully
  ##        - ESP_FAIL: free Ethernet MAC instance failed because some error occurred
  del_cb_t* = proc (mac: ptr esp_eth_mac_t): esp_err_t {.cdecl.}


##  @brief Configuration of Ethernet MAC object
type
  eth_mac_config_t* {.importc: "eth_mac_config_t", header: "esp_eth_mac.h", bycopy.} = object
    sw_reset_timeout_ms* {.importc: "sw_reset_timeout_ms".}: uint32 ## !< Software reset timeout value (Unit: ms)
    rx_task_stack_size* {.importc: "rx_task_stack_size".}: uint32 ## !< Stack size of the receive task
    rx_task_prio* {.importc: "rx_task_prio".}: uint32 ## !< Priority of the receive task
    smi_mdc_gpio_num* {.importc: "smi_mdc_gpio_num".}: cint ## !< SMI MDC GPIO number
    smi_mdio_gpio_num* {.importc: "smi_mdio_gpio_num".}: cint ## !< SMI MDIO GPIO number
    flags* {.importc: "flags".}: uint32 ## !< Flags that specify extra capability for mac driver

proc ETH_MAC_DEFAULT_CONFIG*(
          sw_reset_timeout_ms = 100,
          rx_task_stack_size = 4096,
          rx_task_prio = 15,
          smi_mdc_gpio_num = 23,
          smi_mdio_gpio_num = 18,
          flags = 0): eth_mac_config_t {.inline.} =
    return eth_mac_config_t(
         sw_reset_timeout_ms: sw_reset_timeout_ms.uint32(), 
         rx_task_stack_size: rx_task_stack_size.uint32(), 
         rx_task_prio: rx_task_prio.uint32(),         
         smi_mdc_gpio_num: smi_mdc_gpio_num.cint(),     
         smi_mdio_gpio_num: smi_mdio_gpio_num.cint(),    
         flags: flags.cint())

##  @brief Default configuration for Ethernet MAC object
##  #define ETH_MAC_DEFAULT_CONFIG()    \
##      {                               \
##          .sw_reset_timeout_ms = 100, \
##          .rx_task_stack_size = 4096, \
##          .rx_task_prio = 15,         \
##          .smi_mdc_gpio_num = 23,     \
##          .smi_mdio_gpio_num = 18,    \
##          .flags = 0,                 \
##      }
##  @brief Create ESP32 Ethernet MAC instance
##  @param config: Ethernet MAC configuration
##  @return
##       - instance: create MAC instance successfully
##       - NULL: create MAC instance failed because some error occurred
proc esp_eth_mac_new_esp32*(config: ptr eth_mac_config_t): ptr esp_eth_mac_t {.
    importc: "esp_eth_mac_new_esp32", header: "esp_eth_mac.h".}

##  @brief DM9051 specific configuration
type
  eth_dm9051_config_t* {.importc: "eth_dm9051_config_t", header: "esp_eth_mac.h",
                        bycopy.} = object
    spi_hdl* {.importc: "spi_hdl".}: spi_device_handle_t ## !< Handle of SPI device driver
    int_gpio_num* {.importc: "int_gpio_num".}: cint ## !< Interrupt GPIO number


##  @brief Default DM9051 specific configuration
##  #define ETH_DM9051_DEFAULT_CONFIG(spi_device) \
##      {                                         \
##          .spi_hdl = spi_device,                \
##          .int_gpio_num = 4,                    \
##      }
##  @brief Create DM9051 Ethernet MAC instance
##  @param dm9051_config: DM9051 specific configuration
##  @param mac_config: Ethernet MAC configuration
##  @return
##       - instance: create MAC instance successfully
##       - NULL: create MAC instance failed because some error occurred
proc esp_eth_mac_new_dm9051*(dm9051_config: ptr eth_dm9051_config_t;
                            mac_config: ptr eth_mac_config_t): ptr esp_eth_mac_t {.
    importc: "esp_eth_mac_new_dm9051", header: "esp_eth_mac.h".}


