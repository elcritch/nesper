##  Copyright 2021 Espressif Systems (Shanghai) PTE LTD
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

const
  ETH_CRC_LEN* = (4)            ##
                  ##  @brief Ethernet frame CRC length
                  ##
                  ##

type
  eth_data_interface_t* {.size: sizeof(cint), header: "eth_types.h".} = enum ##
                                                 ##  @brief Ethernet interface
                                                 ##
                                                 ##
    EMAC_DATA_INTERFACE_RMII, ## !< Reduced Media Independent Interface
    EMAC_DATA_INTERFACE_MII   ## !< Media Independent Interface

type
  eth_link_t* {.size: sizeof(cint), header: "eth_types.h".} = enum
    ETH_LINK_UP,              ## !< Ethernet link is up
    ETH_LINK_DOWN             ## !< Ethernet link is down

type
  eth_speed_t* {.size: sizeof(cint), header: "eth_types.h".} = enum
    ETH_SPEED_10M,            ## !< Ethernet speed is 10Mbps
    ETH_SPEED_100M,           ## !< Ethernet speed is 100Mbps
    ETH_SPEED_MAX             ## !< Max speed mode (for checking purpose)

type
  eth_duplex_t* {.size: sizeof(cint), header: "eth_types.h".} = enum
    ETH_DUPLEX_HALF,          ## !< Ethernet is in half duplex
    ETH_DUPLEX_FULL           ## !< Ethernet is in full duplex

type
  eth_checksum_t* {.size: sizeof(cint), header: "eth_types.h".} = enum
    ETH_CHECKSUM_SW,          ## !< Ethernet checksum calculate by software
    ETH_CHECKSUM_HW           ## !< Ethernet checksum calculate by hardware

##
##  @brief Ethernet link status
##
##

##
##  @brief Ethernet speed
##
##

##
##  @brief Ethernet duplex mode
##
##

##
##  @brief Ethernet Checksum
##
