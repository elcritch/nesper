##
##  SPDX-FileCopyrightText: 2023-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

when not CONFIG_I2C_ENABLE_SLAVE_DRIVER_VERSION_2:
  ##
  ##  @brief I2C slave specific configurations
  ##
  type
    INNER_C_STRUCT_i2c_slave_1* {.importc: "i2c_slave_config_t::no_name",
                                  header: "i2c_slave.h", bycopy.} = object
      stretch_en* {.importc: "stretch_en", bitsize: 1.}: uint32
      ## !< Enable slave stretch
      broadcast_en* {.importc: "broadcast_en", bitsize: 1.}: uint32
      ## !< I2C slave enable broadcast
      access_ram_en* {.importc: "access_ram_en", bitsize: 1.}: uint32
      ## !< Can get access to I2C RAM directly
      slave_unmatch_en* {.importc: "slave_unmatch_en", bitsize: 1.}: uint32
      ## !< Can trigger unmatch interrupt when slave address does not match what master sends
      allow_pd* {.importc: "allow_pd", bitsize: 1.}: uint32
      ## !< If set, the driver will backup/restore the I2C registers before/after entering/exist sleep mode.
      ##                                               By this approach, the system can power off I2C's power domain.
      ##                                               This can save power, but at the expense of more RAM being consumed

  type
    i2c_slave_config_t* {.importc: "i2c_slave_config_t", header: "i2c_slave.h",
                          bycopy.} = object
      i2c_port* {.importc: "i2c_port".}: i2c_port_num_t
      ## !< I2C port number, `-1` for auto selecting
      sda_io_num* {.importc: "sda_io_num".}: gpio_num_t
      ## !< SDA IO number used by I2C bus
      scl_io_num* {.importc: "scl_io_num".}: gpio_num_t
      ## !< SCL IO number used by I2C bus
      clk_source* {.importc: "clk_source".}: i2c_clock_source_t
      ## !< Clock source of I2C bus.
      send_buf_depth* {.importc: "send_buf_depth".}: uint32
      ## !< Depth of internal transfer ringbuffer, increase this value can support more transfers pending in the background
      slave_addr* {.importc: "slave_addr".}: uint16
      ## !< I2C slave address
      addr_bit_len* {.importc: "addr_bit_len".}: i2c_addr_bit_len_t
      ## !< I2C slave address in bit length
      intr_priority* {.importc: "intr_priority".}: cint
      ## !< I2C interrupt priority, if set to 0, driver will select the default priority (1,2,3).
      flags* {.importc: "flags".}: INNER_C_STRUCT_i2c_slave_1
      ## !< I2C slave config flags

  ##
  ##  @brief Group of I2C slave callbacks (e.g. get i2c slave stretch cause). But take care of potential concurrency issues.
  ##  @note The callbacks are all running under ISR context
  ##  @note When CONFIG_I2C_ISR_IRAM_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
  ##        The variables used in the function should be in the SRAM as well.
  ##
  type
    i2c_slave_event_callbacks_t* {.importc: "i2c_slave_event_callbacks_t",
                                   header: "i2c_slave.h", bycopy.} = object
      on_recv_done* {.importc: "on_recv_done".}: i2c_slave_received_callback_t
      ## !< I2C slave receive done callback

  ##
  ##  @brief Read bytes from I2C internal buffer. Start a job to receive I2C data.
  ##
  ##  @note This function is non-blocking, it initiates a new receive job and then returns.
  ##        User should check the received data from the `on_recv_done` callback that registered by `i2c_slave_register_event_callbacks()`.
  ##
  ##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
  ##  @param[out] data Buffer to store data from I2C fifo. Should be valid until `on_recv_done` is triggered.
  ##  @param[in] buffer_size Buffer size of data that provided by users.
  ##  @return
  ##       - ESP_OK: I2C slave receive success.
  ##       - ESP_ERR_INVALID_ARG: I2C slave receive parameter invalid.
  ##       - ESP_ERR_NOT_SUPPORTED: This function should be work in fifo mode, but I2C_SLAVE_NONFIFO mode is configured
  ##
  proc i2c_slave_receive*(i2c_slave: i2c_slave_dev_handle_t; data: ptr uint8;
                          buffer_size: csize_t): esp_err_t {.cdecl,
      importc: "i2c_slave_receive", header: "i2c_slave.h".}
  ##
  ##  @brief Write bytes to internal ringbuffer of the I2C slave data. When the TX fifo empty, the ISR will
  ##         fill the hardware FIFO with the internal ringbuffer's data.
  ##
  ##  @note If you connect this slave device to some master device, the data transaction direction is from slave
  ##        device to master device.
  ##
  ##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
  ##  @param[in] data Buffer to write to slave fifo, can pickup by master. Can be freed after this function returns. Equal or larger than `size`.
  ##  @param[in] size In bytes, of `data` buffer.
  ##  @param[in] xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
  ##  @return
  ##       - ESP_OK: I2C slave transmit success.
  ##       - ESP_ERR_INVALID_ARG: I2C slave transmit parameter invalid.
  ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the device is busy or hardware crash.
  ##       - ESP_ERR_NOT_SUPPORTED: This function should be work in fifo mode, but I2C_SLAVE_NONFIFO mode is configured
  ##
  proc i2c_slave_transmit*(i2c_slave: i2c_slave_dev_handle_t; data: ptr uint8;
                           size: cint; xfer_timeout_ms: cint): esp_err_t {.
      cdecl, importc: "i2c_slave_transmit", header: "i2c_slave.h".}
  when SOC_I2C_SLAVE_SUPPORT_I2CRAM_ACCESS:
    ##
    ##  @brief Read bytes from I2C internal ram. This can be only used when `access_ram_en` in configuration structure set to true.
    ##
    ##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
    ##  @param[in] ram_address The offset of RAM (Cannot larger than I2C RAM memory)
    ##  @param[out] data Buffer to store data read from I2C ram.
    ##  @param[in] receive_size Received size from RAM.
    ##  @return
    ##       - ESP_OK: I2C slave transmit success.
    ##       - ESP_ERR_INVALID_ARG: I2C slave transmit parameter invalid.
    ##       - ESP_ERR_NOT_SUPPORTED: This function should be work in non-fifo mode, but I2C_SLAVE_FIFO mode is configured
    ##
    proc i2c_slave_read_ram*(i2c_slave: i2c_slave_dev_handle_t;
                             ram_address: uint8; data: ptr uint8;
                             receive_size: csize_t): esp_err_t {.cdecl,
        importc: "i2c_slave_read_ram", header: "i2c_slave.h".}
    ##
    ##  @brief Write bytes to I2C internal ram. This can be only used when `access_ram_en` in configuration structure set to true.
    ##
    ##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
    ##  @param[in] ram_address The offset of RAM (Cannot larger than I2C RAM memory)
    ##  @param[in] data Buffer to fill.
    ##  @param[in] size Received size from RAM.
    ##  @return
    ##       - ESP_OK: I2C slave transmit success.
    ##       - ESP_ERR_INVALID_ARG: I2C slave transmit parameter invalid.
    ##       - ESP_ERR_INVALID_SIZE: Write size is larger than
    ##       - ESP_ERR_NOT_SUPPORTED: This function should be work in non-fifo mode, but I2C_SLAVE_FIFO mode is configured
    ##
    proc i2c_slave_write_ram*(i2c_slave: i2c_slave_dev_handle_t;
                              ram_address: uint8; data: ptr uint8; size: csize_t): esp_err_t {.
        cdecl, importc: "i2c_slave_write_ram", header: "i2c_slave.h".}
else:
  ##
  ##  @brief I2C slave specific configurations
  ##
  type
    INNER_C_STRUCT_i2c_slave_3* {.importc: "i2c_slave_config_t::no_name",
                                  header: "i2c_slave.h", bycopy.} = object
      allow_pd* {.importc: "allow_pd", bitsize: 1.}: uint32
      ## !< If set, the driver will backup/restore the I2C registers before/after entering/exist sleep mode.
      ##                                               By this approach, the system can power off I2C's power domain.
      ##                                               This can save power, but at the expense of more RAM being consumed
      enable_internal_pullup* {.importc: "enable_internal_pullup", bitsize: 1.}: uint32
      ## !< Enable internal pullups. Note: This is not strong enough to pullup buses under high-speed frequency. Recommend proper external pull-up if possible
      broadcast_en* {.importc: "broadcast_en", bitsize: 1.}: uint32
      ## !< I2C slave enable broadcast, able to respond to broadcast address

  type
    i2c_slave_config_t* {.importc: "i2c_slave_config_t", header: "i2c_slave.h",
                          bycopy.} = object
      i2c_port* {.importc: "i2c_port".}: i2c_port_num_t
      ## !< I2C port number, `-1` for auto selecting
      sda_io_num* {.importc: "sda_io_num".}: gpio_num_t
      ## !< SDA IO number used by I2C bus
      scl_io_num* {.importc: "scl_io_num".}: gpio_num_t
      ## !< SCL IO number used by I2C bus
      clk_source* {.importc: "clk_source".}: i2c_clock_source_t
      ## !< Clock source of I2C bus.
      send_buf_depth* {.importc: "send_buf_depth".}: uint32
      ## !< Depth of internal transfer ringbuffer
      receive_buf_depth* {.importc: "receive_buf_depth".}: uint32
      ## !< Depth of receive internal software buffer
      slave_addr* {.importc: "slave_addr".}: uint16
      ## !< I2C slave address
      addr_bit_len* {.importc: "addr_bit_len".}: i2c_addr_bit_len_t
      ## !< I2C slave address in bit length
      intr_priority* {.importc: "intr_priority".}: cint
      ## !< I2C interrupt priority, if set to 0, driver will select the default priority (1,2,3).
      flags* {.importc: "flags".}: INNER_C_STRUCT_i2c_slave_3
      ## !< I2C slave config flags

  ##
  ##  @brief Group of I2C slave callbacks. Take care of potential concurrency issues.
  ##  @note The callbacks are all running under ISR context
  ##  @note When CONFIG_I2C_ISR_IRAM_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
  ##        The variables used in the function should be in the SRAM as well.
  ##
  type
    i2c_slave_event_callbacks_t* {.importc: "i2c_slave_event_callbacks_t",
                                   header: "i2c_slave.h", bycopy.} = object
      on_request* {.importc: "on_request".}: i2c_slave_request_callback_t
      ## !< Callback for when a master requests data from the slave
      on_receive* {.importc: "on_receive".}: i2c_slave_received_callback_t
      ## !< Callback for when the slave receives data from the master

  ##
  ##  @brief Write buffer to hardware fifo. If write length is larger than hardware fifo, then restore in software buffer.
  ##
  ##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
  ##  @param[in] data Buffer to write to slave fifo, can pickup by master.
  ##  @param[in] len In bytes, of `data` buffer.
  ##  @param[out] write_len In bytes, actually write length.
  ##  @param[in] timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
  ##  @return
  ##       - ESP_OK: I2C slave write success.
  ##       - ESP_ERR_INVALID_ARG: I2C slave write parameter invalid.
  ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the device is busy or hardware crash.
  ##
  proc i2c_slave_write*(i2c_slave: i2c_slave_dev_handle_t; data: ptr uint8;
                        len: uint32; write_len: ptr uint32; timeout_ms: cint): esp_err_t {.
      cdecl, importc: "i2c_slave_write", header: "i2c_slave.h".}
##
##  @brief Initialize an I2C slave device
##
##  @param[in] slave_config I2C slave device configurations
##  @param[out] ret_handle Return a generic I2C device handle
##  @return
##       - ESP_OK: I2C slave device initialized successfully
##       - ESP_ERR_INVALID_ARG: I2C device initialization failed because of invalid argument.
##       - ESP_ERR_NO_MEM: Create I2C device failed because of out of memory.
##

proc i2c_new_slave_device*(slave_config: ptr i2c_slave_config_t;
                           ret_handle: ptr i2c_slave_dev_handle_t): esp_err_t {.
    cdecl, importc: "i2c_new_slave_device", header: "i2c_slave.h".}
##
##  @brief Set I2C slave event callbacks for I2C slave channel.
##
##  @note User can deregister a previously registered callback by calling this function and setting the callback member in the `cbs` structure to NULL.
##  @note When CONFIG_I2C_ISR_IRAM_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
##        The variables used in the function should be in the SRAM as well. The `user_data` should also reside in SRAM.
##
##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
##  @param[in] cbs Group of callback functions
##  @param[in] user_data User data, which will be passed to callback functions directly
##  @return
##       - ESP_OK: Set I2C transaction callbacks successfully
##       - ESP_ERR_INVALID_ARG: Set I2C transaction callbacks failed because of invalid argument
##       - ESP_FAIL: Set I2C transaction callbacks failed because of other error
##

proc i2c_slave_register_event_callbacks*(i2c_slave: i2c_slave_dev_handle_t;
    cbs: ptr i2c_slave_event_callbacks_t; user_data: pointer): esp_err_t {.
    cdecl, importc: "i2c_slave_register_event_callbacks", header: "i2c_slave.h".}
##
##  @brief Deinitialize the I2C slave device
##
##  @param[in] i2c_slave I2C slave device handle that created by `i2c_new_slave_device`.
##  @return
##       - ESP_OK: Delete I2C device successfully.
##       - ESP_ERR_INVALID_ARG: I2C device initialization failed because of invalid argument.
##

proc i2c_del_slave_device*(i2c_slave: i2c_slave_dev_handle_t): esp_err_t {.
    cdecl, importc: "i2c_del_slave_device", header: "i2c_slave.h".}