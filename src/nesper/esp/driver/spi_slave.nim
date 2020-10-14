##  Copyright 2010-2018 Espressif Systems (Shanghai) PTE LTD
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
  esp_err, freertos/FreeRTOS, freertos/semphr, driver/spi_common

const
  SPI_SLAVE_TXBIT_LSBFIRST* = (1 shl 0) ## /< Transmit command/address/data LSB first instead of the default MSB first
  SPI_SLAVE_RXBIT_LSBFIRST* = (1 shl 1) ## /< Receive data LSB first instead of the default MSB first
  SPI_SLAVE_BIT_LSBFIRST* = (SPI_SLAVE_TXBIT_LSBFIRST or SPI_SLAVE_RXBIT_LSBFIRST) ## /< Transmit and receive LSB first

type
  slave_transaction_cb_t* = proc (trans: ptr spi_slave_transaction_t)

## *
##  @brief This is a configuration for a SPI host acting as a slave device.
##

type
  spi_slave_interface_config_t* {.importc: "spi_slave_interface_config_t",
                                 header: "spi_slave.h", bycopy.} = object
    spics_io_num* {.importc: "spics_io_num".}: cint ## /< CS GPIO pin for this device
    flags* {.importc: "flags".}: uint32 ## /< Bitwise OR of SPI_SLAVE_* flags
    queue_size* {.importc: "queue_size".}: cint ## /< Transaction queue size. This sets how many transactions can be 'in the air' (queued using spi_slave_queue_trans but not yet finished using spi_slave_get_trans_result) at the same time
    mode* {.importc: "mode".}: uint8 ## /< SPI mode (0-3)
    post_setup_cb* {.importc: "post_setup_cb".}: slave_transaction_cb_t ## *< Callback called after the SPI registers are loaded with new data.
                                                                    ##
                                                                    ##   This callback is called within interrupt
                                                                    ##   context should be in IRAM for best
                                                                    ##   performance, see "Transferring Speed"
                                                                    ##   section in the SPI Master documentation for
                                                                    ##   full details. If not, the callback may crash
                                                                    ##   during flash operation when the driver is
                                                                    ##   initialized with ESP_INTR_FLAG_IRAM.
                                                                    ##
    post_trans_cb* {.importc: "post_trans_cb".}: slave_transaction_cb_t ## *< Callback called after a transaction is done.
                                                                    ##
                                                                    ##   This callback is called within interrupt
                                                                    ##   context should be in IRAM for best
                                                                    ##   performance, see "Transferring Speed"
                                                                    ##   section in the SPI Master documentation for
                                                                    ##   full details. If not, the callback may crash
                                                                    ##   during flash operation when the driver is
                                                                    ##   initialized with ESP_INTR_FLAG_IRAM.
                                                                    ##


## *
##  This structure describes one SPI transaction
##

type
  spi_slave_transaction_t* {.importc: "spi_slave_transaction_t",
                            header: "spi_slave.h", bycopy.} = object
    length* {.importc: "length".}: csize_t ## /< Total data length, in bits
    trans_len* {.importc: "trans_len".}: csize_t ## /< Transaction data length, in bits
    tx_buffer* {.importc: "tx_buffer".}: pointer ## /< Pointer to transmit buffer, or NULL for no MOSI phase
    rx_buffer* {.importc: "rx_buffer".}: pointer ## *< Pointer to receive buffer, or NULL for no MISO phase.
                                             ##  When the DMA is anabled, must start at WORD boundary (``rx_buffer%4==0``),
                                             ##  and has length of a multiple of 4 bytes.
                                             ##
    user* {.importc: "user".}: pointer ## /< User-defined variable. Can be used to store eg transaction ID.


## *
##  @brief Initialize a SPI bus as a slave interface
##
##  @warning For now, only supports HSPI and VSPI.
##
##  @param host SPI peripheral to use as a SPI slave interface
##  @param bus_config Pointer to a spi_bus_config_t struct specifying how the host should be initialized
##  @param slave_config Pointer to a spi_slave_interface_config_t struct specifying the details for the slave interface
##  @param dma_chan Either 1 or 2. A SPI bus used by this driver must have a DMA channel associated with
##                  it. The SPI hardware has two DMA channels to share. This parameter indicates which
##                  one to use.
##
##  @warning If a DMA channel is selected, any transmit and receive buffer used should be allocated in
##           DMA-capable memory.
##
##  @warning The ISR of SPI is always executed on the core which calls this
##           function. Never starve the ISR on this core or the SPI transactions will not
##           be handled.
##
##  @return
##          - ESP_ERR_INVALID_ARG   if configuration is invalid
##          - ESP_ERR_INVALID_STATE if host already is in use
##          - ESP_ERR_NO_MEM        if out of memory
##          - ESP_OK                on success
##

proc spi_slave_initialize*(host: spi_host_device_t;
                          bus_config: ptr spi_bus_config_t;
                          slave_config: ptr spi_slave_interface_config_t;
                          dma_chan: cint): esp_err_t {.
    importc: "spi_slave_initialize", header: "spi_slave.h".}
## *
##  @brief Free a SPI bus claimed as a SPI slave interface
##
##  @param host SPI peripheral to free
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_INVALID_STATE if not all devices on the bus are freed
##          - ESP_OK                on success
##

proc spi_slave_free*(host: spi_host_device_t): esp_err_t {.
    importc: "spi_slave_free", header: "spi_slave.h".}
## *
##  @brief Queue a SPI transaction for execution
##
##  Queues a SPI transaction to be executed by this slave device. (The transaction queue size was specified when the slave
##  device was initialised via spi_slave_initialize.) This function may block if the queue is full (depending on the
##  ticks_to_wait parameter). No SPI operation is directly initiated by this function, the next queued transaction
##  will happen when the master initiates a SPI transaction by pulling down CS and sending out clock signals.
##
##  This function hands over ownership of the buffers in ``trans_desc`` to the SPI slave driver; the application is
##  not to access this memory until ``spi_slave_queue_trans`` is called to hand ownership back to the application.
##
##  @param host SPI peripheral that is acting as a slave
##  @param trans_desc Description of transaction to execute. Not const because we may want to write status back
##                    into the transaction description.
##  @param ticks_to_wait Ticks to wait until there's room in the queue; use portMAX_DELAY to
##                       never time out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spi_slave_queue_trans*(host: spi_host_device_t;
                           trans_desc: ptr spi_slave_transaction_t;
                           ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_slave_queue_trans", header: "spi_slave.h".}
## *
##  @brief Get the result of a SPI transaction queued earlier
##
##  This routine will wait until a transaction to the given device (queued earlier with
##  spi_slave_queue_trans) has succesfully completed. It will then return the description of the
##  completed transaction so software can inspect the result and e.g. free the memory or
##  re-use the buffers.
##
##  It is mandatory to eventually use this function for any transaction queued by ``spi_slave_queue_trans``.
##
##  @param host SPI peripheral to that is acting as a slave
##  @param[out] trans_desc Pointer to variable able to contain a pointer to the description of the
##                    transaction that is executed
##  @param ticks_to_wait Ticks to wait until there's a returned item; use portMAX_DELAY to never time
##                       out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spi_slave_get_trans_result*(host: spi_host_device_t;
                                trans_desc: ptr ptr spi_slave_transaction_t;
                                ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_slave_get_trans_result", header: "spi_slave.h".}
## *
##  @brief Do a SPI transaction
##
##  Essentially does the same as spi_slave_queue_trans followed by spi_slave_get_trans_result. Do
##  not use this when there is still a transaction queued that hasn't been finalized
##  using spi_slave_get_trans_result.
##
##  @param host SPI peripheral to that is acting as a slave
##  @param trans_desc Pointer to variable able to contain a pointer to the description of the
##                    transaction that is executed. Not const because we may want to write status back
##                    into the transaction description.
##  @param ticks_to_wait Ticks to wait until there's a returned item; use portMAX_DELAY to never time
##                       out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spi_slave_transmit*(host: spi_host_device_t;
                        trans_desc: ptr spi_slave_transaction_t;
                        ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_slave_transmit", header: "spi_slave.h".}