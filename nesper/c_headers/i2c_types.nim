##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
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

import
  soc/i2c_caps

## *
##  @brief I2C port number, can be I2C_NUM_0 ~ (I2C_NUM_MAX-1).
##

type
  i2c_port_t* = cint
  i2c_mode_t* {.size: sizeof(cint).} = enum
    I2C_MODE_SLAVE = 0,         ## !< I2C slave mode
    I2C_MODE_MASTER,          ## !< I2C master mode
    I2C_MODE_MAX
  i2c_rw_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_WRITE = 0,       ## !< I2C write data
    I2C_MASTER_READ           ## !< I2C read data
  i2c_opmode_t* {.size: sizeof(cint).} = enum
    I2C_CMD_RESTART = 0,        ## !<I2C restart command
    I2C_CMD_WRITE,            ## !<I2C write command
    I2C_CMD_READ,             ## !<I2C read command
    I2C_CMD_STOP,             ## !<I2C stop command
    I2C_CMD_END               ## !<I2C end command
  i2c_trans_mode_t* {.size: sizeof(cint).} = enum
    I2C_DATA_MODE_MSB_FIRST = 0, ## !< I2C data msb first
    I2C_DATA_MODE_LSB_FIRST = 1, ## !< I2C data lsb first
    I2C_DATA_MODE_MAX
  i2c_addr_mode_t* {.size: sizeof(cint).} = enum
    I2C_ADDR_BIT_7 = 0,         ## !< I2C 7bit address for slave mode
    I2C_ADDR_BIT_10,          ## !< I2C 10bit address for slave mode
    I2C_ADDR_BIT_MAX
  i2c_ack_type_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_ACK = 0x00000000, ## !< I2C ack for each byte read
    I2C_MASTER_NACK = 0x00000001, ## !< I2C nack for each byte read
    I2C_MASTER_LAST_NACK = 0x00000002, ## !< I2C nack for the last byte
    I2C_MASTER_ACK_MAX
  i2c_sclk_t* {.size: sizeof(cint).} = enum
    I2C_SCLK_REF_TICK,        ## !< I2C source clock from REF_TICK
    I2C_SCLK_APB              ## !< I2C source clock from APB








## *
##  @brief I2C initialization parameters
##

type
  INNER_C_STRUCT_i2c_types_85* {.importc: "no_name", header: "i2c_types.h", bycopy.} = object
    clk_speed* {.importc: "clk_speed".}: uint32_t ## !< I2C clock frequency for master mode, (no higher than 1MHz for now)

  INNER_C_STRUCT_i2c_types_88* {.importc: "no_name", header: "i2c_types.h", bycopy.} = object
    addr_10bit_en* {.importc: "addr_10bit_en".}: uint8_t ## !< I2C 10bit address mode enable for slave mode
    slave_addr* {.importc: "slave_addr".}: uint16_t ## !< I2C address for slave mode

  INNER_C_UNION_i2c_types_84* {.importc: "no_name", header: "i2c_types.h", bycopy.} = object {.
      union.}
    master* {.importc: "master".}: INNER_C_STRUCT_i2c_types_85 ## !< I2C master config
    slave* {.importc: "slave".}: INNER_C_STRUCT_i2c_types_88 ## !< I2C slave config

  i2c_config_t* {.importc: "i2c_config_t", header: "i2c_types.h", bycopy.} = object
    mode* {.importc: "mode".}: i2c_mode_t ## !< I2C mode
    sda_io_num* {.importc: "sda_io_num".}: cint ## !< GPIO number for I2C sda signal
    scl_io_num* {.importc: "scl_io_num".}: cint ## !< GPIO number for I2C scl signal
    sda_pullup_en* {.importc: "sda_pullup_en".}: bool ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en* {.importc: "scl_pullup_en".}: bool ## !< Internal GPIO pull mode for I2C scl signal
    ano_i2c_types_91* {.importc: "ano_i2c_types_91".}: INNER_C_UNION_i2c_types_84

