##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
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

import consts
import uart_reg
import queue

const
  UART_FIFO_LEN* = (128)        ## !< Length of the hardware FIFO buffers
  UART_INTR_MASK* = 0x000001FF
  UART_LINE_INV_MASK* = (0x0000003F shl 19) ## !< TBD
  UART_BITRATE_MAX* = 5000000
  UART_PIN_NO_CHANGE* = (-1)    ## !< Constant for uart_set_pin function which indicates that UART pin should not be changed
  UART_INVERSE_DISABLE* = (0x00000000) ## !< Disable UART signal inverse
  UART_INVERSE_RXD* = (UART_RXD_INV_M) ## !< UART RXD input inverse
  UART_INVERSE_CTS* = (UART_CTS_INV_M) ## !< UART CTS input inverse
  UART_INVERSE_TXD* = (UART_TXD_INV_M) ## !< UART TXD output inverse
  UART_INVERSE_RTS* = (UART_RTS_INV_M) ## !< UART RTS output inverse

## *
##  @brief UART mode selection
##

type
  uart_mode_t* {.size: sizeof(cint).} = enum
    UART_MODE_UART = 0x00000000, ## !< mode: regular UART mode
    UART_MODE_RS485_HALF_DUPLEX = 0x00000001, ## !< mode: half duplex RS485 UART mode control by RTS pin
    UART_MODE_IRDA = 0x00000002, ## !< mode: IRDA  UART mode
    UART_MODE_RS485_COLLISION_DETECT = 0x00000003, ## !< mode: RS485 collision detection UART mode (used for test purposes)
    UART_MODE_RS485_APP_CTRL = 0x00000004 ## !< mode: application control RS485 UART mode (used for test purposes)


## *
##  @brief UART word length constants
##

type
  uart_word_length_t* {.size: sizeof(cint).} = enum
    UART_DATA_5_BITS = 0x00000000, ## !< word length: 5bits
    UART_DATA_6_BITS = 0x00000001, ## !< word length: 6bits
    UART_DATA_7_BITS = 0x00000002, ## !< word length: 7bits
    UART_DATA_8_BITS = 0x00000003, ## !< word length: 8bits
    UART_DATA_BITS_MAX = 0x00000004


## *
##  @brief UART stop bits number
##

type
  uart_stop_bits_t* {.size: sizeof(cint).} = enum
    UART_STOP_BITS_1 = 0x00000001, ## !< stop bit: 1bit
    UART_STOP_BITS_1_5 = 0x00000002, ## !< stop bit: 1.5bits
    UART_STOP_BITS_2 = 0x00000003, ## !< stop bit: 2bits
    UART_STOP_BITS_MAX = 0x00000004


## *
##  @brief UART peripheral number
##

type
  uart_port_t* {.size: sizeof(cint).} = enum
    UART_NUM_0 = 0x00000000,    ## !< UART base address 0x3ff40000
    UART_NUM_1 = 0x00000001,    ## !< UART base address 0x3ff50000
    UART_NUM_2 = 0x00000002,    ## !< UART base address 0x3ff6e000
    UART_NUM_MAX


## *
##  @brief UART parity constants
##

type
  uart_parity_t* {.size: sizeof(cint).} = enum
    UART_PARITY_DISABLE = 0x00000000, ## !< Disable UART parity
    UART_PARITY_EVEN = 0x00000002, ## !< Enable UART even parity
    UART_PARITY_ODD = 0x00000003


## *
##  @brief UART hardware flow control modes
##

type
  uart_hw_flowcontrol_t* {.size: sizeof(cint).} = enum
    UART_HW_FLOWCTRL_DISABLE = 0x00000000, ## !< disable hardware flow control
    UART_HW_FLOWCTRL_RTS = 0x00000001, ## !< enable RX hardware flow control (rts)
    UART_HW_FLOWCTRL_CTS = 0x00000002, ## !< enable TX hardware flow control (cts)
    UART_HW_FLOWCTRL_CTS_RTS = 0x00000003, ## !< enable hardware flow control
    UART_HW_FLOWCTRL_MAX = 0x00000004


## *
##  @brief UART configuration parameters for uart_param_config function
##

type
  uart_config_t* {.importc: "uart_config_t", header: "<driver/uart.h>", bycopy.} = object
    baud_rate* {.importc: "baud_rate".}: cint ## !< UART baud rate
    data_bits* {.importc: "data_bits".}: uart_word_length_t ## !< UART byte size
    parity* {.importc: "parity".}: uart_parity_t ## !< UART parity mode
    stop_bits* {.importc: "stop_bits".}: uart_stop_bits_t ## !< UART stop bits
    flow_ctrl* {.importc: "flow_ctrl".}: uart_hw_flowcontrol_t ## !< UART HW flow control mode (cts/rts)
    rx_flow_ctrl_thresh* {.importc: "rx_flow_ctrl_thresh".}: uint8 ## !< UART HW RTS threshold
    use_ref_tick* {.importc: "use_ref_tick".}: bool ## !< Set to true if UART should be clocked from REF_TICK


## *
##  @brief UART interrupt configuration parameters for uart_intr_config function
##

type
  uart_intr_config_t* {.importc: "uart_intr_config_t", header: "<driver/uart.h>", bycopy.} = object
    intr_enable_mask* {.importc: "intr_enable_mask".}: uint32 ## !< UART interrupt enable mask, choose from UART_XXXX_INT_ENA_M under UART_INT_ENA_REG(i), connect with bit-or operator
    rx_timeout_thresh* {.importc: "rx_timeout_thresh".}: uint8 ## !< UART timeout interrupt threshold (unit: time of sending one byte)
    txfifo_empty_intr_thresh* {.importc: "txfifo_empty_intr_thresh".}: uint8 ## !< UART TX empty interrupt threshold.
    rxfifo_full_thresh* {.importc: "rxfifo_full_thresh".}: uint8 ## !< UART RX full interrupt threshold.


## *
##  @brief UART event types used in the ring buffer
##

type
  uart_event_type_t* {.size: sizeof(cint).} = enum
    UART_DATA,                ## !< UART data event
    UART_BREAK,               ## !< UART break event
    UART_BUFFER_FULL,         ## !< UART RX buffer full event
    UART_FIFO_OVF,            ## !< UART FIFO overflow event
    UART_FRAME_ERR,           ## !< UART RX frame error event
    UART_PARITY_ERR,          ## !< UART RX parity event
    UART_DATA_BREAK,          ## !< UART TX data and break event
    UART_PATTERN_DET,         ## !< UART pattern detected
    UART_EVENT_MAX            ## !< UART event max index


## *
##  @brief Event structure used in UART event queue
##

type
  uart_event_t* {.importc: "uart_event_t", header: "<driver/uart.h>", bycopy.} = object
    `type`* {.importc: "type".}: uart_event_type_t ## !< UART event type
    size* {.importc: "size".}: csize ## !< UART data size for UART_DATA event

  uart_isr_handle_t* = intr_handle_t

## *
##  @brief Checks whether the driver is installed or not
##
##  @param uart_num UART port number, the max port number is (UART_NUM_MAX -1).
##
##  @return
##      - true  driver is installed
##      - false driver is not installed
##

proc uart_is_driver_installed*(uart_num: uart_port_t): bool {.cdecl,
    importc: "uart_is_driver_installed", header: "<driver/uart.h>".}
## *
##  @brief Set UART data bits.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param data_bit UART data bits
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_word_length*(uart_num: uart_port_t; data_bit: uart_word_length_t): esp_err_t {.
    cdecl, importc: "uart_set_word_length", header: "<driver/uart.h>".}
## *
##  @brief Get UART data bits.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param data_bit Pointer to accept value of UART data bits.
##
##  @return
##      - ESP_FAIL  Parameter error
##      - ESP_OK    Success, result will be put in (*data_bit)
##

proc uart_get_word_length*(uart_num: uart_port_t; data_bit: ptr uart_word_length_t): esp_err_t {.
    cdecl, importc: "uart_get_word_length", header: "<driver/uart.h>".}
## *
##  @brief Set UART stop bits.
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param stop_bits  UART stop bits
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Fail
##

proc uart_set_stop_bits*(uart_num: uart_port_t; stop_bits: uart_stop_bits_t): esp_err_t {.
    cdecl, importc: "uart_set_stop_bits", header: "<driver/uart.h>".}
## *
##  @brief Get UART stop bits.
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param stop_bits  Pointer to accept value of UART stop bits.
##
##  @return
##      - ESP_FAIL Parameter error
##      - ESP_OK   Success, result will be put in (*stop_bit)
##

proc uart_get_stop_bits*(uart_num: uart_port_t; stop_bits: ptr uart_stop_bits_t): esp_err_t {.
    cdecl, importc: "uart_get_stop_bits", header: "<driver/uart.h>".}
## *
##  @brief Set UART parity mode.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param parity_mode the enum of uart parity configuration
##
##  @return
##      - ESP_FAIL  Parameter error
##      - ESP_OK    Success
##

proc uart_set_parity*(uart_num: uart_port_t; parity_mode: uart_parity_t): esp_err_t {.
    cdecl, importc: "uart_set_parity", header: "<driver/uart.h>".}
## *
##  @brief Get UART parity mode.
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param parity_mode Pointer to accept value of UART parity mode.
##
##  @return
##      - ESP_FAIL  Parameter error
##      - ESP_OK    Success, result will be put in (*parity_mode)
##
##

proc uart_get_parity*(uart_num: uart_port_t; parity_mode: ptr uart_parity_t): esp_err_t {.
    cdecl, importc: "uart_get_parity", header: "<driver/uart.h>".}
## *
##  @brief Set UART baud rate.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param baudrate UART baud rate.
##
##  @return
##      - ESP_FAIL Parameter error
##      - ESP_OK   Success
##

proc uart_set_baudrate*(uart_num: uart_port_t; baudrate: uint32): esp_err_t {.cdecl,
    importc: "uart_set_baudrate", header: "<driver/uart.h>".}
## *
##  @brief Get UART baud rate.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param baudrate Pointer to accept value of UART baud rate
##
##  @return
##      - ESP_FAIL Parameter error
##      - ESP_OK   Success, result will be put in (*baudrate)
##
##

proc uart_get_baudrate*(uart_num: uart_port_t; baudrate: ptr uint32): esp_err_t {.
    cdecl, importc: "uart_get_baudrate", header: "<driver/uart.h>".}
## *
##  @brief Set UART line inverse mode
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param inverse_mask Choose the wires that need to be inverted.
##         Inverse_mask should be chosen from
##         UART_INVERSE_RXD / UART_INVERSE_TXD / UART_INVERSE_RTS / UART_INVERSE_CTS,
##         combined with OR operation.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_line_inverse*(uart_num: uart_port_t; inverse_mask: uint32): esp_err_t {.
    cdecl, importc: "uart_set_line_inverse", header: "<driver/uart.h>".}
## *
##  @brief Set hardware flow control.
##
##  @param uart_num   UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param flow_ctrl Hardware flow control mode
##  @param rx_thresh Threshold of Hardware RX flow control (0 ~ UART_FIFO_LEN).
##         Only when UART_HW_FLOWCTRL_RTS is set, will the rx_thresh value be set.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_hw_flow_ctrl*(uart_num: uart_port_t;
                           flow_ctrl: uart_hw_flowcontrol_t; rx_thresh: uint8): esp_err_t {.
    cdecl, importc: "uart_set_hw_flow_ctrl", header: "<driver/uart.h>".}
## *
##  @brief Set software flow control.
##
##  @param uart_num   UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param enable     switch on or off
##  @param rx_thresh_xon  low water mark
##  @param rx_thresh_xoff high water mark
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_sw_flow_ctrl*(uart_num: uart_port_t; enable: bool;
                           rx_thresh_xon: uint8; rx_thresh_xoff: uint8): esp_err_t {.
    cdecl, importc: "uart_set_sw_flow_ctrl", header: "<driver/uart.h>".}
## *
##  @brief Get hardware flow control mode
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param flow_ctrl Option for different flow control mode.
##
##  @return
##      - ESP_FAIL Parameter error
##      - ESP_OK   Success, result will be put in (*flow_ctrl)
##

proc uart_get_hw_flow_ctrl*(uart_num: uart_port_t;
                           flow_ctrl: ptr uart_hw_flowcontrol_t): esp_err_t {.cdecl,
    importc: "uart_get_hw_flow_ctrl", header: "<driver/uart.h>".}
## *
##  @brief Clear UART interrupt status
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param clr_mask  Bit mask of the interrupt status to be cleared.
##                   The bit mask should be composed from the fields of register UART_INT_CLR_REG.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_clear_intr_status*(uart_num: uart_port_t; clr_mask: uint32): esp_err_t {.
    cdecl, importc: "uart_clear_intr_status", header: "<driver/uart.h>".}
## *
##  @brief Set UART interrupt enable
##
##  @param uart_num     UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param enable_mask  Bit mask of the enable bits.
##                      The bit mask should be composed from the fields of register UART_INT_ENA_REG.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_enable_intr_mask*(uart_num: uart_port_t; enable_mask: uint32): esp_err_t {.
    cdecl, importc: "uart_enable_intr_mask", header: "<driver/uart.h>".}
## *
##  @brief Clear UART interrupt enable bits
##
##  @param uart_num      UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param disable_mask  Bit mask of the disable bits.
##                       The bit mask should be composed from the fields of register UART_INT_ENA_REG.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_disable_intr_mask*(uart_num: uart_port_t; disable_mask: uint32): esp_err_t {.
    cdecl, importc: "uart_disable_intr_mask", header: "<driver/uart.h>".}
## *
##  @brief Enable UART RX interrupt (RX_FULL & RX_TIMEOUT INTERRUPT)
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_enable_rx_intr*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_enable_rx_intr", header: "<driver/uart.h>".}
## *
##  @brief Disable UART RX interrupt (RX_FULL & RX_TIMEOUT INTERRUPT)
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_disable_rx_intr*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_disable_rx_intr", header: "<driver/uart.h>".}
## *
##  @brief Disable UART TX interrupt (TX_FULL & TX_TIMEOUT INTERRUPT)
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_disable_tx_intr*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_disable_tx_intr", header: "<driver/uart.h>".}
## *
##  @brief Enable UART TX interrupt (TX_FULL & TX_TIMEOUT INTERRUPT)
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param enable  1: enable; 0: disable
##  @param thresh  Threshold of TX interrupt, 0 ~ UART_FIFO_LEN
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_enable_tx_intr*(uart_num: uart_port_t; enable: cint; thresh: cint): esp_err_t {.
    cdecl, importc: "uart_enable_tx_intr", header: "<driver/uart.h>".}
## *
##  @brief Register UART interrupt handler (ISR).
##
##  @note UART ISR handler will be attached to the same CPU core that this function is running on.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param fn  Interrupt handler function.
##  @param arg parameter for handler function
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##  @param handle Pointer to return handle. If non-NULL, a handle for the interrupt will
##         be returned here.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_isr_register*(uart_num: uart_port_t; fn: proc (a1: pointer) {.cdecl.};
                       arg: pointer; intr_alloc_flags: cint;
                       handle: ptr uart_isr_handle_t): esp_err_t {.cdecl,
    importc: "uart_isr_register", header: "<driver/uart.h>".}
## *
##  @brief Free UART interrupt handler registered by uart_isr_register. Must be called on the same core as
##  uart_isr_register was called.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_isr_free*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_isr_free", header: "<driver/uart.h>".}
## *
##  @brief Set UART pin number
##
##  @note Internal signal can be output to multiple GPIO pads.
##        Only one GPIO pad can connect with input signal.
##
##  @note Instead of GPIO number a macro 'UART_PIN_NO_CHANGE' may be provided
##          to keep the currently allocated pin.
##
##  @param uart_num   UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param tx_io_num  UART TX pin GPIO number.
##  @param rx_io_num  UART RX pin GPIO number.
##  @param rts_io_num UART RTS pin GPIO number.
##  @param cts_io_num UART CTS pin GPIO number.
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_pin*(uart_num: uart_port_t; tx_io_num: cint; rx_io_num: cint;
                  rts_io_num: cint; cts_io_num: cint): esp_err_t {.cdecl,
    importc: "uart_set_pin", header: "<driver/uart.h>".}
## *
##  @brief Manually set the UART RTS pin level.
##  @note  UART must be configured with hardware flow control disabled.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param level    1: RTS output low (active); 0: RTS output high (block)
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_rts*(uart_num: uart_port_t; level: cint): esp_err_t {.cdecl,
    importc: "uart_set_rts", header: "<driver/uart.h>".}
## *
##  @brief Manually set the UART DTR pin level.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param level    1: DTR output low; 0: DTR output high
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_dtr*(uart_num: uart_port_t; level: cint): esp_err_t {.cdecl,
    importc: "uart_set_dtr", header: "<driver/uart.h>".}
## *
##  @brief Set UART idle interval after tx FIFO is empty
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param idle_num idle interval after tx FIFO is empty(unit: the time it takes to send one bit
##         under current baudrate)
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_set_tx_idle_num*(uart_num: uart_port_t; idle_num: uint16): esp_err_t {.
    cdecl, importc: "uart_set_tx_idle_num", header: "<driver/uart.h>".}
## *
##  @brief Set UART configuration parameters.
##
##  @param uart_num    UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param uart_config UART parameter settings
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_param_config*(uart_num: uart_port_t; uart_config: ptr uart_config_t): esp_err_t {.
    cdecl, importc: "uart_param_config", header: "<driver/uart.h>".}
## *
##  @brief Configure UART interrupts.
##
##  @param uart_num  UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param intr_conf UART interrupt settings
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_intr_config*(uart_num: uart_port_t; intr_conf: ptr uart_intr_config_t): esp_err_t {.
    cdecl, importc: "uart_intr_config", header: "<driver/uart.h>".}
## *
##  @brief Install UART driver.
##
##  UART ISR handler will be attached to the same CPU core that this function is running on.
##
##  @note  Rx_buffer_size should be greater than UART_FIFO_LEN. Tx_buffer_size should be either zero or greater than UART_FIFO_LEN.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param rx_buffer_size UART RX ring buffer size.
##  @param tx_buffer_size UART TX ring buffer size.
##         If set to zero, driver will not use TX buffer, TX function will block task until all data have been sent out.
##  @param queue_size UART event queue size/depth.
##  @param uart_queue UART event queue handle (out param). On success, a new queue handle is written here to provide
##         access to UART events. If set to NULL, driver will not use an event queue.
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info. Do not set ESP_INTR_FLAG_IRAM here
##         (the driver's ISR handler is not located in IRAM)
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_driver_install*(uart_num: uart_port_t; rx_buffer_size: cint;
                         tx_buffer_size: cint; queue_size: cint;
                         uart_queue: ptr QueueHandle_t; intr_alloc_flags: cint): esp_err_t {.
    cdecl, importc: "uart_driver_install", header: "<driver/uart.h>".}
## *
##  @brief Uninstall UART driver.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##

proc uart_driver_delete*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_driver_delete", header: "<driver/uart.h>".}
## *
##  @brief Wait until UART TX FIFO is empty.
##
##  @param uart_num      UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param ticks_to_wait Timeout, count in RTOS ticks
##
##  @return
##      - ESP_OK   Success
##      - ESP_FAIL Parameter error
##      - ESP_ERR_TIMEOUT  Timeout
##

proc uart_wait_tx_done*(uart_num: uart_port_t; ticks_to_wait: TickType_t): esp_err_t {.
    cdecl, importc: "uart_wait_tx_done", header: "<driver/uart.h>".}
## *
##  @brief Send data to the UART port from a given buffer and length.
##
##  This function will not wait for enough space in TX FIFO. It will just fill the available TX FIFO and return when the FIFO is full.
##  @note This function should only be used when UART TX buffer is not enabled.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param buffer data buffer address
##  @param len    data length to send
##
##  @return
##      - (-1)  Parameter error
##      - OTHERS (>=0) The number of bytes pushed to the TX FIFO
##

proc uart_tx_chars*(uart_num: uart_port_t; buffer: cstring; len: uint32): cint {.
    cdecl, importc: "uart_tx_chars", header: "<driver/uart.h>".}
## *
##  @brief Send data to the UART port from a given buffer and length,
##
##  If the UART driver's parameter 'tx_buffer_size' is set to zero:
##  This function will not return until all the data have been sent out, or at least pushed into TX FIFO.
##
##  Otherwise, if the 'tx_buffer_size' > 0, this function will return after copying all the data to tx ring buffer,
##  UART ISR will then move data from the ring buffer to TX FIFO gradually.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param src   data buffer address
##  @param size  data length to send
##
##  @return
##      - (-1) Parameter error
##      - OTHERS (>=0) The number of bytes pushed to the TX FIFO
##

proc uart_write_bytes*(uart_num: uart_port_t; src: cstring; size: csize): cint {.cdecl,
    importc: "uart_write_bytes", header: "<driver/uart.h>".}
## *
##  @brief Send data to the UART port from a given buffer and length,
##
##  If the UART driver's parameter 'tx_buffer_size' is set to zero:
##  This function will not return until all the data and the break signal have been sent out.
##  After all data is sent out, send a break signal.
##
##  Otherwise, if the 'tx_buffer_size' > 0, this function will return after copying all the data to tx ring buffer,
##  UART ISR will then move data from the ring buffer to TX FIFO gradually.
##  After all data sent out, send a break signal.
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param src   data buffer address
##  @param size  data length to send
##  @param brk_len break signal duration(unit: the time it takes to send one bit at current baudrate)
##
##  @return
##      - (-1) Parameter error
##      - OTHERS (>=0) The number of bytes pushed to the TX FIFO
##

proc uart_write_bytes_with_break*(uart_num: uart_port_t; src: cstring; size: csize;
                                 brk_len: cint): cint {.cdecl,
    importc: "uart_write_bytes_with_break", header: "<driver/uart.h>".}
## *
##  @brief UART read bytes from UART buffer
##
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##  @param buf     pointer to the buffer.
##  @param length  data length
##  @param ticks_to_wait sTimeout, count in RTOS ticks
##
##  @return
##      - (-1) Error
##      - OTHERS (>=0) The number of bytes read from UART FIFO
##

proc uart_read_bytes*(uart_num: uart_port_t; buf: ptr uint8; length: uint32;
                     ticks_to_wait: TickType_t): cint {.cdecl,
    importc: "uart_read_bytes", header: "<driver/uart.h>".}
## *
##  @brief Alias of uart_flush_input.
##         UART ring buffer flush. This will discard all data in the UART RX buffer.
##  @note  Instead of waiting the data sent out, this function will clear UART rx buffer.
##         In order to send all the data in tx FIFO, we can use uart_wait_tx_done function.
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK Success
##      - ESP_FAIL Parameter error
##

proc uart_flush*(uart_num: uart_port_t): esp_err_t {.cdecl, importc: "uart_flush",
    header: "<driver/uart.h>".}
## *
##  @brief Clear input buffer, discard all the data is in the ring-buffer.
##  @note  In order to send all the data in tx FIFO, we can use uart_wait_tx_done function.
##  @param uart_num UART_NUM_0, UART_NUM_1 or UART_NUM_2
##
##  @return
##      - ESP_OK Success
##      - ESP_FAIL Parameter error
##

proc uart_flush_input*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_flush_input", header: "<driver/uart.h>".}
## *
##  @brief   UART get RX ring buffer cached data length
##
##  @param   uart_num UART port number.
##  @param   size Pointer of size_t to accept cached data length
##
##  @return
##      - ESP_OK Success
##      - ESP_FAIL Parameter error
##

proc uart_get_buffered_data_len*(uart_num: uart_port_t; size: ptr csize): esp_err_t {.
    cdecl, importc: "uart_get_buffered_data_len", header: "<driver/uart.h>".}
## *
##  @brief   UART disable pattern detect function.
##           Designed for applications like 'AT commands'.
##           When the hardware detects a series of one same character, the interrupt will be triggered.
##
##  @param uart_num UART port number.
##
##  @return
##      - ESP_OK Success
##      - ESP_FAIL Parameter error
##

proc uart_disable_pattern_det_intr*(uart_num: uart_port_t): esp_err_t {.cdecl,
    importc: "uart_disable_pattern_det_intr", header: "<driver/uart.h>".}
## *
##  @brief UART enable pattern detect function.
##         Designed for applications like 'AT commands'.
##         When the hardware detect a series of one same character, the interrupt will be triggered.
##
##  @param uart_num UART port number.
##  @param pattern_chr character of the pattern
##  @param chr_num number of the character, 8bit value.
##  @param chr_tout timeout of the interval between each pattern characters, 24bit value, unit is APB (80Mhz) clock cycle.
##         When the duration is less than this value, it will not take this data as at_cmd char
##  @param post_idle idle time after the last pattern character, 24bit value, unit is APB (80Mhz) clock cycle.
##         When the duration is less than this value, it will not take the previous data as the last at_cmd char
##  @param pre_idle idle time before the first pattern character, 24bit value, unit is APB (80Mhz) clock cycle.
##         When the duration is less than this value, it will not take this data as the first at_cmd char
##
##  @return
##      - ESP_OK Success
##      - ESP_FAIL Parameter error
##

proc uart_enable_pattern_det_intr*(uart_num: uart_port_t; pattern_chr: char;
                                  chr_num: uint8; chr_tout: cint; post_idle: cint;
                                  pre_idle: cint): esp_err_t {.cdecl,
    importc: "uart_enable_pattern_det_intr", header: "<driver/uart.h>".}
## *
##  @brief Return the nearest detected pattern position in buffer.
##         The positions of the detected pattern are saved in a queue,
##         this function will dequeue the first pattern position and move the pointer to next pattern position.
##  @note  If the RX buffer is full and flow control is not enabled,
##         the detected pattern may not be found in the rx buffer due to overflow.
##
##         The following APIs will modify the pattern position info:
##         uart_flush_input, uart_read_bytes, uart_driver_delete, uart_pop_pattern_pos
##         It is the application's responsibility to ensure atomic access to the pattern queue and the rx data buffer
##         when using pattern detect feature.
##
##  @param uart_num UART port number
##  @return
##      - (-1) No pattern found for current index or parameter error
##      - others the pattern position in rx buffer.
##

proc uart_pattern_pop_pos*(uart_num: uart_port_t): cint {.cdecl,
    importc: "uart_pattern_pop_pos", header: "<driver/uart.h>".}
## *
##  @brief Return the nearest detected pattern position in buffer.
##         The positions of the detected pattern are saved in a queue,
##         This function do nothing to the queue.
##  @note  If the RX buffer is full and flow control is not enabled,
##         the detected pattern may not be found in the rx buffer due to overflow.
##
##         The following APIs will modify the pattern position info:
##         uart_flush_input, uart_read_bytes, uart_driver_delete, uart_pop_pattern_pos
##         It is the application's responsibility to ensure atomic access to the pattern queue and the rx data buffer
##         when using pattern detect feature.
##
##  @param uart_num UART port number
##  @return
##      - (-1) No pattern found for current index or parameter error
##      - others the pattern position in rx buffer.
##

proc uart_pattern_get_pos*(uart_num: uart_port_t): cint {.cdecl,
    importc: "uart_pattern_get_pos", header: "<driver/uart.h>".}
## *
##  @brief Allocate a new memory with the given length to save record the detected pattern position in rx buffer.
##  @param uart_num UART port number
##  @param queue_length Max queue length for the detected pattern.
##         If the queue length is not large enough, some pattern positions might be lost.
##         Set this value to the maximum number of patterns that could be saved in data buffer at the same time.
##  @return
##      - ESP_ERR_NO_MEM No enough memory
##      - ESP_ERR_INVALID_STATE Driver not installed
##      - ESP_FAIL Parameter error
##      - ESP_OK Success
##

proc uart_pattern_queue_reset*(uart_num: uart_port_t; queue_length: cint): esp_err_t {.
    cdecl, importc: "uart_pattern_queue_reset", header: "<driver/uart.h>".}
## *
##  @brief UART set communication mode
##  @note  This function must be executed after uart_driver_install(), when the driver object is initialized.
##  @param uart_num     Uart number to configure
##  @param mode UART    UART mode to set
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc uart_set_mode*(uart_num: uart_port_t; mode: uart_mode_t): esp_err_t {.cdecl,
    importc: "uart_set_mode", header: "<driver/uart.h>".}
## *
##  @brief UART set threshold timeout for TOUT feature
##
##  @param uart_num     Uart number to configure
##  @param tout_thresh  This parameter defines timeout threshold in uart symbol periods. The maximum value of threshold is 126.
##         tout_thresh = 1, defines TOUT interrupt timeout equal to transmission time of one symbol (~11 bit) on current baudrate.
##         If the time is expired the UART_RXFIFO_TOUT_INT interrupt is triggered. If tout_thresh == 0,
##         the TOUT feature is disabled.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_INVALID_STATE Driver is not installed
##

proc uart_set_rx_timeout*(uart_num: uart_port_t; tout_thresh: uint8): esp_err_t {.
    cdecl, importc: "uart_set_rx_timeout", header: "<driver/uart.h>".}
## *
##  @brief Returns collision detection flag for RS485 mode
##         Function returns the collision detection flag into variable pointed by collision_flag.
##         *collision_flag = true, if collision detected else it is equal to false.
##         This function should be executed when actual transmission is completed (after uart_write_bytes()).
##
##  @param uart_num       Uart number to configure
##  @param collision_flag Pointer to variable of type bool to return collision flag.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc uart_get_collision_flag*(uart_num: uart_port_t; collision_flag: ptr bool): esp_err_t {.
    cdecl, importc: "uart_get_collision_flag", header: "<driver/uart.h>".}
## *
##  @brief Set the number of RX pin signal edges for light sleep wakeup
##
##  UART can be used to wake up the system from light sleep. This feature works
##  by counting the number of positive edges on RX pin and comparing the count to
##  the threshold. When the count exceeds the threshold, system is woken up from
##  light sleep. This function allows setting the threshold value.
##
##  Stop bit and parity bits (if enabled) also contribute to the number of edges.
##  For example, letter 'a' with ASCII code 97 is encoded as 0100001101 on the wire
##  (with 8n1 configuration), start and stop bits included. This sequence has 3
##  positive edges (transitions from 0 to 1). Therefore, to wake up the system
##  when 'a' is sent, set wakeup_threshold=3.
##
##  The character that triggers wakeup is not received by UART (i.e. it can not
##  be obtained from UART FIFO). Depending on the baud rate, a few characters
##  after that will also not be received. Note that when the chip enters and exits
##  light sleep mode, APB frequency will be changing. To make sure that UART has
##  correct baud rate all the time, select REF_TICK as UART clock source,
##  by setting use_ref_tick field in uart_config_t to true.
##
##  @note in ESP32, the wakeup signal can only be input via IO_MUX (i.e.
##        GPIO3 should be configured as function_1 to wake up UART0,
##        GPIO9 should be configured as function_5 to wake up UART1), UART2
##        does not support light sleep wakeup feature.
##
##  @param uart_num  UART number
##  @param wakeup_threshold  number of RX edges for light sleep wakeup, value is 3 .. 0x3ff.
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if uart_num is incorrect or wakeup_threshold is
##         outside of [3, 0x3ff] range.
##

proc uart_set_wakeup_threshold*(uart_num: uart_port_t; wakeup_threshold: cint): esp_err_t {.
    cdecl, importc: "uart_set_wakeup_threshold", header: "<driver/uart.h>".}
## *
##  @brief Get the number of RX pin signal edges for light sleep wakeup.
##
##  See description of uart_set_wakeup_threshold for the explanation of UART
##  wakeup feature.
##
##  @param uart_num  UART number
##  @param[out] out_wakeup_threshold  output, set to the current value of wakeup
##                                    threshold for the given UART.
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if out_wakeup_threshold is NULL
##

proc uart_get_wakeup_threshold*(uart_num: uart_port_t;
                               out_wakeup_threshold: ptr cint): esp_err_t {.cdecl,
    importc: "uart_get_wakeup_threshold", header: "<driver/uart.h>".}