##  Copyright 2010-2019 Espressif Systems (Shanghai) PTE LTD
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

import ../consts

## for spi_bus_initialization funcions. to be back-compatible

const
  SPI_MAX_DMA_LEN* = (4096 - 4)

## *
##  Transform unsigned integer of length <= 32 bits to the format which can be
##  sent by the SPI driver directly.
##
##  E.g. to send 9 bits of data, you can:
##
##       uint16 data = SPI_SWAP_DATA_TX(0x145, 9);
##
##  Then points tx_buffer to ``&data``.
##
##  @param DATA Data to be sent, can be uint8, uint16 or uint32.
##  @param LEN Length of data to be sent, since the SPI peripheral sends from
##       the MSB, this helps to shift the data to the MSB.
##

proc SPI_SWAP_DATA_TX*(DATA, LEN: uint32): uint32 = {.importc: "SPI_SWAP_DATA_TX", header: "spi_common.h".}


## *
##  Transform received data of length <= 32 bits to the format of an unsigned integer.
##
##  E.g. to transform the data of 15 bits placed in a 4-byte array to integer:
##
##       uint16 data = SPI_SWAP_DATA_RX(*(uint32*)t->rx_data, 15);
##
##  @param DATA Data to be rearranged, can be uint8, uint16 or uint32.
##  @param LEN Length of data received, since the SPI peripheral writes from
##       the MSB, this helps to shift the data to the LSB.
##

proc SPI_SWAP_DATA_RX*(DATA, LEN: uint32): uint32 = {.importc: "SPI_SWAP_DATA_RX", header: "spi_common.h".}

const
  SPICOMMON_BUSFLAG_SLAVE* = 0
  SPICOMMON_BUSFLAG_MASTER* = (1 shl 0) ## /< Initialize I/O in master mode
  SPICOMMON_BUSFLAG_IOMUX_PINS* = (1 shl 1) ## /< Check using iomux pins. Or indicates the pins are configured through the IO mux rather than GPIO matrix.
  SPICOMMON_BUSFLAG_SCLK* = (1 shl 2) ## /< Check existing of SCLK pin. Or indicates CLK line initialized.
  SPICOMMON_BUSFLAG_MISO* = (1 shl 3) ## /< Check existing of MISO pin. Or indicates MISO line initialized.
  SPICOMMON_BUSFLAG_MOSI* = (1 shl 4) ## /< Check existing of MOSI pin. Or indicates CLK line initialized.
  SPICOMMON_BUSFLAG_DUAL* = (1 shl 5) ## /< Check MOSI and MISO pins can output. Or indicates bus able to work under DIO mode.
  SPICOMMON_BUSFLAG_WPHD* = (1 shl 6) ## /< Check existing of WP and HD pins. Or indicates WP & HD pins initialized.
  SPICOMMON_BUSFLAG_QUAD* = (SPICOMMON_BUSFLAG_DUAL or SPICOMMON_BUSFLAG_WPHD) ## /< Check existing of MOSI/MISO/WP/HD pins as output. Or indicates bus able to work under QIO mode.
  SPICOMMON_BUSFLAG_NATIVE_PINS* = SPICOMMON_BUSFLAG_IOMUX_PINS

## *
##  @brief This is a configuration structure for a SPI bus.
##
##  You can use this structure to specify the GPIO pins of the bus. Normally, the driver will use the
##  GPIO matrix to route the signals. An exception is made when all signals either can be routed through
##  the IO_MUX or are -1. In that case, the IO_MUX is used, allowing for >40MHz speeds.
##
##  @note Be advised that the slave driver does not use the quadwp/quadhd lines and fields in spi_bus_config_t refering to these lines will be ignored and can thus safely be left uninitialized.
##

type
  spi_bus_config_t* {.importc: "spi_bus_config_t", header: "spi_common.h", bycopy.} = object
    mosi_io_num* {.importc: "mosi_io_num".}: cint ## /< GPIO pin for Master Out Slave In (=spi_d) signal, or -1 if not used.
    miso_io_num* {.importc: "miso_io_num".}: cint ## /< GPIO pin for Master In Slave Out (=spi_q) signal, or -1 if not used.
    sclk_io_num* {.importc: "sclk_io_num".}: cint ## /< GPIO pin for Spi CLocK signal, or -1 if not used.
    quadwp_io_num* {.importc: "quadwp_io_num".}: cint ## /< GPIO pin for WP (Write Protect) signal which is used as D2 in 4-bit communication modes, or -1 if not used.
    quadhd_io_num* {.importc: "quadhd_io_num".}: cint ## /< GPIO pin for HD (HolD) signal which is used as D3 in 4-bit communication modes, or -1 if not used.
    max_transfer_sz* {.importc: "max_transfer_sz".}: cint ## /< Maximum transfer size, in bytes. Defaults to 4094 if 0.
    flags* {.importc: "flags".}: uint32 ## /< Abilities of bus to be checked by the driver. Or-ed value of ``SPICOMMON_BUSFLAG_*`` flags.
    intr_flags* {.importc: "intr_flags".}: cint ## *< Interrupt flag for the bus to set the priority, and IRAM attribute, see
                                            ##   ``esp_intr_alloc.h``. Note that the EDGE, INTRDISABLED attribute are ignored
                                            ##   by the driver. Note that if ESP_INTR_FLAG_IRAM is set, ALL the callbacks of
                                            ##   the driver, and their callee functions, should be put in the IRAM.
                                            ##


## *
##  @brief Initialize a SPI bus
##
##  @warning For now, only supports HSPI and VSPI.
##
##  @param host_id SPI peripheral that controls this bus
##  @param bus_config Pointer to a spi_bus_config_t struct specifying how the host should be initialized
##  @param dma_chan Either channel 1 or 2, or 0 in the case when no DMA is required. Selecting a DMA channel
##                  for a SPI bus allows transfers on the bus to have sizes only limited by the amount of
##                  internal memory. Selecting no DMA channel (by passing the value 0) limits the amount of
##                  bytes transfered to a maximum of 64. Set to 0 if only the SPI flash uses
##                  this bus.
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

proc spi_bus_initialize*(host_id: spi_host_device_t;
                        bus_config: ptr spi_bus_config_t; dma_chan: cint): esp_err_t {.
    importc: "spi_bus_initialize", header: "spi_common.h".}
## *
##  @brief Free a SPI bus
##
##  @warning In order for this to succeed, all devices have to be removed first.
##
##  @param host_id SPI peripheral to free
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_INVALID_STATE if not all devices on the bus are freed
##          - ESP_OK                on success
##

proc spi_bus_free*(host_id: spi_host_device_t): esp_err_t {.importc: "spi_bus_free",
    header: "spi_common.h".}


## * SPI master clock is divided by 80MHz apb clock. Below defines are example frequencies, and are accurate. Be free to specify a random frequency, it will be rounded to closest frequency (to macros below if above 8MHz).
##  8MHz
##

when APB_CLK_FREQ == 80 * 1000 * 1000:
  const
    SPI_MASTER_FREQ_8M* = (APB_CLK_FREQ div 10)
    SPI_MASTER_FREQ_9M* = (APB_CLK_FREQ div 9) ## /< 8.89MHz
    SPI_MASTER_FREQ_10M* = (APB_CLK_FREQ div 8) ## /< 10MHz
    SPI_MASTER_FREQ_11M* = (APB_CLK_FREQ div 7) ## /< 11.43MHz
    SPI_MASTER_FREQ_13M* = (APB_CLK_FREQ div 6) ## /< 13.33MHz
    SPI_MASTER_FREQ_16M* = (APB_CLK_FREQ div 5) ## /< 16MHz
    SPI_MASTER_FREQ_20M* = (APB_CLK_FREQ div 4) ## /< 20MHz
    SPI_MASTER_FREQ_26M* = (APB_CLK_FREQ div 3) ## /< 26.67MHz
    SPI_MASTER_FREQ_40M* = (APB_CLK_FREQ div 2) ## /< 40MHz
    SPI_MASTER_FREQ_80M* = (APB_CLK_FREQ div 1) ## /< 80MHz
elif APB_CLK_FREQ == 40 * 1000 * 1000:
  const
    SPI_MASTER_FREQ_7M* = (APB_CLK_FREQ div 6) ## /< 13.33MHz
    SPI_MASTER_FREQ_8M* = (APB_CLK_FREQ div 5) ## /< 16MHz
    SPI_MASTER_FREQ_10M* = (APB_CLK_FREQ div 4) ## /< 20MHz
    SPI_MASTER_FREQ_13M* = (APB_CLK_FREQ div 3) ## /< 26.67MHz
    SPI_MASTER_FREQ_20M* = (APB_CLK_FREQ div 2) ## /< 40MHz
    SPI_MASTER_FREQ_40M* = (APB_CLK_FREQ div 1) ## /< 80MHz
const
  SPI_DEVICE_TXBIT_LSBFIRST* = (1 shl 0) ## /< Transmit command/address/data LSB first instead of the default MSB first
  SPI_DEVICE_RXBIT_LSBFIRST* = (1 shl 1) ## /< Receive data LSB first instead of the default MSB first
  SPI_DEVICE_BIT_LSBFIRST* = (
    SPI_DEVICE_TXBIT_LSBFIRST or SPI_DEVICE_RXBIT_LSBFIRST) ## /< Transmit and receive LSB first
  SPI_DEVICE_3WIRE* = (1 shl 2)   ## /< Use MOSI (=spid) for both sending and receiving data
  SPI_DEVICE_POSITIVE_CS* = (1 shl 3) ## /< Make CS positive during a transaction instead of negative
  SPI_DEVICE_HALFDUPLEX* = (1 shl 4) ## /< Transmit data before receiving it, instead of simultaneously
  SPI_DEVICE_CLK_AS_CS* = (1 shl 5) ## /< Output clock on CS line if CS is active
                               ## * There are timing issue when reading at high frequency (the frequency is related to whether iomux pins are used, valid time after slave sees the clock).
                               ##      - In half-duplex mode, the driver automatically inserts dummy bits before reading phase to fix the timing issue. Set this flag to disable this feature.
                               ##      - In full-duplex mode, however, the hardware cannot use dummy bits, so there is no way to prevent data being read from getting corrupted.
                               ##        Set this flag to confirm that you're going to work with output only, or read without dummy bits at your own risk.
                               ##
  SPI_DEVICE_NO_DUMMY* = (1 shl 6)
  SPI_DEVICE_DDRCLK* = (1 shl 7)

type
  transaction_cb_t* = proc (trans: ptr spi_transaction_t)

## *
##  @brief This is a configuration for a SPI slave device that is connected to one of the SPI buses.
##

type
  spi_device_interface_config_t* {.importc: "spi_device_interface_config_t",
                                  header: "spi_master.h", bycopy.} = object
    command_bits* {.importc: "command_bits".}: uint8 ## /< Default amount of bits in command phase (0-16), used when ``SPI_TRANS_VARIABLE_CMD`` is not used, otherwise ignored.
    address_bits* {.importc: "address_bits".}: uint8 ## /< Default amount of bits in address phase (0-64), used when ``SPI_TRANS_VARIABLE_ADDR`` is not used, otherwise ignored.
    dummy_bits* {.importc: "dummy_bits".}: uint8 ## /< Amount of dummy bits to insert between address and data phase
    mode* {.importc: "mode".}: uint8 ## /< SPI mode (0-3)
    duty_cycle_pos* {.importc: "duty_cycle_pos".}: uint16 ## /< Duty cycle of positive clock, in 1/256th increments (128 = 50%/50% duty). Setting this to 0 (=not setting it) is equivalent to setting this to 128.
    cs_ena_pretrans* {.importc: "cs_ena_pretrans".}: uint16 ## /< Amount of SPI bit-cycles the cs should be activated before the transmission (0-16). This only works on half-duplex transactions.
    cs_ena_posttrans* {.importc: "cs_ena_posttrans".}: uint8 ## /< Amount of SPI bit-cycles the cs should stay active after the transmission (0-16)
    clock_speed_hz* {.importc: "clock_speed_hz".}: cint ## /< Clock speed, divisors of 80MHz, in Hz. See ``SPI_MASTER_FREQ_*``.
    input_delay_ns* {.importc: "input_delay_ns".}: cint ## *< Maximum data valid time of slave. The time required between SCLK and MISO
                                                    ##         valid, including the possible clock delay from slave to master. The driver uses this value to give an extra
                                                    ##         delay before the MISO is ready on the line. Leave at 0 unless you know you need a delay. For better timing
                                                    ##         performance at high frequency (over 8MHz), it's suggest to have the right value.
                                                    ##
    spics_io_num* {.importc: "spics_io_num".}: cint ## /< CS GPIO pin for this device, or -1 if not used
    flags* {.importc: "flags".}: uint32 ## /< Bitwise OR of SPI_DEVICE_* flags
    queue_size* {.importc: "queue_size".}: cint ## /< Transaction queue size. This sets how many transactions can be 'in the air' (queued using spi_device_queue_trans but not yet finished using spi_device_get_trans_result) at the same time
    pre_cb* {.importc: "pre_cb".}: transaction_cb_t ## *< Callback to be called before a transmission is started.
                                                ##
                                                ##   This callback is called within interrupt
                                                ##   context should be in IRAM for best
                                                ##   performance, see "Transferring Speed"
                                                ##   section in the SPI Master documentation for
                                                ##   full details. If not, the callback may crash
                                                ##   during flash operation when the driver is
                                                ##   initialized with ESP_INTR_FLAG_IRAM.
                                                ##
    post_cb* {.importc: "post_cb".}: transaction_cb_t ## *< Callback to be called after a transmission has completed.
                                                  ##
                                                  ##   This callback is called within interrupt
                                                  ##   context should be in IRAM for best
                                                  ##   performance, see "Transferring Speed"
                                                  ##   section in the SPI Master documentation for
                                                  ##   full details. If not, the callback may crash
                                                  ##   during flash operation when the driver is
                                                  ##   initialized with ESP_INTR_FLAG_IRAM.
                                                  ##


const
  SPI_TRANS_MODE_DIO* = (1 shl 0) ## /< Transmit/receive data in 2-bit mode
  SPI_TRANS_MODE_QIO* = (1 shl 1) ## /< Transmit/receive data in 4-bit mode
  SPI_TRANS_USE_RXDATA* = (1 shl 2) ## /< Receive into rx_data member of spi_transaction_t instead into memory at rx_buffer.
  SPI_TRANS_USE_TXDATA* = (1 shl 3) ## /< Transmit tx_data member of spi_transaction_t instead of data at tx_buffer. Do not set tx_buffer when using this.
  SPI_TRANS_MODE_DIOQIO_ADDR* = (1 shl 4) ## /< Also transmit address in mode selected by SPI_MODE_DIO/SPI_MODE_QIO
  SPI_TRANS_VARIABLE_CMD* = (1 shl 5) ## /< Use the ``command_bits`` in ``spi_transaction_ext_t`` rather than default value in ``spi_device_interface_config_t``.
  SPI_TRANS_VARIABLE_ADDR* = (1 shl 6) ## /< Use the ``address_bits`` in ``spi_transaction_ext_t`` rather than default value in ``spi_device_interface_config_t``.
  SPI_TRANS_VARIABLE_DUMMY* = (1 shl 7) ## /< Use the ``dummy_bits`` in ``spi_transaction_ext_t`` rather than default value in ``spi_device_interface_config_t``.
  SPI_TRANS_SET_CD* = (1 shl 7)   ## /< Set the CD pin

## *
##  This structure describes one SPI transaction. The descriptor should not be modified until the transaction finishes.
##

type
  INNER_C_UNION_spi_master_142* {.importc: "no_name", header: "spi_master.h", bycopy.} = object {.
      union.}
    tx_buffer* {.importc: "tx_buffer".}: pointer ## /< Pointer to transmit buffer, or NULL for no MOSI phase
    tx_data* {.importc: "tx_data".}: array[4, uint8] ## /< If SPI_TRANS_USE_TXDATA is set, data set here is sent directly from this variable.

  INNER_C_UNION_spi_master_146* {.importc: "no_name", header: "spi_master.h", bycopy.} = object {.
      union.}
    rx_buffer* {.importc: "rx_buffer".}: pointer ## /< Pointer to receive buffer, or NULL for no MISO phase. Written by 4 bytes-unit if DMA is used.
    rx_data* {.importc: "rx_data".}: array[4, uint8] ## /< If SPI_TRANS_USE_RXDATA is set, data is received directly to this variable

  spi_transaction_t* {.importc: "spi_transaction_t", header: "spi_master.h", bycopy.} = object
    flags* {.importc: "flags".}: uint32 ## /< Bitwise OR of SPI_TRANS_* flags
    cmd* {.importc: "cmd".}: uint16 ## *< Command data, of which the length is set in the ``command_bits`` of spi_device_interface_config_t.
                                  ##
                                  ##   <b>NOTE: this field, used to be "command" in ESP-IDF 2.1 and before, is re-written to be used in a new way in ESP-IDF 3.0.</b>
                                  ##
                                  ##   Example: write 0x0123 and command_bits=12 to send command 0x12, 0x3_ (in previous version, you may have to write 0x3_12).
                                  ##
    `addr`* {.importc: "addr".}: uint64 ## *< Address data, of which the length is set in the ``address_bits`` of spi_device_interface_config_t.
                                      ##
                                      ##   <b>NOTE: this field, used to be "address" in ESP-IDF 2.1 and before, is re-written to be used in a new way in ESP-IDF3.0.</b>
                                      ##
                                      ##   Example: write 0x123400 and address_bits=24 to send address of 0x12, 0x34, 0x00 (in previous version, you may have to write 0x12340000).
                                      ##
    length* {.importc: "length".}: csize_t ## /< Total data length, in bits
    rxlength* {.importc: "rxlength".}: csize_t ## /< Total data length received, should be not greater than ``length`` in full-duplex mode (0 defaults this to the value of ``length``).
    user* {.importc: "user".}: pointer ## /< User-defined variable. Can be used to store eg transaction ID.
    ano_spi_master_144* {.importc: "ano_spi_master_144".}: INNER_C_UNION_spi_master_142
    ano_spi_master_148* {.importc: "ano_spi_master_148".}: INNER_C_UNION_spi_master_146


## the rx data should start from a 32-bit aligned address to get around dma issue.
## *
##  This struct is for SPI transactions which may change their address and command length.
##  Please do set the flags in base to ``SPI_TRANS_VARIABLE_CMD_ADR`` to use the bit length here.
##

type
  spi_transaction_ext_t* {.importc: "spi_transaction_ext_t",
                          header: "spi_master.h", bycopy.} = object
    base* {.importc: "base".}: spi_transaction_t ## /< Transaction data, so that pointer to spi_transaction_t can be converted into spi_transaction_ext_t
    command_bits* {.importc: "command_bits".}: uint8 ## /< The command length in this transaction, in bits.
    address_bits* {.importc: "address_bits".}: uint8 ## /< The address length in this transaction, in bits.
    dummy_bits* {.importc: "dummy_bits".}: uint8 ## /< The dummy length in this transaction, in bits.

  spi_device_t* {.importc: "spi_device_t", header: "spi_master.h", bycopy.} = object
    id* {.importc: "id".}: cint
    # trans_queue* {.importc: "trans_queue".}: QueueHandle_t
    # ret_queue* {.importc: "ret_queue".}: QueueHandle_t
    # cfg* {.importc: "cfg".}: spi_device_interface_config_t
    # timing_conf* {.importc: "timing_conf".}: spi_hal_timing_conf_t
    # host* {.importc: "host".}: ptr spi_host_t
    # semphr_polling* {.importc: "semphr_polling".}: SemaphoreHandle_t ## semaphore to notify the device it claimed the bus
    # waiting* {.importc: "waiting".}: bool ## the device is waiting for the exclusive control of the bus


  spi_device_handle_t* = ptr spi_device_t

## /< Handle for a device on a SPI bus
## *
##  @brief Allocate a device on a SPI bus
##
##  This initializes the internal structures for a device, plus allocates a CS pin on the indicated SPI master
##  peripheral and routes it to the indicated GPIO. All SPI master devices have three CS pins and can thus control
##  up to three devices.
##
##  @note While in general, speeds up to 80MHz on the dedicated SPI pins and 40MHz on GPIO-matrix-routed pins are
##        supported, full-duplex transfers routed over the GPIO matrix only support speeds up to 26MHz.
##
##  @param host_id SPI peripheral to allocate device on
##  @param dev_config SPI interface protocol config for the device
##  @param handle Pointer to variable to hold the device handle
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_NOT_FOUND     if host doesn't have any free CS slots
##          - ESP_ERR_NO_MEM        if out of memory
##          - ESP_OK                on success
##

proc spi_bus_add_device*(host_id: spi_host_device_t;
                        dev_config: ptr spi_device_interface_config_t;
                        handle: ptr spi_device_handle_t): esp_err_t {.
    importc: "spi_bus_add_device", header: "spi_master.h".}
## *
##  @brief Remove a device from the SPI bus
##
##  @param handle Device handle to free
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_INVALID_STATE if device already is freed
##          - ESP_OK                on success
##

proc spi_bus_remove_device*(handle: spi_device_handle_t): esp_err_t {.
    importc: "spi_bus_remove_device", header: "spi_master.h".}
## *
##  @brief Queue a SPI transaction for interrupt transaction execution. Get the result by ``spi_device_get_trans_result``.
##
##  @note Normally a device cannot start (queue) polling and interrupt
##       transactions simultaneously.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param trans_desc Description of transaction to execute
##  @param ticks_to_wait Ticks to wait until there's room in the queue; use portMAX_DELAY to
##                       never time out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_TIMEOUT       if there was no room in the queue before ticks_to_wait expired
##          - ESP_ERR_NO_MEM        if allocating DMA-capable temporary buffer failed
##          - ESP_ERR_INVALID_STATE if previous transactions are not finished
##          - ESP_OK                on success
##

proc spi_device_queue_trans*(handle: spi_device_handle_t;
                            trans_desc: ptr spi_transaction_t;
                            ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_device_queue_trans", header: "spi_master.h".}
## *
##  @brief Get the result of a SPI transaction queued earlier by ``spi_device_queue_trans``.
##
##  This routine will wait until a transaction to the given device
##  succesfully completed. It will then return the description of the
##  completed transaction so software can inspect the result and e.g. free the memory or
##  re-use the buffers.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param trans_desc Pointer to variable able to contain a pointer to the description of the transaction
##         that is executed. The descriptor should not be modified until the descriptor is returned by
##         spi_device_get_trans_result.
##  @param ticks_to_wait Ticks to wait until there's a returned item; use portMAX_DELAY to never time
##                         out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_TIMEOUT       if there was no completed transaction before ticks_to_wait expired
##          - ESP_OK                on success
##

proc spi_device_get_trans_result*(handle: spi_device_handle_t;
                                 trans_desc: ptr ptr spi_transaction_t;
                                 ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_device_get_trans_result", header: "spi_master.h".}
## *
##  @brief Send a SPI transaction, wait for it to complete, and return the result
##
##  This function is the equivalent of calling spi_device_queue_trans() followed by spi_device_get_trans_result().
##  Do not use this when there is still a transaction separately queued (started) from spi_device_queue_trans() or polling_start/transmit that hasn't been finalized.
##
##  @note This function is not thread safe when multiple tasks access the same SPI device.
##       Normally a device cannot start (queue) polling and interrupt
##       transactions simutanuously.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param trans_desc Description of transaction to execute
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spi_device_transmit*(handle: spi_device_handle_t;
                         trans_desc: ptr spi_transaction_t): esp_err_t {.
    importc: "spi_device_transmit", header: "spi_master.h".}
## *
##  @brief Immediately start a polling transaction.
##
##  @note Normally a device cannot start (queue) polling and interrupt
##       transactions simutanuously. Moreover, a device cannot start a new polling
##       transaction if another polling transaction is not finished.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param trans_desc Description of transaction to execute
##  @param ticks_to_wait Ticks to wait until there's room in the queue;
##               currently only portMAX_DELAY is supported.
##
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_TIMEOUT       if the device cannot get control of the bus before ``ticks_to_wait`` expired
##          - ESP_ERR_NO_MEM        if allocating DMA-capable temporary buffer failed
##          - ESP_ERR_INVALID_STATE if previous transactions are not finished
##          - ESP_OK                on success
##

proc spi_device_polling_start*(handle: spi_device_handle_t;
                              trans_desc: ptr spi_transaction_t;
                              ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_device_polling_start", header: "spi_master.h".}
## *
##  @brief Poll until the polling transaction ends.
##
##  This routine will not return until the transaction to the given device has
##  succesfully completed. The task is not blocked, but actively busy-spins for
##  the transaction to be completed.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param ticks_to_wait Ticks to wait until there's a returned item; use portMAX_DELAY to never time
##                         out.
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_ERR_TIMEOUT       if the transaction cannot finish before ticks_to_wait expired
##          - ESP_OK                on success
##

proc spi_device_polling_end*(handle: spi_device_handle_t; ticks_to_wait: TickType_t): esp_err_t {.
    importc: "spi_device_polling_end", header: "spi_master.h".}
## *
##  @brief Send a polling transaction, wait for it to complete, and return the result
##
##  This function is the equivalent of calling spi_device_polling_start() followed by spi_device_polling_end().
##  Do not use this when there is still a transaction that hasn't been finalized.
##
##  @note This function is not thread safe when multiple tasks access the same SPI device.
##       Normally a device cannot start (queue) polling and interrupt
##       transactions simutanuously.
##
##  @param handle Device handle obtained using spi_host_add_dev
##  @param trans_desc Description of transaction to execute
##  @return
##          - ESP_ERR_INVALID_ARG   if parameter is invalid
##          - ESP_OK                on success
##

proc spi_device_polling_transmit*(handle: spi_device_handle_t;
                                 trans_desc: ptr spi_transaction_t): esp_err_t {.
    importc: "spi_device_polling_transmit", header: "spi_master.h".}
## *
##  @brief Occupy the SPI bus for a device to do continuous transactions.
##
##  Transactions to all other devices will be put off until ``spi_device_release_bus`` is called.
##
##  @note The function will wait until all the existing transactions have been sent.
##
##  @param device The device to occupy the bus.
##  @param wait Time to wait before the the bus is occupied by the device. Currently MUST set to portMAX_DELAY.
##
##  @return
##       - ESP_ERR_INVALID_ARG : ``wait`` is not set to portMAX_DELAY.
##       - ESP_OK : Success.
##

proc spi_device_acquire_bus*(device: spi_device_handle_t; wait: TickType_t): esp_err_t {.
    importc: "spi_device_acquire_bus", header: "spi_master.h".}
## *
##  @brief Release the SPI bus occupied by the device. All other devices can start sending transactions.
##
##  @param dev The device to release the bus.
##

proc spi_device_release_bus*(dev: spi_device_handle_t) {.
    importc: "spi_device_release_bus", header: "spi_master.h".}
## *
##  @brief Calculate the working frequency that is most close to desired frequency.
##
##  @param fapb The frequency of apb clock, should be ``APB_CLK_FREQ``.
##  @param hz Desired working frequency
##  @param duty_cycle Duty cycle of the spi clock
##
##  @return Actual working frequency that most fit.
##

proc spi_get_actual_clock*(fapb: cint; hz: cint; duty_cycle: cint): cint {.
    importc: "spi_get_actual_clock", header: "spi_master.h".}
## *
##  @brief Calculate the timing settings of specified frequency and settings.
##
##  @param gpio_is_used True if using GPIO matrix, or False if iomux pins are used.
##  @param input_delay_ns Input delay from SCLK launch edge to MISO data valid.
##  @param eff_clk Effective clock frequency (in Hz) from spi_cal_clock.
##  @param dummy_o Address of dummy bits used output. Set to NULL if not needed.
##  @param cycles_remain_o Address of cycles remaining (after dummy bits are used) output.
##          - -1 If too many cycles remaining, suggest to compensate half a clock.
##          - 0 If no remaining cycles or dummy bits are not used.
##          - positive value: cycles suggest to compensate.
##
##  @note If **dummy_o* is not zero, it means dummy bits should be applied in half duplex mode, and full duplex mode may not work.
##

proc spi_get_timing*(gpio_is_used: bool; input_delay_ns: cint; eff_clk: cint;
                    dummy_o: ptr cint; cycles_remain_o: ptr cint) {.
    importc: "spi_get_timing", header: "spi_master.h".}
## *
##  @brief Get the frequency limit of current configurations.
##          SPI master working at this limit is OK, while above the limit, full duplex mode and DMA will not work,
##          and dummy bits will be aplied in the half duplex mode.
##
##  @param gpio_is_used True if using GPIO matrix, or False if native pins are used.
##  @param input_delay_ns Input delay from SCLK launch edge to MISO data valid.
##  @return Frequency limit of current configurations.
##

proc spi_get_freq_limit*(gpio_is_used: bool; input_delay_ns: cint): cint {.
    importc: "spi_get_freq_limit", header: "spi_master.h".}