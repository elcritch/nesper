##
##  SPDX-FileCopyrightText: 2015-2025 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

const hdr = "<hal/i2c_types.h>"

type

  i2c_port_t* = distinct cint

let
  I2C_NUM_0* {.importc: "I2C_NUM_0", header: hdr.}: i2c_port_t
  I2C_NUM_1* {.importc: "I2C_NUM_1", header: hdr.}: i2c_port_t
  LP_I2C_NUM_0* {.importc: "LP_I2C_NUM_0", header: hdr.}: i2c_port_t

type

  i2c_addr_bit_len_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enumeration for I2C device address bit length
                              ##
    I2C_ADDR_BIT_LEN_7 = 0, ## !< i2c address bit length 7
                             ##  #if SOC_I2C_SUPPORT_10BIT_ADDR
    I2C_ADDR_BIT_LEN_10 = 1  ## !< i2c address bit length 10
                             ##  #endif


type                        ##  #if SOC_I2C_SUPPORT_SLAVE

  i2c_hal_clk_config_t* {.importc: "i2c_hal_clk_config_t", header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Data structure for calculating I2C bus timing.
                              ##
    clkm_div* {.importc: "clkm_div".}: uint16 ## !< I2C core clock divider
    scl_low* {.importc: "scl_low".}: uint16 ## !< I2C scl low period
    scl_high* {.importc: "scl_high".}: uint16 ## !< I2C scl high period
    scl_wait_high* {.importc: "scl_wait_high".}: uint16 ##
                              ## !< I2C scl wait_high period
    sda_hold* {.importc: "sda_hold".}: uint16 ## !< I2C scl low period
    sda_sample* {.importc: "sda_sample".}: uint16 ## !< I2C sda sample time
    setup* {.importc: "setup".}: uint16 ## !< I2C start and stop condition setup period
    hold* {.importc: "hold".}: uint16 ## !< I2C start and stop condition hold period
    tout* {.importc: "tout".}: uint16
    ## !< I2C bus timeout period


  i2c_mode_t* = distinct cint

let
  I2C_MODE_SLAVE* {.importc: "I2C_MODE_SLAVE", header: hdr.}: i2c_mode_t
  I2C_MODE_MASTER* {.importc: "I2C_MODE_MASTER", header: hdr.}: i2c_mode_t
  I2C_MODE_MAX* {.importc: "I2C_MODE_MAX", header: hdr.}: i2c_mode_t

type
  i2c_rw_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_WRITE = 0,   ## !< I2C write data
    I2C_MASTER_READ          ## !< I2C read data

  i2c_trans_mode_t* {.size: sizeof(cint).} = enum
    I2C_DATA_MODE_MSB_FIRST = 0, ## !< I2C data msb first
    I2C_DATA_MODE_LSB_FIRST = 1, ## !< I2C data lsb first
    I2C_DATA_MODE_MAX

  i2c_ack_type_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_ACK = 0x0,   ## !< I2C ack for each byte read
    I2C_MASTER_NACK = 0x1,  ## !< I2C nack for each byte read
    I2C_MASTER_LAST_NACK = 0x2, ## !< I2C nack for the last byte
    I2C_MASTER_ACK_MAX


type

  i2c_slave_stretch_cause_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enum for I2C slave stretch causes
                              ##
    I2C_SLAVE_STRETCH_CAUSE_ADDRESS_MATCH = 0, ## !< Stretching SCL low when the slave is read by the master and the address just matched
    I2C_SLAVE_STRETCH_CAUSE_TX_EMPTY = 1, ## !< Stretching SCL low when TX FIFO is empty in slave mode
    I2C_SLAVE_STRETCH_CAUSE_RX_FULL = 2, ## !< Stretching SCL low when RX FIFO is full in slave mode
    I2C_SLAVE_STRETCH_CAUSE_SENDING_ACK = 3 ## !< Stretching SCL low when slave sending ACK

  i2c_slave_read_write_status_t* {.size: sizeof(cint).} = enum
    I2C_SLAVE_WRITE_BY_MASTER = 0, I2C_SLAVE_READ_BY_MASTER = 1


type

  i2c_bus_mode_t* {.size: sizeof(cint).} = enum ##
                                                 ##  @brief Enum for i2c working modes.
                                                 ##
    I2C_BUS_MODE_MASTER = 0, ## !< I2C works under master mode
    I2C_BUS_MODE_SLAVE = 1   ## !< I2C works under slave mode


type
  i2c_clock_source_t* {.importc: "i2c_clock_source_t", incompleteStruct, header: hdr.} = cint
  
let I2C_CLK_SRC_XTAL* {.importc: "I2C_CLK_SRC_XTAL", header: hdr.}: cint
let I2C_CLK_SRC_RC_FAST* {.importc: "I2C_CLK_SRC_RC_FAST", header: hdr.}: cint
let I2C_CLK_SRC_DEFAULT* {.importc: "I2C_CLK_SRC_DEFAULT", header: hdr.}: cint
