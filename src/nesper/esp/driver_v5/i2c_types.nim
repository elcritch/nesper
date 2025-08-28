##
##  SPDX-FileCopyrightText: 2023-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

type

  i2c_port_num_t* = cint     ##
                             ##  @brief I2C port number.
                             ##

  i2c_master_status_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enumeration for I2C fsm status.
                              ##
    I2C_STATUS_READ,        ## !< read status for current master command
    I2C_STATUS_WRITE,       ## !< write status for current master command
    I2C_STATUS_START,       ## !< Start status for current master command
    I2C_STATUS_STOP,        ## !< stop status for current master command
    I2C_STATUS_IDLE,        ## !< idle status for current master command
    I2C_STATUS_ACK_ERROR,   ## !< ack error status for current master command
    I2C_STATUS_DONE,        ## !< I2C command done
    I2C_STATUS_TIMEOUT       ## !< I2C bus status error, and operation timeout


type

  i2c_master_event_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enumeration for I2C event.
                              ##
    I2C_EVENT_ALIVE,        ## !< i2c bus in alive status.
    I2C_EVENT_DONE,         ## !< i2c bus transaction done
    I2C_EVENT_NACK,         ## !< i2c bus nack
    I2C_EVENT_TIMEOUT        ## !< i2c bus timeout


type

  i2c_master_command_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Enum for I2C master commands
                              ##
                              ##  These commands are used to define the I2C master operations.
                              ##  They correspond to hardware-level commands supported by the I2C peripheral.
                              ##
    I2C_MASTER_CMD_START,   ## < Start or Restart condition
    I2C_MASTER_CMD_WRITE,   ## < Write operation
    I2C_MASTER_CMD_READ,    ## < Read operation
    I2C_MASTER_CMD_STOP      ## < Stop condition


type

  i2c_ack_value_t* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief Enum for I2C master ACK values
                                                  ##
                                                  ##  These values define the acknowledgment (ACK) behavior during read operations.
                                                  ##
    I2C_ACK_VAL = 0,        ## < Acknowledge (ACK) signal
    I2C_NACK_VAL = 1         ## < Not Acknowledge (NACK) signal


type

  i2c_master_bus_config_tt* {.importc: "i2c_master_bus_config_t", incompleteStruct, header: "<driver/i2c_types.h>".} = object

  i2c_master_bus_handle_t* = ptr i2c_master_bus_config_tt ##
                                                  ##  @brief Type of I2C master bus handle
                                                  ##

  i2c_master_dev_handle_t* = pointer ##
                                                  ##  @brief Type of I2C master bus device handle
                                                  ##

  i2c_slave_dev_handle_t* = pointer ##
                                                ##  @brief Type of I2C slave device handle
                                                ##

  i2c_master_event_data_t* {.importc: "i2c_master_event_data_t",
                             header: "i2c_types.h", bycopy.} = object ##
                              ##
                              ##  @brief Data type used in I2C event callback
                              ##
    event* {.importc: "event".}: i2c_master_event_t
    ## < The I2C hardware event that I2C callback is called.


  i2c_master_callback_t* = proc (i2c_dev: i2c_master_dev_handle_t;
                                 evt_data: ptr i2c_master_event_data_t;
                                 arg: pointer): bool {.cdecl.} ##
                              ##
                              ##  @brief An callback for I2C transaction.
                              ##
                              ##  @param[in]  i2c_dev Handle for I2C device.
                              ##  @param[out] evt_data I2C capture event data, fed by driver
                              ##  @param[in]  arg User data, set in `i2c_master_register_event_callbacks()`
                              ##
                              ##  @return Whether a high priority task has been waken up by this function
                              ##

  i2c_slave_rx_done_event_data_t* {.importc: "i2c_slave_rx_done_event_data_t",
                                    header: "i2c_types.h", bycopy.} = object ##
                              ##
                              ##  @brief Event structure used in I2C slave
                              ##
    buffer* {.importc: "buffer".}: ptr uint8 ## < Pointer for buffer received in callback.

    length*: uint32
    ## < Length for buffer received in callback.


  i2c_slave_received_callback_t* = proc (i2c_slave: i2c_slave_dev_handle_t;
      evt_data: ptr i2c_slave_rx_done_event_data_t; arg: pointer): bool {.cdecl.} ##
                              ##
                              ##  @brief Callback signature for I2C slave.
                              ##
                              ##  @param[in]  i2c_slave Handle for I2C slave.
                              ##  @param[out] evt_data I2C capture event data, fed by driver
                              ##  @param[in]  arg User data, set in `i2c_slave_register_event_callbacks()`
                              ##
                              ##  @return Whether a high priority task has been waken up by this function
                              ##

when defined(SOC_I2C_SLAVE_CAN_GET_STRETCH_CAUSE):
  ##
  ##  @brief Stretch cause event structure used in I2C slave
  ##
  type

    i2c_slave_stretch_event_data_t* {.importc: "i2c_slave_stretch_event_data_t",
                                      header: "i2c_types.h", bycopy.} = object
      stretch_cause* {.importc: "stretch_cause".}: i2c_slave_stretch_cause_t
      ## !< Stretch cause can be got in callback

  ##
  ##  @brief Callback signature for I2C slave stretch.
  ##
  ##  @param[in]  i2c_slave Handle for I2C slave.
  ##  @param[out] evt_cause I2C capture event cause, fed by driver
  ##  @param[in]  arg User data, set in `i2c_slave_register_event_callbacks()`
  ##
  ##  @return Whether a high priority task has been waken up by this function
  ##
  type

    i2c_slave_stretch_callback_t* = proc (i2c_slave: i2c_slave_dev_handle_t;
        evt_cause: ptr i2c_slave_stretch_event_data_t; arg: pointer): bool {.
        cdecl.}

type

  i2c_slave_request_event_data_t* {.importc: "i2c_slave_request_event_data_t",
                                    header: "i2c_types.h", bycopy.} = object ##
                              ##
                              ##  @brief Event structure used in I2C slave request.
                              ##


  i2c_slave_request_callback_t* = proc (i2c_slave: i2c_slave_dev_handle_t;
      evt_data: ptr i2c_slave_request_event_data_t; arg: pointer): bool {.cdecl.} ##
                              ##
                              ##  @brief Callback signature for I2C slave request event. When this callback is triggered that means master want to read data
                              ##  from slave while there is no data in slave fifo. So user should write data to fifo via `i2c_slave_write`
                              ##
                              ##  @param[in]  i2c_slave Handle for I2C slave.
                              ##  @param[out] evt_data I2C receive event data, fed by driver
                              ##  @param[in]  arg User data, set in `i2c_slave_register_event_callbacks()`
                              ##
                              ##  @return Whether a high priority task has been waken up by this function
                              ##
