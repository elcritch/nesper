
import endians
import sequtils

import consts, general
import esp/driver/spi

# export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t, spi_device_handle_t
export spi

type

  bits* = distinct int

  SpiError* = object of OSError
    code*: esp_err_t

  SpiBus* = object
    host*: spi_host_device_t
    buscfg*: spi_bus_config_t

  SpiDev* = object
    handle*: spi_device_handle_t

  SpiTrans* = ref object
    dev*: SpiDev
    trn*: spi_transaction_t
    tx_data*: seq[uint8]
    rx_data*: seq[uint8]


proc swapDataTx*(data: uint32, len: uint32): uint32 =
  # bigEndian( data shl (32-len) )
  var inp: uint32 = data shl (32-len)
  var outp: uint32 = 0
  addr(outp).bigEndian32(inp.addr())

proc swapDataRx*(data: uint32, len: uint32): uint32 =
  # bigEndian(data) shr (32-len)
  var inp: uint32 = data
  var outp: uint32 = 0
  addr(outp).bigEndian32(inp.addr())

  return outp shr (32-len)

proc newSpiError*(msg: string, error: esp_err_t): ref SpiError =
  new(result)
  result.msg = msg
  result.code = error

proc newSpiBus*(
        host: spi_host_device_t;
        miso, mosi, sclk: int;
        quadwp = -1, quadhd = -1;
        dma_channel: range[0..2],
        flags: set[SpiBusFlag] = {},
        intr_flags: int = 0,
        max_transfer_sz = 4094
      ): SpiBus = 

  result.host = host

  result.buscfg.miso_io_num = miso.cint
  result.buscfg.mosi_io_num = mosi.cint
  result.buscfg.sclk_io_num = sclk.cint
  result.buscfg.quadwp_io_num = quadwp.cint
  result.buscfg.quadhd_io_num = quadhd.cint
  result.buscfg.max_transfer_sz = max_transfer_sz.cint
  result.buscfg.intr_flags = intr_flags.cint

  result.buscfg.flags = 0
  for flg in flags:
    result.buscfg.flags = flg.uint32 or result.buscfg.flags 

    #//Initialize the SPI bus
  let ret = spi_bus_initialize(host, addr(result.buscfg), dma_channel)
  if (ret != ESP_OK):
    raise newSpiError("Error initializing spi (" & $esp_err_to_name(ret) & ")", ret)


# TODO: setup spi device (create spi_device_interface_config_t )
#   - Note: SPI_DEVICE_* is bitwise flags in  spi_device_interface_config_t
# The attributes of a transaction are determined by the bus configuration structure spi_bus_config_t, device configuration structure spi_device_interface_config_t, and transaction configuration structure spi_transaction_t.
# 
# An SPI Host can send full-duplex transactions, during which the read and write phases occur simultaneously. The total transaction length is determined by the sum of the following members:
#     spi_device_interface_config_t::command_bits
#     spi_device_interface_config_t::address_bits
#     spi_transaction_t::length
# While the member spi_transaction_t::rxlength only determines the length of data received into the buffer.
# 
# In half-duplex transactions, the read and write phases are not simultaneous (one direction at a time). The lengths of the write and read phases are determined by length and rxlength members of the struct spi_transaction_t respectively.
# 
# The command and address phases are optional, as not every SPI device requires a command and/or address. This is reflected in the Device’s configuration: if command_bits and/or address_bits are set to zero, no command or address phase will occur.
# 
# The read and write phases can also be optional, as not every transaction requires both writing and reading data. If rx_buffer is NULL and SPI_TRANS_USE_RXDATA is not set, the read phase is skipped. If tx_buffer is NULL and SPI_TRANS_USE_TXDATA is not set, the write phase is skipped.
# 
# The driver supports two types of transactions: the interrupt transactions and polling transactions. The programmer can choose to use a different transaction type per Device. If your Device requires both transaction types, see Notes on Sending Mixed Transactions to the Same Device.


proc addDevice*(
      bus: SpiBus,
      commandlen: bits, ## \
        ## Default amount of bits in command phase (0-16), used when ``SPI_TRANS_VARIABLE_CMD`` is not used, otherwise ignored.
      addresslen: bits, ## \
        ## Default amount of bits in address phase (0-64), used when ``SPI_TRANS_VARIABLE_ADDR`` is not used, otherwise ignored.
      mode: range[0..3], ## \
        ## SPI mode (0-3)
      cs_io: int, ## \
        ## CS GPIO pin for this device, or -1 if not used
      clock_speed_hz: cint, ## \
        ## Clock speed, divisors of 80MHz, in Hz. See ``SPI_MASTER_FREQ_*``.
      queue_size: int, ## \
        ## Transaction queue size. This sets how many transactions can be 'in the air' \
        ## (queued using spi_device_queue_trans but not yet finished using \
        ## spi_device_get_trans_result) at the same time
      dummy_bits: uint8 = 0, ## \
        ## Amount of dummy bits to insert between address and data phase
      duty_cycle_pos: uint16 = 0, ## \
        ## Duty cycle of positive clock, in 1/256th increments (128 = 50%/50% duty). Setting this to 0 (=not setting it) is equivalent to setting this to 128.
      cs_cycles_pretrans: uint16 = 0, ## \
        ## Amount of SPI bit-cycles the cs should be activated before the transmission (0-16). This only works on half-duplex transactions.
      cs_cycles_posttrans: uint8 = 0, ## \
        ## Amount of SPI bit-cycles the cs should stay active after the transmission (0-16)
      input_delay_ns: cint = 0, ## \
      ## Maximum data valid time of slave. The time required between SCLK and MISO \
      ## valid, including the possible clock delay from slave to master. The driver uses this value to give an extra \
      ## delay before the MISO is ready on the line. Leave at 0 unless you know you need a delay. For better timing \
      ## performance at high frequency (over 8MHz), it's suggest to have the right value.
      flags: set[SpiDeviceFlag], ## \
        ## Flags from SpiDevices. Produces bitwise OR of SPI_DEVICE_* flags
      pre_cb: transaction_cb_t = nil, ## \
      ## Callback to be called before a transmission is started. \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
      post_cb: transaction_cb_t = nil, ## \
      ## Callback to be called after a transmission has completed \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
    ): SpiDev =

  var devcfg: spi_device_interface_config_t 
  devcfg.command_bits = commandlen.uint8 
  devcfg.address_bits = addresslen.uint8
  devcfg.dummy_bits = dummy_bits 
  devcfg.mode = mode.uint8
  devcfg.duty_cycle_pos = duty_cycle_pos
  devcfg.cs_ena_pretrans = cs_cycles_pretrans
  devcfg.cs_ena_posttrans = cs_cycles_posttrans
  devcfg.clock_speed_hz = clock_speed_hz
  devcfg.input_delay_ns = input_delay_ns
  devcfg.spics_io_num = cs_io.cint
  devcfg.queue_size = queue_size.cint
  devcfg.pre_cb = pre_cb
  devcfg.post_cb = post_cb

  devcfg.flags = 0
  for flg in flags:
    devcfg.flags = flg.uint32 or devcfg.flags 

  let ret = spi_bus_add_device(bus.host, unsafeAddr(devcfg), addr(result.handle))

  if (ret != ESP_OK):
    raise newSpiError("Error adding spi device (" & $esp_err_to_name(ret) & ")", ret)

# TODO: setup spi device rx memory
# TODO: setup cmd/addr
# TODO: setup cmd/addr custom sizes
var spi_id: uint32 = 0'u32

proc raw_trans*(dev: SpiDev;
                     cmd: uint16,
                     taddr: uint64,
                     txdata: openArray[uint8],
                     txbits: bits = bits(-1),
                     rxbits: bits = bits(-1),
                     flags: set[SpiTransFlag] = {},
                  ): SpiTrans =
  spi_id.inc()
  var tflags = flags
  assert txbits.int() <= 8*len(txdata)

  result.dev = dev
  result.trn.user = cast[pointer](spi_id) # use to keep track of spi trans id's

  # Set TX Details
  result.trn.length = if txbits.int < 0: 8*txdata.len().csize_t() else: txbits.uint32()
  if result.trn.length. in 1U..4U: tflags.incl({USE_TXDATA})
  if result.trn.length <= 3:
    for i in 0..<4:
      result.trn.tx.data[i] = 0
    for i in 0..high(txdata):
      result.trn.tx.data[i] = txdata[i]
  else:
    # This order is important, copy the seq then take the unsafe addr
    result.tx_data = txdata.toSeq()
    result.trn.tx.buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself
  
  # Set RX Details
  result.trn.rxlength = rxbits.uint()
  if result.trn.rxlength in 1U..4U: tflags.incl({USE_RXDATA})
  if result.trn.rxlength <= 3:
    for i in 0..high(txdata):
      result.trn.rx.data[i] = 0
  else:
    # This order is important, copy the seq then take the unsafe addr
    let rm = if result.trn.rxlength mod 8 > 0: 1 else: 0
    result.rx_data = newSeq[byte](int(result.trn.rxlength div 8) + rm)
    result.trn.rx.buffer = unsafeAddr(result.rx_data[0]) ## The data is the cmd itself

  result.trn.flags = 0
  for flg in tflags:
    result.trn.flags = flg.uint32 or result.trn.flags 


proc tx_trans*(dev: SpiDev;
                  txdata: seq[uint8],
                  len: bits = bits(-1),
                ): SpiTrans =
  raw_trans()

proc rx_trans*(dev: SpiDev;
                  rxdata: seq[uint8],
                  len: bits = bits(-1),
                ): SpiTrans =
  raw_trans()

proc rw_trans*(dev: SpiDev;
                  txdata: seq[uint8],
                  rxdata: seq[uint8],
                  len: bits = bits(-1),
                ): SpiTrans =
  raw_trans()

proc pollingStart*(trn: SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret = spi_device_polling_start(trn.dev.handle, addr(trn.trn), ticks_to_wait)
  if (ret != ESP_OK):
    raise newSpiError("start polling (" & $esp_err_to_name(ret) & ")", ret)

proc pollingEnd*(dev: SpiDev, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret = spi_device_polling_end(dev.handle, ticks_to_wait)
  if (ret != ESP_OK):
    raise newSpiError("end polling (" & $esp_err_to_name(ret) & ")", ret)

proc poll*(trn: SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret: esp_err_t = spi_device_polling_transmit(trn.dev.handle, addr(trn.trn))
  if (ret != ESP_OK):
    raise newSpiError("spi polling (" & $esp_err_to_name(ret) & ")", ret)

proc acquireBus*(trn: SpiDev, wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret: esp_err_t = spi_device_acquire_bus(trn.handle, wait)
  if (ret != ESP_OK):
    raise newSpiError("spi aquire bus (" & $esp_err_to_name(ret) & ")", ret)

proc releaseBus*(dev: SpiDev) {.inline.} = 
  spi_device_release_bus(dev.handle)

template withSpiBus*(dev: SpiDev, blk: untyped) =
  dev.acquireBus()
  blk
  dev.releaseBus()

template withSpiBus*(dev: SpiDev, wait: TickType_t, blk: untyped) =
  dev.acquireBus(wait)
  blk
  dev.releaseBus()

proc queue*(trn: SpiTrans, ticks_to_wait: TickType_t = portMAX_DELAY) {.inline.} = 
  let ret: esp_err_t =
    spi_device_queue_trans(trn.dev.handle, addr(trn.trn), ticks_to_wait)

  if (ret != ESP_OK):
    raise newSpiError("start polling (" & $esp_err_to_name(ret) & ")", ret)

proc retrieve*(dev: SpiDev, ticks_to_wait: TickType_t = portMAX_DELAY): ptr spi_transaction_t {.inline.} = 
  let ret: esp_err_t =
    spi_device_get_trans_result(dev.handle, addr(result), ticks_to_wait)

  if (ret != ESP_OK):
    raise newSpiError("start polling (" & $esp_err_to_name(ret) & ")", ret)

proc transmit*(trn: SpiTrans) {.inline.} = 
  let ret: esp_err_t =
    spi_device_transmit(trn.dev.handle, addr(trn.trn))

  if (ret != ESP_OK):
    raise newSpiError("start polling (" & $esp_err_to_name(ret) & ")", ret)


