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

## *

const
  ETH_MAX_PAYLOAD_LEN* = (1500) ##  @brief Maximum Ethernet payload size
  ETH_MIN_PAYLOAD_LEN* = (46) ##  @brief Minimum Ethernet payload size
  ETH_HEADER_LEN* = (14) ##  @brief Ethernet frame header size: Dest addr(6 Bytes) + Src addr(6 Bytes) + length/type(2 Bytes)
  ETH_CRC_LEN* = (4) ##  @brief Ethernet frame CRC length
  ETH_VLAN_TAG_LEN* = (4) ##  @brief Optional 802.1q VLAN Tag length
  ETH_JUMBO_FRAME_PAYLOAD_LEN* = (9000) ##  @brief Jumbo frame payload size
  ETH_MAX_PACKET_SIZE* = (ETH_HEADER_LEN + ETH_VLAN_TAG_LEN + ETH_MAX_PAYLOAD_LEN + ETH_CRC_LEN) ##  @brief Maximum frame size (1522 Bytes)
  ETH_MIN_PACKET_SIZE* = (ETH_HEADER_LEN + ETH_MIN_PAYLOAD_LEN + ETH_CRC_LEN) ##  @brief Minimum frame size (64 Bytes)

type
  esp_eth_state_t* {.size: sizeof(cint).} = enum ##  @brief Ethernet driver state
    ETH_STATE_LLINIT,         ## !< Lowlevel init done
    ETH_STATE_DEINIT,         ## !< Deinit done
    ETH_STATE_LINK,           ## !< Link status changed
    ETH_STATE_SPEED,          ## !< Speed updated
    ETH_STATE_DUPLEX          ## !< Duplex updated


type
  esp_eth_io_cmd_t* {.size: sizeof(cint).} = enum ##  @brief Command list for ioctl API
    ETH_CMD_G_MAC_ADDR,       ## !< Get MAC address
    ETH_CMD_S_MAC_ADDR,       ## !< Set MAC address
    ETH_CMD_G_PHY_ADDR,       ## !< Get PHY address
    ETH_CMD_S_PHY_ADDR,       ## !< Set PHY address
    ETH_CMD_G_SPEED,          ## !< Get Speed
    ETH_CMD_S_PROMISCUOUS     ## !< Set promiscuous mode

  eth_link_t* {.size: sizeof(cint).} = enum ##  @brief Ethernet link status
    ETH_LINK_UP,              ## !< Ethernet link is up
    ETH_LINK_DOWN             ## !< Ethernet link is down

  eth_speed_t* {.size: sizeof(cint).} = enum ##  @brief Ethernet speed
    ETH_SPEED_10M,            ## !< Ethernet speed is 10Mbps
    ETH_SPEED_100M            ## !< Ethernet speed is 100Mbps

  eth_duplex_t* {.size: sizeof(cint).} = enum ##  @brief Ethernet duplex mode
    ETH_DUPLEX_HALF,          ## !< Ethernet is in half duplex
    ETH_DUPLEX_FULL           ## !< Ethernet is in full duplex

  ##  @brief Read PHY register
  ##  @param[in] eth: mediator of Ethernet driver
  ##  @param[in] phy_addr: PHY Chip address (0~31)
  ##  @param[in] phy_reg: PHY register index code
  ##  @param[out] reg_value: PHY register value
  ##  @return
  ##        - ESP_OK: read PHY register successfully
  ##        - ESP_FAIL: read PHY register failed because some error occurred
  phy_reg_read_cv* = proc (eth: ptr esp_eth_mediator_t; phy_addr: uint32; phy_reg: uint32; reg_value: ptr uint32): esp_err_t {.cdecl.}

  ##  @brief Write PHY register
  ##  @param[in] eth: mediator of Ethernet driver
  ##  @param[in] phy_addr: PHY Chip address (0~31)
  ##  @param[in] phy_reg: PHY register index code
  ##  @param[in] reg_value: PHY register value
  ##  @return
  ##        - ESP_OK: write PHY register successfully
  ##        - ESP_FAIL: write PHY register failed because some error occurred
  phy_reg_write_cb* = proc (eth: ptr esp_eth_mediator_t; phy_addr: uint32; phy_reg: uint32; reg_value: uint32): esp_err_t {.cdecl.}

  ##  @brief Deliver packet to upper stack
  ##  @param[in] eth: mediator of Ethernet driver
  ##  @param[in] buffer: packet buffer
  ##  @param[in] length: length of the packet
  ##  @return
  ##        - ESP_OK: deliver packet to upper stack successfully
  ##        - ESP_FAIL: deliver packet failed because some error occurred
  stack_input_cb* = proc (eth: ptr esp_eth_mediator_t; buffer: ptr uint8; length: uint32): esp_err_t {.cdecl.}

  on_state_changed_cb* = proc (eth: ptr esp_eth_mediator_t; state: esp_eth_state_t; args: pointer): esp_err_t {.cdecl.}

  esp_eth_mediator_t* {.importc: "esp_eth_mediator_t", header: "esp_eth_com.h",
                       bycopy.} = object ##  @brief Ethernet mediator
    phy_reg_read* {.importc: "phy_reg_read".}: phy_reg_read_cv
    phy_reg_write* {.importc: "phy_reg_write".}: phy_reg_write_cb
    stack_input* {.importc: "stack_input".}: stack_input_cb
    on_state_changed* {.importc: "on_state_changed".}: on_state_changed_cb


  eth_event_t* {.size: sizeof(cint).} = enum ##  @brief Ethernet event declarations
    ETHERNET_EVENT_START,     ## !< Ethernet driver start
    ETHERNET_EVENT_STOP,      ## !< Ethernet driver stop
    ETHERNET_EVENT_CONNECTED, ## !< Ethernet got a valid link
    ETHERNET_EVENT_DISCONNECTED ## !< Ethernet lost a valid link

when defined(ESP_IDF_V4_0):
  var ETH_EVENT* {.importc: "ETH_EVENT", header: "esp_wifi_types.h".}: esp_event_base_t ##  @brief Ethernet event base declaration
else:
  var ETH_EVENT* {.importc: "ETH_EVENT", header: "esp_eth_com.h".}: esp_event_base_t ##  @brief Ethernet event base declaration
