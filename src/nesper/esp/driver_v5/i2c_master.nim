##
##  SPDX-FileCopyrightText: 2023-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##
import std/strutils

import ../../consts
import ../driver/gpio_driver
import ../hal/i2c_types as i2c_hal_types

import ./i2c_types
export i2c_types
export i2c_hal_types

{.push header: "<driver/i2c_master.h>".}

type
  I2cAddr = distinct uint16

proc `$`*(a: I2cAddr): string = 
  result = toHex(a.uint16, 2)
proc `==`*(a, b: I2cAddr): bool {.borrow.}

type

  INNER_C_STRUCT_i2c_master_3* = object ##
                              ##
                              ##  @brief I2C master bus specific configurations
                              ##
    enable_internal_pullup* {.importc: "enable_internal_pullup", bitsize: 1.}: uint32 ##
                              ## !< Enable internal pullups. Note: This is not strong enough to pullup buses under high-speed frequency. Recommend proper external pull-up if possible
    allow_pd* {.importc: "allow_pd", bitsize: 1.}: uint32
    ## !< If set, the driver will backup/restore the I2C registers before/after entering/exist sleep mode.
    ##                                               By this approach, the system can power off I2C's power domain.
    ##                                               This can save power, but at the expense of more RAM being consumed


  i2c_master_bus_config_t* {.importc: "i2c_master_bus_config_t",
                              bycopy.} = object
    i2c_port* {.importc: "i2c_port".}: i2c_port_num_t ##
                              ## !< I2C port number, `-1` for auto selecting, (not include LP I2C instance)
    sda_io_num* {.importc: "sda_io_num".}: gpio_num_t ##
                              ## !< GPIO number of I2C SDA signal, pulled-up internally
    scl_io_num* {.importc: "scl_io_num".}: gpio_num_t ##
                              ## !< GPIO number of I2C SCL signal, pulled-up internally
    
    # anonymous union begin
    clk_source* {.importc: "clk_source".}: i2c_clock_source_t ##
                              ## !< Clock source of I2C master bus

    when defined(SOC_LP_I2C_SUPPORTED):
      lp_source_clk* {.header: "i2c_master.h".}: lp_i2c_clock_source_t
                              ## !< LP_UART source clock selection
    # anonymous union end

    glitch_ignore_cnt* {.importc: "glitch_ignore_cnt".}: uint8 ##
                              ## !< If the glitch period on the line is less than this value, it can be filtered out, typically value is 7 (unit: I2C module clock cycle)
    intr_priority* {.importc: "intr_priority".}: cint ##
                              ## !< I2C interrupt priority, if set to 0, driver will select the default priority (1,2,3).
    trans_queue_depth* {.importc: "trans_queue_depth".}: csize_t ##
                              ## !< Depth of internal transfer queue, increase this value can support more transfers pending in the background, only valid in asynchronous transaction. (Typically max_device_num * per_transaction)
    flags* {.importc: "flags".}: INNER_C_STRUCT_i2c_master_3
    ## !< I2C master config flags


const
  I2C_DEVICE_ADDRESS_NOT_USED* = (0xffff) ## !< Skip carry address bit in driver transmit and receive

type

  INNER_C_STRUCT_i2c_master_5* = object ##
                              ##
                              ##  @brief I2C device configuration
                              ##
    disable_ack_check* {.importc: "disable_ack_check", bitsize: 1.}: uint32
    ## !< Disable ACK check. If this is set false, that means ack check is enabled, the transaction will be stopped and API returns error when nack is detected.


  i2c_device_config_t* {.importc: "i2c_device_config_t", 
                         bycopy.} = object
    dev_addr_length* {.importc: "dev_addr_length".}: i2c_addr_bit_len_t ##
                              ## !< Select the address length of the slave device.
    device_address* {.importc: "device_address".}: I2cAddr ##
                              ## !< I2C device raw address. (The 7/10 bit address without read/write bit). Macro I2C_DEVICE_ADDRESS_NOT_USED (0xFFFF) stands for skip the address config inside driver.
    scl_speed_hz* {.importc: "scl_speed_hz".}: Hertz ##
                              ## !< I2C SCL line frequency.
    scl_wait_us* {.importc: "scl_wait_us".}: uint32 ##
                              ## !< Timeout value. (unit: us). Please note this value should not be so small that it can handle stretch/disturbance properly. If 0 is set, that means use the default reg value
    flags* {.importc: "flags".}: INNER_C_STRUCT_i2c_master_5
    ## !< I2C device config flags


  INNER_C_STRUCT_i2c_master_10* = object ##
                              ##
                              ##  @brief Structure representing an I2C operation job
                              ##
                              ##  This structure is used to define individual I2C operations (write or read)
                              ##  within a sequence of I2C master transactions.
                              ##
    ack_check* {.importc: "ack_check".}: bool ## < Whether to enable ACK check during WRITE operation
    data* {.importc: "data".}: ptr uint8 ## < Pointer to the data to be written
    total_bytes* {.importc: "total_bytes".}: csize_t
    ## < Total number of bytes to write


  INNER_C_STRUCT_i2c_master_11* = object
    ack_value* {.importc: "ack_value".}: i2c_ack_value_t ##
                              ## < ACK value to send after the read (ACK or NACK)
    data* {.importc: "data".}: ptr uint8 ## < Pointer to the buffer for storing the data read from the bus
    total_bytes* {.importc: "total_bytes".}: csize_t
    ## < Total number of bytes to read


  i2c_operation_job_t* {.importc: "i2c_operation_job_t", 
                         bycopy.} = object
    command* {.importc: "command".}: i2c_master_command_t ##
                              ## < I2C command indicating the type of operation (START, WRITE, READ, or STOP)
    write* {.importc: "write".}: INNER_C_STRUCT_i2c_master_10 ##
                              ##
                              ##  @brief Structure for WRITE command
                              ##
                              ##  Used when the `command` is set to `I2C_MASTER_CMD_WRITE`.
                              ##
    read* {.importc: "read".}: INNER_C_STRUCT_i2c_master_11 ##
                              ##
                              ##  @brief Structure for READ command
                              ##
                              ##  Used when the `command` is set to `I2C_MASTER_CMD_READ`.
                              ##


  i2c_master_transmit_multi_buffer_info_t* {.
      importc: "i2c_master_transmit_multi_buffer_info_t",
       bycopy.} = object ##
                                                 ##  @brief I2C master transmit buffer information structure
                                                 ##
    write_buffer* {.importc: "write_buffer".}: ptr uint8 ##
                              ## !< Pointer to buffer to be written.
    buffer_size* {.importc: "buffer_size".}: csize_t
    ## !< Size of data to be written.


  i2c_master_event_callbacks_t* {.importc: "i2c_master_event_callbacks_t",
                                   bycopy.} = object ##
                              ##
                              ##  @brief Group of I2C master callbacks, can be used to get status during transaction or doing other small things. But take care potential concurrency issues.
                              ##  @note The callbacks are all running under ISR context
                              ##  @note When CONFIG_I2C_ISR_IRAM_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
                              ##        The variables used in the function should be in the SRAM as well.
                              ##
    on_trans_done* {.importc: "on_trans_done".}: i2c_master_callback_t
    ## !< I2C master transaction finish callback

converter toHandle*(s: i2c_master_bus_config_tt): i2c_master_bus_config_t {.inline.} = cast[typeof(result)](s)
converter toHandle*(s: i2c_master_bus_config_t): i2c_master_bus_config_tt {.inline.} = cast[typeof(result)](s)

proc i2c_new_master_bus*(bus_config: ptr i2c_master_bus_config_t;
                         ret_bus_handle: ptr i2c_master_bus_handle_t): esp_err_t {.
    cdecl, importc: "i2c_new_master_bus", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Allocate an I2C master bus
                              ##
                              ##  @param[in] bus_config I2C master bus configuration.
                              ##  @param[out] ret_bus_handle I2C bus handle
                              ##  @return
                              ##       - ESP_OK: I2C master bus initialized successfully.
                              ##       - ESP_ERR_INVALID_ARG: I2C bus initialization failed because of invalid argument.
                              ##       - ESP_ERR_NO_MEM: Create I2C bus failed because of out of memory.
                              ##       - ESP_ERR_NOT_FOUND: No more free bus.
                              ##

proc i2c_master_bus_add_device*(bus_handle: i2c_master_bus_handle_t;
                                dev_config: ptr i2c_device_config_t;
                                ret_handle: ptr i2c_master_dev_handle_t): esp_err_t {.
    cdecl, importc: "i2c_master_bus_add_device", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Add I2C master BUS device.
                              ##
                              ##  @param[in] bus_handle I2C bus handle.
                              ##  @param[in] dev_config device config.
                              ##  @param[out] ret_handle device handle.
                              ##  @return
                              ##       - ESP_OK: Create I2C master device successfully.
                              ##       - ESP_ERR_INVALID_ARG: I2C bus initialization failed because of invalid argument.
                              ##       - ESP_ERR_NO_MEM: Create I2C bus failed because of out of memory.
                              ##

proc i2c_del_master_bus*(bus_handle: i2c_master_bus_handle_t): esp_err_t {.
    cdecl, importc: "i2c_del_master_bus", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Deinitialize the I2C master bus and delete the handle.
                              ##
                              ##  @param[in] bus_handle I2C bus handle.
                              ##  @return
                              ##       - ESP_OK: Delete I2C bus success, otherwise, failed.
                              ##       - Otherwise: Some module delete failed.
                              ##

proc i2c_master_bus_rm_device*(handle: i2c_master_dev_handle_t): esp_err_t {.
    cdecl, importc: "i2c_master_bus_rm_device", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief I2C master bus delete device
                              ##
                              ##  @param handle i2c device handle
                              ##  @return
                              ##       - ESP_OK: If device is successfully deleted.
                              ##

proc i2c_master_transmit*(i2c_dev: i2c_master_dev_handle_t;
                          write_buffer: ptr uint8; write_size: csize_t;
                          xfer_timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_transmit", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Perform a write transaction on the I2C bus.
                              ##         The transaction will be undergoing until it finishes or it reaches
                              ##         the timeout provided.
                              ##
                              ##  @note If a callback was registered with `i2c_master_register_event_callbacks`, the transaction will be asynchronous, and thus, this function will return directly, without blocking.
                              ##        You will get finish information from callback. Besides, data buffer should always be completely prepared when callback is registered, otherwise, the data will get corrupt.
                              ##
                              ##  @param[in] i2c_dev I2C master device handle that created by `i2c_master_bus_add_device`.
                              ##  @param[in] write_buffer Data bytes to send on the I2C bus.
                              ##  @param[in] write_size Size, in bytes, of the write buffer.
                              ##  @param[in] xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
                              ##  @return
                              ##       - ESP_OK: I2C master transmit success
                              ##       - ESP_ERR_INVALID_ARG: I2C master transmit parameter invalid.
                              ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the bus is busy or hardware crash.
                              ##

proc i2c_master_multi_buffer_transmit*(i2c_dev: i2c_master_dev_handle_t;
    buffer_info_array: ptr i2c_master_transmit_multi_buffer_info_t;
                                       array_size: csize_t;
                                       xfer_timeout_ms: cint): esp_err_t {.
    cdecl, importc: "i2c_master_multi_buffer_transmit", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Transmit multiple buffers of data over an I2C bus.
                              ##
                              ##  This function transmits multiple buffers of data over an I2C bus using the specified I2C master device handle.
                              ##  It takes in an array of buffer information structures along with the size of the array and a transfer timeout value in milliseconds.
                              ##
                              ##  @param i2c_dev I2C master device handle that created by `i2c_master_bus_add_device`.
                              ##  @param buffer_info_array Pointer to buffer information array.
                              ##  @param array_size size of buffer information array.
                              ##  @param xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
                              ##
                              ##  @return
                              ##       - ESP_OK: I2C master transmit success
                              ##       - ESP_ERR_INVALID_ARG: I2C master transmit parameter invalid.
                              ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the bus is busy or hardware crash.
                              ##

proc i2c_master_transmit_receive*(i2c_dev: i2c_master_dev_handle_t;
                                  write_buffer: ptr uint8; write_size: csize_t;
                                  read_buffer: ptr uint8; read_size: csize_t;
                                  xfer_timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_transmit_receive", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Perform a write-read transaction on the I2C bus.
                              ##         The transaction will be undergoing until it finishes or it reaches
                              ##         the timeout provided.
                              ##
                              ##  @note If a callback was registered with `i2c_master_register_event_callbacks`, the transaction will be asynchronous, and thus, this function will return directly, without blocking.
                              ##        You will get finish information from callback. Besides, data buffer should always be completely prepared when callback is registered, otherwise, the data will get corrupt.
                              ##
                              ##  @param[in] i2c_dev I2C master device handle that created by `i2c_master_bus_add_device`.
                              ##  @param[in] write_buffer Data bytes to send on the I2C bus.
                              ##  @param[in] write_size Size, in bytes, of the write buffer.
                              ##  @param[out] read_buffer Data bytes received from i2c bus.
                              ##  @param[in] read_size Size, in bytes, of the read buffer.
                              ##  @param[in] xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
                              ##  @return
                              ##       - ESP_OK: I2C master transmit-receive success
                              ##       - ESP_ERR_INVALID_ARG: I2C master transmit parameter invalid.
                              ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the bus is busy or hardware crash.
                              ##

proc i2c_master_receive*(i2c_dev: i2c_master_dev_handle_t;
                         read_buffer: ptr uint8; read_size: csize_t;
                         xfer_timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_receive", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Perform a read transaction on the I2C bus.
                              ##         The transaction will be undergoing until it finishes or it reaches
                              ##         the timeout provided.
                              ##
                              ##  @note If a callback was registered with `i2c_master_register_event_callbacks`, the transaction will be asynchronous, and thus, this function will return directly, without blocking.
                              ##        You will get finish information from callback. Besides, data buffer should always be completely prepared when callback is registered, otherwise, the data will get corrupt.
                              ##
                              ##  @param[in] i2c_dev I2C master device handle that created by `i2c_master_bus_add_device`.
                              ##  @param[out] read_buffer Data bytes received from i2c bus.
                              ##  @param[in] read_size Size, in bytes, of the read buffer.
                              ##  @param[in] xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever.
                              ##  @return
                              ##       - ESP_OK: I2C master receive success
                              ##       - ESP_ERR_INVALID_ARG: I2C master receive parameter invalid.
                              ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the bus is busy or hardware crash.
                              ##

proc i2c_master_probe*(bus_handle: i2c_master_bus_handle_t; address: uint16;
                       xfer_timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_probe", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Probe I2C address, if address is correct and ACK is received, this function will return ESP_OK.
                              ##
                              ##  @param[in] bus_handle I2C master device handle that created by `i2c_master_bus_add_device`.
                              ##  @param[in] address I2C device address that you want to probe.
                              ##  @param[in] xfer_timeout_ms Wait timeout, in ms. Note: -1 means wait forever (Not recommended in this function).
                              ##
                              ##  @attention Pull-ups must be connected to the SCL and SDA pins when this function is called. If you get `ESP_ERR_TIMEOUT
                              ##  while `xfer_timeout_ms` was parsed correctly, you should check the pull-up resistors. If you do not have proper resistors nearby.
                              ##  `flags.enable_internal_pullup` is also acceptable.
                              ##
                              ##  @note The principle of this function is to sent device address with a write command. If the device on your I2C bus, there would be an ACK signal and function
                              ##  returns `ESP_OK`. If the device is not on your I2C bus, there would be a NACK signal and function returns `ESP_ERR_NOT_FOUND`. `ESP_ERR_TIMEOUT` is not an expected
                              ##  failure, which indicated that the i2c probe not works properly, usually caused by pull-up resistors not be connected properly. Suggestion check data on SDA/SCL line
                              ##  to see whether there is ACK/NACK signal is on line when i2c probe function fails.
                              ##
                              ##  @note There are lots of I2C devices all over the world, we assume that not all I2C device support the behavior like `device_address+nack/ack`.
                              ##  So, if the on line data is strange and no ack/nack got respond. Please check the device datasheet.
                              ##
                              ##  @return
                              ##       - ESP_OK: I2C device probe successfully
                              ##       - ESP_ERR_NOT_FOUND: I2C probe failed, doesn't find the device with specific address you gave.
                              ##       - ESP_ERR_TIMEOUT: Operation timeout(larger than xfer_timeout_ms) because the bus is busy or hardware crash.
                              ##

proc i2c_master_execute_defined_operations*(i2c_dev: i2c_master_dev_handle_t;
    i2c_operation: ptr i2c_operation_job_t; operation_list_num: csize_t;
    xfer_timeout_ms: cint): esp_err_t {.cdecl, importc: "i2c_master_execute_defined_operations",
                                        header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Execute a series of pre-defined I2C operations.
                              ##
                              ##  This function processes a list of I2C operations, such as start, write, read, and stop,
                              ##  according to the user-defined `i2c_operation_job_t` array. It performs these operations
                              ##  sequentially on the specified I2C master device.
                              ##
                              ##  @param[in] i2c_dev           Handle to the I2C master device.
                              ##  @param[in] i2c_operation     Pointer to an array of user-defined I2C operation jobs.
                              ##                               Each job specifies a command and associated parameters.
                              ##  @param[in] operation_list_num The number of operations in the `i2c_operation` array.
                              ##  @param[in] xfer_timeout_ms   Timeout for the transaction, in milliseconds.
                              ##
                              ##  @return
                              ##   - ESP_OK: Transaction completed successfully.
                              ##   - ESP_ERR_INVALID_ARG: One or more arguments are invalid.
                              ##   - ESP_ERR_TIMEOUT: Transaction timed out.
                              ##   - ESP_FAIL: Other error during transaction.
                              ##
                              ##  @note The `ack_value` field in the READ operation must be set to `I2C_NACK_VAL` if the next
                              ##        operation is a STOP command.
                              ##

proc i2c_master_register_event_callbacks*(i2c_dev: i2c_master_dev_handle_t;
    cbs: ptr i2c_master_event_callbacks_t; user_data: pointer): esp_err_t {.
    cdecl, importc: "i2c_master_register_event_callbacks",
    header: "i2c_master.h".}
  ##
                            ##  @brief Register I2C transaction callbacks for a master device
                            ##
                            ##  @note User can deregister a previously registered callback by calling this function and setting the callback member in the `cbs` structure to NULL.
                            ##  @note When CONFIG_I2C_ISR_IRAM_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
                            ##        The variables used in the function should be in the SRAM as well. The `user_data` should also reside in SRAM.
                            ##  @note If the callback is used for helping asynchronous transaction. On the same bus, only one device can be used for performing asynchronous operation.
                            ##
                            ##  @param[in] i2c_dev I2C master device handle that created by `i2c_master_bus_add_device`.
                            ##  @param[in] cbs Group of callback functions
                            ##  @param[in] user_data User data, which will be passed to callback functions directly
                            ##  @return
                            ##       - ESP_OK: Set I2C transaction callbacks successfully
                            ##       - ESP_ERR_INVALID_ARG: Set I2C transaction callbacks failed because of invalid argument
                            ##       - ESP_FAIL: Set I2C transaction callbacks failed because of other error
                            ##

proc i2c_master_bus_reset*(bus_handle: i2c_master_bus_handle_t): esp_err_t {.
    cdecl, importc: "i2c_master_bus_reset", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Reset the I2C master bus.
                              ##
                              ##  @param bus_handle I2C bus handle.
                              ##  @return
                              ##       - ESP_OK: Reset succeed.
                              ##       - ESP_ERR_INVALID_ARG: I2C master bus handle is not initialized.
                              ##       - Otherwise: Reset failed.
                              ##

proc i2c_master_device_change_address*(i2c_dev: i2c_master_dev_handle_t;
                                       new_device_address: uint16;
                                       timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_device_change_address", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Change the I2C device address at runtime.
                              ##
                              ##  This function updates the device address of an existing I2C device handle.
                              ##  It is useful for devices that support dynamic address assignment or when
                              ##  switching communication to a device with a different address on the same bus.
                              ##
                              ##  @param[in] i2c_dev           I2C device handle.
                              ##  @param[in] new_device_address The new device address.
                              ##  @param[in] timeout_ms        Timeout for the address change operation, in milliseconds.
                              ##
                              ##  @return
                              ##       - ESP_OK: Address successfully changed.
                              ##       - ESP_ERR_INVALID_ARG: Invalid arguments (e.g., NULL handle or invalid address).
                              ##       - ESP_ERR_TIMEOUT: Operation timed out.
                              ##
                              ##  @note
                              ##       - This function does not send commands to the I2C device. It only updates
                              ##         the address used in subsequent transactions through the I2C handle.
                              ##       - Ensure that the new address is valid and does not conflict with other devices on the bus.
                              ##

proc i2c_master_bus_wait_all_done*(bus_handle: i2c_master_bus_handle_t;
                                   timeout_ms: cint): esp_err_t {.cdecl,
    importc: "i2c_master_bus_wait_all_done", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Wait for all pending I2C transactions done
                              ##
                              ##  @param[in] bus_handle I2C bus handle
                              ##  @param[in] timeout_ms Wait timeout, in ms. Specially, -1 means to wait forever.
                              ##  @return
                              ##       - ESP_OK: Flush transactions successfully
                              ##       - ESP_ERR_INVALID_ARG: Flush transactions failed because of invalid argument
                              ##       - ESP_ERR_TIMEOUT: Flush transactions failed because of timeout
                              ##       - ESP_FAIL: Flush transactions failed because of other error
                              ##

proc i2c_master_get_bus_handle*(port_num: i2c_port_num_t;
                                ret_handle: ptr i2c_master_bus_handle_t): esp_err_t {.
    cdecl, importc: "i2c_master_get_bus_handle", header: "i2c_master.h".}
  ##
                              ##
                              ##  @brief Retrieves the I2C master bus handle for a specified I2C port number.
                              ##
                              ##  This function retrieves the I2C master bus handle for the
                              ##  given I2C port number. Please make sure the handle has already been initialized, and this
                              ##  function would simply returns the existing handle. Note that the returned handle still can't be used concurrently
                              ##
                              ##  @param port_num I2C port number for which the handle is to be retrieved.
                              ##  @param ret_handle Pointer to a variable where the retrieved handle will be stored.
                              ##  @return
                              ##      - ESP_OK: Success. The handle is retrieved successfully.
                              ##      - ESP_ERR_INVALID_ARG: Invalid argument, such as invalid port number
                              ##      - ESP_ERR_INVALID_STATE: Invalid state, such as the I2C port is not initialized.
                              ## 