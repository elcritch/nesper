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

import ../../consts

## *
##  @brief I2C port number, can be I2C_NUM_0 ~ (I2C_NUM_MAX-1).
##

type
  i2c_port_t* = distinct cint

  i2c_mode_t* {.size: sizeof(cint).} = enum
    I2C_MODE_SLAVE = 0,       ## !< I2C slave mode
    I2C_MODE_MASTER,          ## !< I2C master mode
    I2C_MODE_MAX

  i2c_rw_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_WRITE = 0,       ## !< I2C write data
    I2C_MASTER_READ           ## !< I2C read data

  i2c_opmode_t* {.size: sizeof(cint).} = enum
    I2C_CMD_RESTART = 0,      ## !<I2C restart command
    I2C_CMD_WRITE,            ## !<I2C write command
    I2C_CMD_READ,             ## !<I2C read command
    I2C_CMD_STOP,             ## !<I2C stop command
    I2C_CMD_END               ## !<I2C end command

  i2c_trans_mode_t* {.size: sizeof(cint).} = enum
    I2C_DATA_MODE_MSB_FIRST = 0, ## !< I2C data msb first
    I2C_DATA_MODE_LSB_FIRST = 1, ## !< I2C data lsb first
    I2C_DATA_MODE_MAX

  i2c_addr_mode_t* {.size: sizeof(cint).} = enum
    I2C_ADDR_BIT_7 = 0,       ## !< I2C 7bit address for slave mode
    I2C_ADDR_BIT_10,          ## !< I2C 10bit address for slave mode
    I2C_ADDR_BIT_MAX

  i2c_ack_type_t* {.size: sizeof(cint).} = enum
    I2C_MASTER_ACK = 0x00000000,  ## !< I2C ack for each byte read
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
    clk_speed* {.importc: "clk_speed".}: uint32 ## !< I2C clock frequency for master mode, (no higher than 1MHz for now)

  INNER_C_STRUCT_i2c_types_88* {.importc: "no_name", header: "i2c_types.h", bycopy.} = object
    addr_10bit_en* {.importc: "addr_10bit_en".}: uint8 ## !< I2C 10bit address mode enable for slave mode
    slave_addr* {.importc: "slave_addr".}: uint16 ## !< I2C address for slave mode

  INNER_C_UNION_i2c_types_84* {.importc: "no_name", header: "i2c_types.h", bycopy, union.} = object
    master* {.importc: "master".}: INNER_C_STRUCT_i2c_types_85 ## !< I2C master config
    slave* {.importc: "slave".}: INNER_C_STRUCT_i2c_types_88 ## !< I2C slave config

  i2c_config_t* {.importc: "i2c_config_t", header: "i2c_types.h", bycopy.} = object
    mode* {.importc: "mode".}: i2c_mode_t ## !< I2C mode
    sda_io_num* {.importc: "sda_io_num".}: cint ## !< GPIO number for I2C sda signal
    scl_io_num* {.importc: "scl_io_num".}: cint ## !< GPIO number for I2C scl signal
    sda_pullup_en* {.importc: "sda_pullup_en".}: bool ## !< Internal GPIO pull mode for I2C sda signal
    scl_pullup_en* {.importc: "scl_pullup_en".}: bool ## !< Internal GPIO pull mode for I2C scl signal
    ano_i2c_types_91* {.importc: "ano_i2c_types_91".}: INNER_C_UNION_i2c_types_84


var I2C_APB_CLK_FREQ* {.importc: "APB_CLK_FREQ", header: "<driver/i2c.h>".}: cint
var I2C_NUM_MAX* {.importc: "SOC_I2C_NUM", header: "<driver/i2c.h>".}: cint

const
  I2C_NUM_0* = 0              ## !< I2C port 0
  I2C_NUM_1* = 1              ## !< I2C port 1

type
  i2c_cmd_handle_t* = distinct pointer

## !< I2C command handle
## *
##  @brief I2C driver install
##
##  @param i2c_num I2C port number
##  @param mode I2C mode( master or slave )
##  @param slv_rx_buf_len receiving buffer size for slave mode
##         @note
##         Only slave mode will use this value, driver will ignore this value in master mode.
##  @param slv_tx_buf_len sending buffer size for slave mode
##         @note
##         Only slave mode will use this value, driver will ignore this value in master mode.
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##             ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##         @note
##         In master mode, if the cache is likely to be disabled(such as write flash) and the slave is time-sensitive,
##         `ESP_INTR_FLAG_IRAM` is suggested to be used. In this case, please use the memory allocated from internal RAM in i2c read and write function,
##         because we can not access the psram(if psram is enabled) in interrupt handle function when cache is disabled.
##
##  @return
##      - ESP_OK   Success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_FAIL Driver install error
##

proc i2c_driver_install*(i2c_num: i2c_port_t; mode: i2c_mode_t;
                        slv_rx_buf_len: csize_t; slv_tx_buf_len: csize_t;
                        intr_alloc_flags: cint): esp_err_t {.
    importc: "i2c_driver_install", header: "driver/i2c.h".}
## *
##  @brief I2C driver delete
##
##  @param i2c_num I2C port number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_driver_delete*(i2c_num: i2c_port_t): esp_err_t {.
    importc: "i2c_driver_delete", header: "driver/i2c.h".}
## *
##  @brief I2C parameter initialization
##
##  @param i2c_num I2C port number
##  @param i2c_conf pointer to I2C parameter settings
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_param_config*(i2c_num: i2c_port_t; i2c_conf: ptr i2c_config_t): esp_err_t {.
    importc: "i2c_param_config", header: "i2c.h".}
## *
##  @brief reset I2C tx hardware fifo
##
##  @param i2c_num I2C port number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_reset_tx_fifo*(i2c_num: i2c_port_t): esp_err_t {.
    importc: "i2c_reset_tx_fifo", header: "i2c.h".}
## *
##  @brief reset I2C rx fifo
##
##  @param i2c_num I2C port number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_reset_rx_fifo*(i2c_num: i2c_port_t): esp_err_t {.
    importc: "i2c_reset_rx_fifo", header: "i2c.h".}
## *
##  @brief I2C isr handler register
##
##  @param i2c_num I2C port number
##  @param fn isr handler function
##  @param arg parameter for isr handler function
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##             ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##  @param handle handle return from esp_intr_alloc.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_isr_register*(i2c_num: i2c_port_t; fn: proc (a1: pointer) {.cdecl.}; arg: pointer;
                      intr_alloc_flags: cint; handle: ptr intr_handle_t): esp_err_t {.
    importc: "i2c_isr_register", header: "i2c.h".}
## *
##  @brief to delete and free I2C isr.
##
##  @param handle handle of isr.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_isr_free*(handle: intr_handle_t): esp_err_t {.importc: "i2c_isr_free",
    header: "i2c.h".}
## *
##  @brief Configure GPIO signal for I2C sck and sda
##
##  @param i2c_num I2C port number
##  @param sda_io_num GPIO number for I2C sda signal
##  @param scl_io_num GPIO number for I2C scl signal
##  @param sda_pullup_en Whether to enable the internal pullup for sda pin
##  @param scl_pullup_en Whether to enable the internal pullup for scl pin
##  @param mode I2C mode
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_pin*(i2c_num: i2c_port_t; sda_io_num: cint; scl_io_num: cint;
                 sda_pullup_en: bool; scl_pullup_en: bool; mode: i2c_mode_t): esp_err_t {.
    importc: "i2c_set_pin", header: "i2c.h".}
## *
##  @brief Create and init I2C command link
##         @note
##         Before we build I2C command link, we need to call i2c_cmd_link_create() to create
##         a command link.
##         After we finish sending the commands, we need to call i2c_cmd_link_delete() to
##         release and return the resources.
##
##  @return i2c command link handler
##

proc i2c_cmd_link_create*(): i2c_cmd_handle_t {.importc: "i2c_cmd_link_create",
    header: "i2c.h".}
## *
##  @brief Free I2C command link
##         @note
##         Before we build I2C command link, we need to call i2c_cmd_link_create() to create
##         a command link.
##         After we finish sending the commands, we need to call i2c_cmd_link_delete() to
##         release and return the resources.
##
##  @param cmd_handle I2C command handle
##

proc i2c_cmd_link_delete*(cmd_handle: i2c_cmd_handle_t) {.
    importc: "i2c_cmd_link_delete", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to generate a start signal
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_start*(cmd_handle: i2c_cmd_handle_t): esp_err_t {.
    importc: "i2c_master_start", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to write one byte to I2C bus
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##  @param data I2C one byte command to write to bus
##  @param ack_en enable ack check for master
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_write_byte*(cmd_handle: i2c_cmd_handle_t; data: uint8; ack_en: bool): esp_err_t {.
    importc: "i2c_master_write_byte", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to write buffer to I2C bus
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##  @param data data to send
##         @note
##         If the psram is enabled and intr_flag is `ESP_INTR_FLAG_IRAM`, please use the memory allocated from internal RAM.
##  @param data_len data length
##  @param ack_en enable ack check for master
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_write*(cmd_handle: i2c_cmd_handle_t; data: ptr uint8;
                      data_len: csize_t; ack_en: bool): esp_err_t {.
    importc: "i2c_master_write", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to read one byte from I2C bus
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##  @param data pointer accept the data byte
##         @note
##         If the psram is enabled and intr_flag is `ESP_INTR_FLAG_IRAM`, please use the memory allocated from internal RAM.
##  @param ack ack value for read command
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_read_byte*(cmd_handle: i2c_cmd_handle_t; data: ptr uint8;
                          ack: i2c_ack_type_t): esp_err_t {.
    importc: "i2c_master_read_byte", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to read data from I2C bus
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##  @param data data buffer to accept the data from bus
##         @note
##         If the psram is enabled and intr_flag is `ESP_INTR_FLAG_IRAM`, please use the memory allocated from internal RAM.
##  @param data_len read data length
##  @param ack ack value for read command
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_read*(cmd_handle: i2c_cmd_handle_t; data: ptr uint8;
                     data_len: csize_t; ack: i2c_ack_type_t): esp_err_t {.
    importc: "i2c_master_read", header: "i2c.h".}
## *
##  @brief Queue command for I2C master to generate a stop signal
##         @note
##         Only call this function in I2C master mode
##         Call i2c_master_cmd_begin() to send all queued commands
##
##  @param cmd_handle I2C cmd link
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_master_stop*(cmd_handle: i2c_cmd_handle_t): esp_err_t {.
    importc: "i2c_master_stop", header: "i2c.h".}
## *
##  @brief I2C master send queued commands.
##         This function will trigger sending all queued commands.
##         The task will be blocked until all the commands have been sent out.
##         The I2C APIs are not thread-safe, if you want to use one I2C port in different tasks,
##         you need to take care of the multi-thread issue.
##         @note
##         Only call this function in I2C master mode
##
##  @param i2c_num I2C port number
##  @param cmd_handle I2C command handler
##  @param ticks_to_wait maximum wait ticks.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_FAIL Sending command error, slave doesn't ACK the transfer.
##      - ESP_ERR_INVALID_STATE I2C driver not installed or not in master mode.
##      - ESP_ERR_TIMEOUT Operation timeout because the bus is busy.
##

proc i2c_master_cmd_begin*(i2c_num: i2c_port_t; cmd_handle: i2c_cmd_handle_t;
                          ticks_to_wait: TickType_t): esp_err_t {.
    importc: "i2c_master_cmd_begin", header: "i2c.h".}
## *
##  @brief I2C slave write data to internal ringbuffer, when tx fifo empty, isr will fill the hardware
##         fifo from the internal ringbuffer
##         @note
##         Only call this function in I2C slave mode
##
##  @param i2c_num I2C port number
##  @param data data pointer to write into internal buffer
##  @param size data size
##  @param ticks_to_wait Maximum waiting ticks
##
##  @return
##      - ESP_FAIL(-1) Parameter error
##      - Others(>=0) The number of data bytes that pushed to the I2C slave buffer.
##

proc i2c_slave_write_buffer*(i2c_num: i2c_port_t; data: ptr uint8; size: cint;
                            ticks_to_wait: TickType_t): cint {.
    importc: "i2c_slave_write_buffer", header: "i2c.h".}
## *
##  @brief I2C slave read data from internal buffer. When I2C slave receive data, isr will copy received data
##         from hardware rx fifo to internal ringbuffer. Then users can read from internal ringbuffer.
##         @note
##         Only call this function in I2C slave mode
##
##  @param i2c_num I2C port number
##  @param data data pointer to accept data from internal buffer
##  @param max_size Maximum data size to read
##  @param ticks_to_wait Maximum waiting ticks
##
##  @return
##      - ESP_FAIL(-1) Parameter error
##      - Others(>=0) The number of data bytes that read from I2C slave buffer.
##

proc i2c_slave_read_buffer*(i2c_num: i2c_port_t; data: ptr uint8; max_size: csize_t;
                           ticks_to_wait: TickType_t): cint {.
    importc: "i2c_slave_read_buffer", header: "i2c.h".}
## *
##  @brief set I2C master clock period
##
##  @param i2c_num I2C port number
##  @param high_period clock cycle number during SCL is high level, high_period is a 14 bit value
##  @param low_period clock cycle number during SCL is low level, low_period is a 14 bit value
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_period*(i2c_num: i2c_port_t; high_period: cint; low_period: cint): esp_err_t {.
    importc: "i2c_set_period", header: "i2c.h".}
## *
##  @brief get I2C master clock period
##
##  @param i2c_num I2C port number
##  @param high_period pointer to get clock cycle number during SCL is high level, will get a 14 bit value
##  @param low_period pointer to get clock cycle number during SCL is low level, will get a 14 bit value
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_period*(i2c_num: i2c_port_t; high_period: ptr cint; low_period: ptr cint): esp_err_t {.
    importc: "i2c_get_period", header: "i2c.h".}
## *
##  @brief enable hardware filter on I2C bus
##         Sometimes the I2C bus is disturbed by high frequency noise(about 20ns), or the rising edge of
##         the SCL clock is very slow, these may cause the master state machine broken. enable hardware
##         filter can filter out high frequency interference and make the master more stable.
##         @note
##         Enable filter will slow the SCL clock.
##
##  @param i2c_num I2C port number
##  @param cyc_num the APB cycles need to be filtered(0<= cyc_num <=7).
##         When the period of a pulse is less than cyc_num * APB_cycle, the I2C controller will ignore this pulse.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_filter_enable*(i2c_num: i2c_port_t; cyc_num: uint8): esp_err_t {.
    importc: "i2c_filter_enable", header: "i2c.h".}
## *
##  @brief disable filter on I2C bus
##
##  @param i2c_num I2C port number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_filter_disable*(i2c_num: i2c_port_t): esp_err_t {.
    importc: "i2c_filter_disable", header: "i2c.h".}
## *
##  @brief set I2C master start signal timing
##
##  @param i2c_num I2C port number
##  @param setup_time clock number between the falling-edge of SDA and rising-edge of SCL for start mark, it's a 10-bit value.
##  @param hold_time clock num between the falling-edge of SDA and falling-edge of SCL for start mark, it's a 10-bit value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_start_timing*(i2c_num: i2c_port_t; setup_time: cint; hold_time: cint): esp_err_t {.
    importc: "i2c_set_start_timing", header: "i2c.h".}
## *
##  @brief get I2C master start signal timing
##
##  @param i2c_num I2C port number
##  @param setup_time pointer to get setup time
##  @param hold_time pointer to get hold time
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_start_timing*(i2c_num: i2c_port_t; setup_time: ptr cint;
                          hold_time: ptr cint): esp_err_t {.
    importc: "i2c_get_start_timing", header: "i2c.h".}
## *
##  @brief set I2C master stop signal timing
##
##  @param i2c_num I2C port number
##  @param setup_time clock num between the rising-edge of SCL and the rising-edge of SDA, it's a 10-bit value.
##  @param hold_time clock number after the STOP bit's rising-edge, it's a 14-bit value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_stop_timing*(i2c_num: i2c_port_t; setup_time: cint; hold_time: cint): esp_err_t {.
    importc: "i2c_set_stop_timing", header: "i2c.h".}
## *
##  @brief get I2C master stop signal timing
##
##  @param i2c_num I2C port number
##  @param setup_time pointer to get setup time.
##  @param hold_time pointer to get hold time.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_stop_timing*(i2c_num: i2c_port_t; setup_time: ptr cint;
                         hold_time: ptr cint): esp_err_t {.
    importc: "i2c_get_stop_timing", header: "i2c.h".}
## *
##  @brief set I2C data signal timing
##
##  @param i2c_num I2C port number
##  @param sample_time clock number I2C used to sample data on SDA after the rising-edge of SCL, it's a 10-bit value
##  @param hold_time clock number I2C used to hold the data after the falling-edge of SCL, it's a 10-bit value
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_data_timing*(i2c_num: i2c_port_t; sample_time: cint; hold_time: cint): esp_err_t {.
    importc: "i2c_set_data_timing", header: "i2c.h".}
## *
##  @brief get I2C data signal timing
##
##  @param i2c_num I2C port number
##  @param sample_time pointer to get sample time
##  @param hold_time pointer to get hold time
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_data_timing*(i2c_num: i2c_port_t; sample_time: ptr cint;
                         hold_time: ptr cint): esp_err_t {.
    importc: "i2c_get_data_timing", header: "i2c.h".}
## *
##  @brief set I2C timeout value
##  @param i2c_num I2C port number
##  @param timeout timeout value for I2C bus (unit: APB 80Mhz clock cycle)
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_timeout*(i2c_num: i2c_port_t; timeout: cint): esp_err_t {.
    importc: "i2c_set_timeout", header: "i2c.h".}
## *
##  @brief get I2C timeout value
##  @param i2c_num I2C port number
##  @param timeout pointer to get timeout value
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_timeout*(i2c_num: i2c_port_t; timeout: ptr cint): esp_err_t {.
    importc: "i2c_get_timeout", header: "i2c.h".}
## *
##  @brief set I2C data transfer mode
##
##  @param i2c_num I2C port number
##  @param tx_trans_mode I2C sending data mode
##  @param rx_trans_mode I2C receving data mode
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_set_data_mode*(i2c_num: i2c_port_t; tx_trans_mode: i2c_trans_mode_t;
                       rx_trans_mode: i2c_trans_mode_t): esp_err_t {.
    importc: "i2c_set_data_mode", header: "i2c.h".}
## *
##  @brief get I2C data transfer mode
##
##  @param i2c_num I2C port number
##  @param tx_trans_mode pointer to get I2C sending data mode
##  @param rx_trans_mode pointer to get I2C receiving data mode
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc i2c_get_data_mode*(i2c_num: i2c_port_t; tx_trans_mode: ptr i2c_trans_mode_t;
                       rx_trans_mode: ptr i2c_trans_mode_t): esp_err_t {.
    importc: "i2c_get_data_mode", header: "i2c.h".}