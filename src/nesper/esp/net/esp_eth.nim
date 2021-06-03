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
import esp_eth_com
import esp_eth_mac
import esp_eth_phy

export esp_eth_com
export esp_eth_mac
export esp_eth_phy

# import ../esp_event_legacy

## *
##  @brief Handle of Ethernet driver
##
##

type
  esp_eth_handle_t* = pointer

## *
##  @brief Configuration of Ethernet driver
##
##

##  @brief Input frame buffer to user's stack
##
##  @param[in] eth_handle: handle of Ethernet driver
##  @param[in] buffer: frame buffer that will get input to upper stack
##  @param[in] length: length of the frame buffer
##
##  @return
##       - ESP_OK: input frame buffer to upper stack successfully
##       - ESP_FAIL: error occurred when inputting buffer to upper stack
##
##
when defined(ESP_IDF_V4_0):
  type
    stack_input_cb_t* =  proc (eth_handle: esp_eth_handle_t; buffer: ptr uint8; length: uint32): esp_err_t {.cdecl.}
else:
  type
    stack_input_cb_t* =  proc (eth_handle: esp_eth_handle_t; buffer: ptr uint8; length: uint32, priv: pointer): esp_err_t {.cdecl.}


type

  ##  @brief Callback function invoked when lowlevel initialization is finished
  ##
  ##  @param[in] eth_handle: handle of Ethernet driver
  ##
  ##  @return
  ##        - ESP_OK: process extra lowlevel initialization successfully
  ##        - ESP_FAIL: error occurred when processing extra lowlevel initialization
  ##
  on_lowlevel_init_done_cb_t* = proc ( eth_handle: esp_eth_handle_t): esp_err_t {.cdecl.} ## *

  ##  @brief Callback function invoked when lowlevel deinitialization is finished
  ##
  ##  @param[in] eth_handle: handle of Ethernet driver
  ##
  ##  @return
  ##        - ESP_OK: process extra lowlevel deinitialization successfully
  ##        - ESP_FAIL: error occurred when processing extra lowlevel deinitialization
  ##
  on_lowlevel_deinit_done_cb_t* = proc ( eth_handle: esp_eth_handle_t): esp_err_t {.cdecl.}

  esp_eth_config_t* {.importc: "esp_eth_config_t", header: "esp_eth.h", bycopy.} = object
    mac* {.importc: "mac".}: ptr esp_eth_mac_t ##  @brief Ethernet MAC object
    phy* {.importc: "phy".}: ptr esp_eth_phy_t ##  @brief Ethernet PHY object
    check_link_period_ms* {.importc: "check_link_period_ms".}: uint32 ##  @brief Period time of checking Ethernet link status
    stack_input* {.importc: "stack_input".}: stack_input_cb_t
    on_lowlevel_init_done* {.importc: "on_lowlevel_init_done".}: on_lowlevel_init_done_cb_t
    on_lowlevel_deinit_done* {.importc: "on_lowlevel_deinit_done".}: on_lowlevel_deinit_done_cb_t

## *
##  @brief Default configuration for Ethernet driver
##
##
proc eth_default_config*(
          emac: ptr esp_eth_mac_t,
          ephy: ptr esp_eth_phy_t,
          check_link_period_ms = 2000'u32,
          stack_input: stack_input_cb_t = nil,
          on_lowlevel_init_done: on_lowlevel_init_done_cb_t = nil,
          on_lowlevel_deinit_done: on_lowlevel_deinit_done_cb_t = nil,
        ): esp_eth_config_t =
  
  result = esp_eth_config_t(
            mac: emac,
            phy: ephy,
            check_link_period_ms: check_link_period_ms,
            stack_input: stack_input,
            on_lowlevel_init_done: on_lowlevel_init_done,
            on_lowlevel_deinit_done: on_lowlevel_deinit_done)

##  #define ETH_DEFAULT_CONFIG(emac, ephy)   \
##      {                                    \
##          .mac = emac,                     \
##          .phy = ephy,                     \
##          .check_link_period_ms = 2000,    \
##          .stack_input = NULL,             \
##          .on_lowlevel_init_done = NULL,   \
##          .on_lowlevel_deinit_done = NULL, \
##      }
## *
##  @brief Install Ethernet driver
##
##  @param[in]  config: configuration of the Ethernet driver
##  @param[out] out_hdl: handle of Ethernet driver
##
##  @return
##        - ESP_OK: install esp_eth driver successfully
##        - ESP_ERR_INVALID_ARG: install esp_eth driver failed because of some invalid argument
##        - ESP_ERR_NO_MEM: install esp_eth driver failed because there's no memory for driver
##        - ESP_FAIL: install esp_eth driver failed because some other error occurred
##

proc esp_eth_driver_install*(config: ptr esp_eth_config_t;
                            out_hdl: ptr esp_eth_handle_t): esp_err_t {.
    importc: "esp_eth_driver_install", header: "esp_eth.h".}
## *
##  @brief Uninstall Ethernet driver
##  @note It's not recommended to uninstall Ethernet driver unless it won't get used any more in application code.
##        To uninstall Ethernet driver, you have to make sure, all references to the driver are released.
##        Ethernet driver can only be uninstalled successfully when reference counter equals to one.
##
##  @param[in] hdl: handle of Ethernet driver
##
##  @return
##        - ESP_OK: uninstall esp_eth driver successfully
##        - ESP_ERR_INVALID_ARG: uninstall esp_eth driver failed because of some invalid argument
##        - ESP_ERR_INVALID_STATE: uninstall esp_eth driver failed because it has more than one reference
##        - ESP_FAIL: uninstall esp_eth driver failed because some other error occurred
##

proc esp_eth_driver_uninstall*(hdl: esp_eth_handle_t): esp_err_t {.
    importc: "esp_eth_driver_uninstall", header: "esp_eth.h".}
## *
##  @brief Start Ethernet driver
##
##  @note This API will start driver state machine and internal software timer (for checking link status).
##
##  @param[in] hdl handle of Ethernet driver
##
##  @return
##        - ESP_OK: start esp_eth driver successfully
##        - ESP_ERR_INVALID_ARG: start esp_eth driver failed because of some invalid argument
##        - ESP_ERR_INVALID_STATE: start esp_eth driver failed because driver has started already
##        - ESP_FAIL: start esp_eth driver failed because some other error occurred
##

proc esp_eth_start*(hdl: esp_eth_handle_t): esp_err_t {.importc: "esp_eth_start",
    header: "esp_eth.h".}
## *
##  @brief Stop Ethernet driver
##
##  @note This function does the oppsite operation of `esp_eth_start`.
##
##  @param[in] hdl handle of Ethernet driver
##  @return
##        - ESP_OK: stop esp_eth driver successfully
##        - ESP_ERR_INVALID_ARG: stop esp_eth driver failed because of some invalid argument
##        - ESP_ERR_INVALID_STATE: stop esp_eth driver failed because driver has not started yet
##        - ESP_FAIL: stop esp_eth driver failed because some other error occurred
##

proc esp_eth_stop*(hdl: esp_eth_handle_t): esp_err_t {.importc: "esp_eth_stop",
    header: "esp_eth.h".}
## *
##  @brief General Transmit
##
##  @param[in] hdl: handle of Ethernet driver
##  @param[in] buf: buffer of the packet to transfer
##  @param[in] length: length of the buffer to transfer
##
##  @return
##        - ESP_OK: transmit frame buffer successfully
##        - ESP_ERR_INVALID_ARG: transmit frame buffer failed because of some invalid argument
##        - ESP_FAIL: transmit frame buffer failed because some other error occurred
##

proc esp_eth_transmit*(hdl: esp_eth_handle_t; buf: ptr uint8; length: uint32): esp_err_t {.
    importc: "esp_eth_transmit", header: "esp_eth.h".}
## *
##  @brief General Receive
##
##  @param[in] hdl: handle of Ethernet driver
##  @param[out] buf: buffer to preserve the received packet
##  @param[out] length: length of the received packet
##
##  @return
##        - ESP_OK: receive frame buffer successfully
##        - ESP_ERR_INVALID_ARG: receive frame buffer failed because of some invalid argument
##        - ESP_FAIL: receive frame buffer failed because some other error occurred
##

proc esp_eth_receive*(hdl: esp_eth_handle_t; buf: ptr uint8; length: ptr uint32): esp_err_t {.
    importc: "esp_eth_receive", header: "esp_eth.h".}
## *
##  @brief Misc IO function of Etherent driver
##
##  @param[in] hdl: handle of Ethernet driver
##  @param[in] cmd: IO control command
##  @param[in] data: specificed data for command
##
##  @return
##        - ESP_OK: process io command successfully
##        - ESP_ERR_INVALID_ARG: process io command failed because of some invalid argument
##        - ESP_FAIL: process io command failed because some other error occurred
##

proc esp_eth_ioctl*(hdl: esp_eth_handle_t; cmd: esp_eth_io_cmd_t; data: pointer): esp_err_t {.
    importc: "esp_eth_ioctl", header: "esp_eth.h".}
## *
##  @brief Increase Ethernet driver reference
##  @note Ethernet driver handle can be obtained by os timer, netif, etc.
##        It's dangerous when thread A is using Ethernet but thread B uninstall the driver.
##        Using reference counter can prevent such risk, but care should be taken, when you obtain Ethernet driver,
##        this API must be invoked so that the driver won't be uninstalled during your using time.
##
##
##  @param[in] hdl: handle of Ethernet driver
##  @return
##        - ESP_OK: increase reference successfully
##        - ESP_ERR_INVALID_ARG: increase reference failed because of some invalid argument
##

proc esp_eth_increase_reference*(hdl: esp_eth_handle_t): esp_err_t {.
    importc: "esp_eth_increase_reference", header: "esp_eth.h".}
## *
##  @brief Decrease Ethernet driver reference
##
##  @param[in] hdl: handle of Ethernet driver
##  @return
##        - ESP_OK: increase reference successfully
##        - ESP_ERR_INVALID_ARG: increase reference failed because of some invalid argument
##

proc esp_eth_decrease_reference*(hdl: esp_eth_handle_t): esp_err_t {.
    importc: "esp_eth_decrease_reference", header: "esp_eth.h".}