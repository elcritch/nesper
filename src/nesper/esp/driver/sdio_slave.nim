##  Copyright 2015-2018 Espressif Systems (Shanghai) PTE LTD
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
  freertos/FreeRTOS, freertos/portmacro, esp_err, sys/queue, soc/sdio_slave_periph

const
  SDIO_SLAVE_RECV_MAX_BUFFER* = (4096 - 4)

type
  sdio_event_cb_t* = proc (event: uint8)

## / Mask of interrupts sending to the host.

type
  sdio_slave_hostint_t* {.size: sizeof(cint).} = enum
    SDIO_SLAVE_HOSTINT_SEND_NEW_PACKET = HOST_SLC0_RX_NEW_PACKET_INT_ENA, ## /< New packet available
    SDIO_SLAVE_HOSTINT_RECV_OVF = HOST_SLC0_TX_OVF_INT_ENA, ## /< Slave receive buffer overflow
    SDIO_SLAVE_HOSTINT_SEND_UDF = HOST_SLC0_RX_UDF_INT_ENA, ## /< Slave sending buffer underflow (this case only happen when the host do not request for packet according to the packet len).
    SDIO_SLAVE_HOSTINT_BIT7 = HOST_SLC0_TOHOST_BIT7_INT_ENA, ## /< General purpose interrupt bits that can be used by the user.
    SDIO_SLAVE_HOSTINT_BIT6 = HOST_SLC0_TOHOST_BIT6_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT5 = HOST_SLC0_TOHOST_BIT5_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT4 = HOST_SLC0_TOHOST_BIT4_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT3 = HOST_SLC0_TOHOST_BIT3_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT2 = HOST_SLC0_TOHOST_BIT2_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT1 = HOST_SLC0_TOHOST_BIT1_INT_ENA,
    SDIO_SLAVE_HOSTINT_BIT0 = HOST_SLC0_TOHOST_BIT0_INT_ENA


## / Timing of SDIO slave

type
  sdio_slave_timing_t* {.size: sizeof(cint).} = enum
    SDIO_SLAVE_TIMING_PSEND_PSAMPLE = 0, ## *< Send at posedge, and sample at posedge. Default value for HS mode.
                                      ##    Normally there's no problem using this to work in DS mode.
                                      ##
    SDIO_SLAVE_TIMING_NSEND_PSAMPLE, ## /< Send at negedge, and sample at posedge. Default value for DS mode and below.
    SDIO_SLAVE_TIMING_PSEND_NSAMPLE, ## /< Send at posedge, and sample at negedge
    SDIO_SLAVE_TIMING_NSEND_NSAMPLE ## /< Send at negedge, and sample at negedge


## / Configuration of SDIO slave mode

type
  sdio_slave_sending_mode_t* {.size: sizeof(cint).} = enum
    SDIO_SLAVE_SEND_STREAM = 0, ## /< Stream mode, all packets to send will be combined as one if possible
    SDIO_SLAVE_SEND_PACKET = 1  ## /< Packet mode, one packets will be sent one after another (only increase packet_len if last packet sent).


## / Configuration of SDIO slave

const
  SDIO_SLAVE_FLAG_DAT2_DISABLED* = BIT(0) ## *< It is required by the SD specification that all 4 data
                                       ##         lines should be used and pulled up even in 1-bit mode or SPI mode. However, as a feature, the user can specify
                                       ##         this flag to make use of DAT2 pin in 1-bit mode. Note that the host cannot read CCCR registers to know we don't
                                       ##         support 4-bit mode anymore, please do this at your own risk.
                                       ##
  SDIO_SLAVE_FLAG_HOST_INTR_DISABLED* = BIT(1) ## *< The DAT1 line is used as the interrupt line in SDIO
                                            ##         protocol. However, as a feature, the user can specify this flag to make use of DAT1 pin of the slave in 1-bit
                                            ##         mode. Note that the host has to do polling to the interrupt registers to know whether there are interrupts from
                                            ##         the slave. And it cannot read CCCR registers to know we don't support 4-bit mode anymore, please do this at
                                            ##         your own risk.
                                            ##
  SDIO_SLAVE_FLAG_INTERNAL_PULLUP* = BIT(2) ## *< Enable internal pullups for enabled pins. It is required
                                         ##         by the SD specification that all the 4 data lines should be pulled up even in 1-bit mode or SPI mode. Note that
                                         ##         the internal pull-ups are not sufficient for stable communication, please do connect external pull-ups on the
                                         ##         bus. This is only for example and debug use.
                                         ##

type
  sdio_slave_config_t* {.importc: "sdio_slave_config_t", header: "sdio_slave.h",
                        bycopy.} = object
    timing* {.importc: "timing".}: sdio_slave_timing_t ## /< timing of sdio_slave. see `sdio_slave_timing_t`.
    sending_mode* {.importc: "sending_mode".}: sdio_slave_sending_mode_t ## /< mode of sdio_slave. `SDIO_SLAVE_MODE_STREAM` if the data needs to be sent as much as possible; `SDIO_SLAVE_MODE_PACKET` if the data should be sent in packets.
    send_queue_size* {.importc: "send_queue_size".}: cint ## /< max buffers that can be queued before sending.
    recv_buffer_size* {.importc: "recv_buffer_size".}: csize_t ## /< If buffer_size is too small, it costs more CPU time to handle larger number of buffers.
                                                           ## /< If buffer_size is too large, the space larger than the transaction length is left blank but still counts a buffer, and the buffers are easily run out.
                                                           ## /< Should be set according to length of data really transferred.
                                                           ## /< All data that do not fully fill a buffer is still counted as one buffer. E.g. 10 bytes data costs 2 buffers if the size is 8 bytes per buffer.
                                                           ## /< Buffer size of the slave pre-defined between host and slave before communication. All receive buffer given to the driver should be larger than this.
    event_cb* {.importc: "event_cb".}: sdio_event_cb_t ## /< when the host interrupts slave, this callback will be called with interrupt number (0-7).
    flags* {.importc: "flags".}: uint32 ## /< Features to be enabled for the slave, combinations of ``SDIO_SLAVE_FLAG_*``.


## * Handle of a receive buffer, register a handle by calling ``sdio_slave_recv_register_buf``. Use the handle to load the buffer to the
##   driver, or call ``sdio_slave_recv_unregister_buf`` if it is no longer used.
##

type
  sdio_slave_buf_handle_t* = pointer

## * Initialize the sdio slave driver
##
##  @param config Configuration of the sdio slave driver.
##
##  @return
##      - ESP_ERR_NOT_FOUND if no free interrupt found.
##      - ESP_ERR_INVALID_STATE if already initialized.
##      - ESP_ERR_NO_MEM if fail due to memory allocation failed.
##      - ESP_OK if success
##

proc sdio_slave_initialize*(config: ptr sdio_slave_config_t): esp_err_t {.
    importc: "sdio_slave_initialize", header: "sdio_slave.h".}
## * De-initialize the sdio slave driver to release the resources.
##

proc sdio_slave_deinit*() {.importc: "sdio_slave_deinit", header: "sdio_slave.h".}
## * Start hardware for sending and receiving, as well as set the IOREADY1 to 1.
##
##  @note The driver will continue sending from previous data and PKT_LEN counting, keep data received as well as start receiving from current TOKEN1 counting.
##  See ``sdio_slave_reset``.
##
##  @return
##   - ESP_ERR_INVALID_STATE if already started.
##   - ESP_OK otherwise.
##

proc sdio_slave_start*(): esp_err_t {.importc: "sdio_slave_start",
                                   header: "sdio_slave.h".}
## * Stop hardware from sending and receiving, also set IOREADY1 to 0.
##
##  @note this will not clear the data already in the driver, and also not reset the PKT_LEN and TOKEN1 counting. Call ``sdio_slave_reset`` to do that.
##

proc sdio_slave_stop*() {.importc: "sdio_slave_stop", header: "sdio_slave.h".}
## * Clear the data still in the driver, as well as reset the PKT_LEN and TOKEN1 counting.
##
##  @return always return ESP_OK.
##

proc sdio_slave_reset*(): esp_err_t {.importc: "sdio_slave_reset",
                                   header: "sdio_slave.h".}
## ---------------------------------------------------------------------------
##                   Receive
## --------------------------------------------------------------------------
## * Register buffer used for receiving. All buffers should be registered before used, and then can be used (again) in the driver by the handle returned.
##
##  @param start The start address of the buffer.
##
##  @note The driver will use and only use the amount of space specified in the `recv_buffer_size` member set in the `sdio_slave_config_t`.
##        All buffers should be larger than that. The buffer is used by the DMA, so it should be DMA capable and 32-bit aligned.
##
##  @return The buffer handle if success, otherwise NULL.
##

proc sdio_slave_recv_register_buf*(start: ptr uint8): sdio_slave_buf_handle_t {.
    importc: "sdio_slave_recv_register_buf", header: "sdio_slave.h".}
## * Unregister buffer from driver, and free the space used by the descriptor pointing to the buffer.
##
##  @param handle Handle to the buffer to release.
##
##  @return ESP_OK if success, ESP_ERR_INVALID_ARG if the handle is NULL or the buffer is being used.
##

proc sdio_slave_recv_unregister_buf*(handle: sdio_slave_buf_handle_t): esp_err_t {.
    importc: "sdio_slave_recv_unregister_buf", header: "sdio_slave.h".}
## * Load buffer to the queue waiting to receive data. The driver takes ownership of the buffer until the buffer is returned by
##   ``sdio_slave_send_get_finished`` after the transaction is finished.
##
##  @param handle Handle to the buffer ready to receive data.
##
##  @return
##      - ESP_ERR_INVALID_ARG    if invalid handle or the buffer is already in the queue. Only after the buffer is returened by
##                               ``sdio_slave_recv`` can you load it again.
##      - ESP_OK if success
##

proc sdio_slave_recv_load_buf*(handle: sdio_slave_buf_handle_t): esp_err_t {.
    importc: "sdio_slave_recv_load_buf", header: "sdio_slave.h".}
## * Get received data if exist. The driver returns the ownership of the buffer to the app.
##
##  @param handle_ret Handle to the buffer holding received data. Use this handle in ``sdio_slave_recv_load_buf`` to receive in the same buffer again.
##  @param[out] out_addr Output of the start address, set to NULL if not needed.
##  @param[out] out_len Actual length of the data in the buffer, set to NULL if not needed.
##  @param wait Time to wait before data received.
##
##  @note Call ``sdio_slave_load_buf`` with the handle to re-load the buffer onto the link list, and receive with the same buffer again.
##        The address and length of the buffer got here is the same as got from `sdio_slave_get_buffer`.
##
##  @return
##      - ESP_ERR_INVALID_ARG    if handle_ret is NULL
##      - ESP_ERR_TIMEOUT        if timeout before receiving new data
##      - ESP_OK if success
##

proc sdio_slave_recv*(handle_ret: ptr sdio_slave_buf_handle_t;
                     out_addr: ptr ptr uint8; out_len: ptr csize_t; wait: TickType_t): esp_err_t {.
    importc: "sdio_slave_recv", header: "sdio_slave.h".}
## * Retrieve the buffer corresponding to a handle.
##
##  @param handle Handle to get the buffer.
##  @param len_o Output of buffer length
##
##  @return buffer address if success, otherwise NULL.
##

proc sdio_slave_recv_get_buf*(handle: sdio_slave_buf_handle_t; len_o: ptr csize_t): ptr uint8 {.
    importc: "sdio_slave_recv_get_buf", header: "sdio_slave.h".}
## ---------------------------------------------------------------------------
##                   Send
## --------------------------------------------------------------------------
## * Put a new sending transfer into the send queue. The driver takes ownership of the buffer until the buffer is returned by
##   ``sdio_slave_send_get_finished`` after the transaction is finished.
##
##  @param addr Address for data to be sent. The buffer should be DMA capable and 32-bit aligned.
##  @param len Length of the data, should not be longer than 4092 bytes (may support longer in the future).
##  @param arg Argument to returned in ``sdio_slave_send_get_finished``. The argument can be used to indicate which transaction is done,
##             or as a parameter for a callback. Set to NULL if not needed.
##  @param wait Time to wait if the buffer is full.
##
##  @return
##      - ESP_ERR_INVALID_ARG if the length is not greater than 0.
##      - ESP_ERR_TIMEOUT if the queue is still full until timeout.
##      - ESP_OK if success.
##

proc sdio_slave_send_queue*(`addr`: ptr uint8; len: csize_t; arg: pointer;
                           wait: TickType_t): esp_err_t {.
    importc: "sdio_slave_send_queue", header: "sdio_slave.h".}
## * Return the ownership of a finished transaction.
##  @param out_arg Argument of the finished transaction. Set to NULL if unused.
##  @param wait Time to wait if there's no finished sending transaction.
##
##  @return ESP_ERR_TIMEOUT if no transaction finished, or ESP_OK if succeed.
##

proc sdio_slave_send_get_finished*(out_arg: ptr pointer; wait: TickType_t): esp_err_t {.
    importc: "sdio_slave_send_get_finished", header: "sdio_slave.h".}
## * Start a new sending transfer, and wait for it (blocked) to be finished.
##
##  @param addr Start address of the buffer to send
##  @param len Length of buffer to send.
##
##  @return
##      - ESP_ERR_INVALID_ARG if the length of descriptor is not greater than 0.
##      - ESP_ERR_TIMEOUT if the queue is full or host do not start a transfer before timeout.
##      - ESP_OK if success.
##

proc sdio_slave_transmit*(`addr`: ptr uint8; len: csize_t): esp_err_t {.
    importc: "sdio_slave_transmit", header: "sdio_slave.h".}
## ---------------------------------------------------------------------------
##                   Host
## --------------------------------------------------------------------------
## * Read the spi slave register shared with host.
##
##  @param pos register address, 0-27 or 32-63.
##
##  @note register 28 to 31 are reserved for interrupt vector.
##
##  @return value of the register.
##

proc sdio_slave_read_reg*(pos: cint): uint8 {.importc: "sdio_slave_read_reg",
    header: "sdio_slave.h".}
## * Write the spi slave register shared with host.
##
##  @param pos register address, 0-11, 14-15, 18-19, 24-27 and 32-63, other address are reserved.
##  @param reg the value to write.
##
##  @note register 29 and 31 are used for interrupt vector.
##
##  @return ESP_ERR_INVALID_ARG if address wrong, otherwise ESP_OK.
##

proc sdio_slave_write_reg*(pos: cint; reg: uint8): esp_err_t {.
    importc: "sdio_slave_write_reg", header: "sdio_slave.h".}
## * Get the interrupt enable for host.
##
##  @return the interrupt mask.
##

proc sdio_slave_get_host_intena*(): sdio_slave_hostint_t {.
    importc: "sdio_slave_get_host_intena", header: "sdio_slave.h".}
## * Set the interrupt enable for host.
##
##  @param ena Enable mask for host interrupt.
##

proc sdio_slave_set_host_intena*(ena: sdio_slave_hostint_t) {.
    importc: "sdio_slave_set_host_intena", header: "sdio_slave.h".}
## * Interrupt the host by general purpose interrupt.
##
##  @param pos Interrupt num, 0-7.
##
##  @return
##      - ESP_ERR_INVALID_ARG if interrupt num error
##      - ESP_OK otherwise
##

proc sdio_slave_send_host_int*(pos: uint8): esp_err_t {.
    importc: "sdio_slave_send_host_int", header: "sdio_slave.h".}
## * Clear general purpose interrupt to host.
##
##  @param mask Interrupt bits to clear, by bit mask.
##

proc sdio_slave_clear_host_int*(mask: uint8) {.
    importc: "sdio_slave_clear_host_int", header: "sdio_slave.h".}
## * Wait for general purpose interrupt from host.
##
##  @param pos Interrupt source number to wait for.
##  is set.
##  @param wait Time to wait before interrupt triggered.
##
##  @note this clears the interrupt at the same time.
##
##  @return ESP_OK if success, ESP_ERR_TIMEOUT if timeout.
##

proc sdio_slave_wait_int*(pos: cint; wait: TickType_t): esp_err_t {.
    importc: "sdio_slave_wait_int", header: "sdio_slave.h".}