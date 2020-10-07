
import endians
import sets

import consts, general
import nesper
import esp/spi
import sequtils

export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t, spi_device_handle_t

type

  bits* = distinct int

  SpiError* = object of OSError
    code*: esp_err_t

  SpiTrans* = ref object
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

proc initSpiBus*(host: spi_host_device_t;
                miso, mosi, sclk: int;
                quadwp = -1, quadhd = -1;
                dma_channel: range[0..2],
                flags: set[SpiBusFlag] = {},
                intr_flags: int = 0,
                max_transfer_sz = 4094
                ): spi_bus_config_t = 
  var buscfg: spi_bus_config_t 

  buscfg.miso_io_num = miso.cint
  buscfg.mosi_io_num = mosi.cint
  buscfg.sclk_io_num = sclk.cint
  buscfg.quadwp_io_num = quadwp.cint
  buscfg.quadhd_io_num = quadhd.cint
  buscfg.max_transfer_sz = max_transfer_sz.cint
  buscfg.intr_flags = intr_flags.cint

  buscfg.flags = 0
  for flg in flags:
    buscfg.flags = flg.uint32 or buscfg.flags 

    #//Initialize the SPI bus
  let ret = spi_bus_initialize(host, addr(buscfg), dma_channel)
  if (ret != ESP_OK):
    raise newSpiError("Error opening nvs (" & $esp_err_to_name(ret) & ")", ret)

# TODO: setup spi device (create spi_device_interface_config_t )
#   - Note: SPI_DEVICE_* is bitwise flags in  spi_device_interface_config_t

proc newSpiTrans*(
      bus: spi_bus_config_t;
      command_bits: uint8, ## \
        ## Default amount of bits in command phase (0-16), used when ``SPI_TRANS_VARIABLE_CMD`` is not used, otherwise ignored.
      address_bits: uint8, ## \
        ## Default amount of bits in address phase (0-64), used when ``SPI_TRANS_VARIABLE_ADDR`` is not used, otherwise ignored.
      mode: uint8, ## \
        ## SPI mode (0-3)
      cs_io_num: cint, ## \
        ## CS GPIO pin for this device, or -1 if not used
      clock_speed_hz: cint, ## \
        ## Clock speed, divisors of 80MHz, in Hz. See ``SPI_MASTER_FREQ_*``.
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
      flags: set[SpiDevice], ## \
        ## Flags from SpiDevices. Produces bitwise OR of SPI_DEVICE_* flags
      queue_size: int = 1, ## \
        ## Transaction queue size. This sets how many transactions can be 'in the air' \
        ## (queued using spi_device_queue_trans but not yet finished using \
        ## spi_device_get_trans_result) at the same time
      pre_cb: transaction_cb_t = nil, ## \
      ## Callback to be called before a transmission is started. \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
      post_cb: transaction_cb_t = nil, ## \
      ## Callback to be called after a transmission has completed \
      ## This callback is called within interrupt \
      ## context should be in IRAM for best performance, see "Transferring Speed" 
    ): spi_device_interface_config_t =

  var spidev: spi_device_interface_config_t 
  spidev.command_bits = command_bits 
  spidev.address_bits = address_bits 
  spidev.dummy_bits = dummy_bits 
  spidev.mode = mode
  spidev.duty_cycle_pos = duty_cycle_pos
  spidev.cs_ena_pretrans = cs_cycles_pretrans
  spidev.cs_ena_posttrans = cs_cycles_posttrans
  spidev.clock_speed_hz = clock_speed_hz
  spidev.input_delay_ns = input_delay_ns
  spidev.spics_io_num = cs_io_num
  spidev.queue_size = queue_size.cint
  spidev.pre_cb = pre_cb
  spidev.post_cb = post_cb

  spidev.flags = 0
  for flg in flags:
    spidev.flags = flg.uint32 or spidev.flags 

# TODO: setup spi device rx memory
# TODO: setup cmd/addr
# TODO: setup cmd/addr custom sizes

proc newSpiTrans*(spi: spi_device_handle_t;
                     data: openArray[uint8],
                     rxlen: bits = bits(9),
                     len: bits = bits(-1),
                     ): SpiTrans =

  if len.int < 0:
    result.trn.length = 8*data.len().csize_t() ## Command is 8 bits
  else:
    # Manually set bit length for non-byte length sizes
    result.trn.length = len.uint

  result.trn.rxlength = rxlen.uint

  # For data less than 4 bytes, use data directly 
  if data.len() <= 3:
    for i in 0..high(data):
      result.trn.tx.data[i] = data[i]
  else:
    # This order is important, copy the seq then take the unsafe addr
    result.tx_data = data.toSeq()
    result.trn.tx.buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself

proc newSpiTrans*(spi: spi_device_handle_t;
                  data: seq[uint8],
                  rxlen: bits = bits(0),
                  len: bits = bits(-1),
                  ): SpiTrans =
  if len.int < 0:
    result.trn.length = 8*data.len().csize_t() ## Command is 8 bits
  else:
    # Manually set bit length for non-byte length sizes
    result.trn.length = len.uint

  result.trn.rxlength = rxlen.uint

  if data.len() <= 3:
    for i in 0..high(data):
      result.trn.tx.data[i] = data[i]
  else:
    # This order is important, copy the seq then take the unsafe addr
    result.tx_data = data
    result.trn.tx.buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself

# proc spiWrite*(spi: spi_device_handle_t, data: seq[uint8]) =
#   var ret: esp_err_t
#   var trn: spi_transaction_t
#   trn.length = data.len().csize_t()
#   trn.tx.buffer = unsafeAddr(data[0]) ## The data is the cmd itself
#   ret = spi_device_polling_transmit(spi, addr(trn)) ## Transmit!

#   if ret != ESP_OK:
#     raise newException(SpiError, "SPI Error (" & $esp_err_to_name(ret) & ") ")

# proc getTransactionResults() = 
#   var rtrans: spi_transaction_t
#   var ret: esp_err_t
  # # //Wait for all 6 transactions to be done and get back the results.
  # for (int x=0; x<6; x++) {
  #   ret=spi_device_get_trans_result(spi, &rtrans, portMAX_DELAY);
  #   assert(ret==ESP_OK);
  #   //We could inspect rtrans now if we received any info back. The LCD is treated as write-only, though.
  # }
