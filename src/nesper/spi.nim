
import endians
import sets

import consts, general
import nesper
import esp/spi
import sequtils

export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t, spi_device_handle_t

type

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

proc newSpiBus*(host: spi_host_device_t;
                miso, mosi, sclk: int;
                quadwp = -1, quadhd = -1;
                max_transfer_sz = 4094;
                flags: set[SpiBusFlag] = {},
                intr_flags: HashSet[cint] = initHashSet[cint](),
                dma_channel = range[0..2]
                ): spi_bus_config_t = 
  var buscfg: spi_bus_config_t 

  buscfg.miso_io_num = miso
  buscfg.mosi_io_num = mosi
  buscfg.sclk_io_num = sclk
  buscfg.quadwp_io_num = quadwp
  buscfg.quadhd_io_num = quadhd
  buscfg.max_transfer_sz = max_transfer_sz

  buscfg.flags = 0
  for flg in flags:
    buscfg.flags = flg or buscfg.flags 

  buscfg.intr_flags = 0
  for flg in intr_flags:
    buscfg.intr_flags = flg or buscfg.intr_flags 

    #//Initialize the SPI bus
  let ret = spi_bus_initialize(host, addr(buscfg), dma_channel)
  if (ret != ESP_OK):
    raise newSpiError("Error opening nvs (" & $esp_err_to_name(ret) & ")", ret)

proc newSpiTrans*[N](spi: spi_device_handle_t;
                        data: array[N, uint8],
                        ): SpiTrans =

  result.trn.length = data.len().csize_t() ## Command is 8 bits

  # For data less than 4 bytes, use data directly 
  when data.len() <= 3:
    for i in 0..high(data):
      result.trn.tx.data[i] = data[i]
  else:
    # This order is important, copy the seq then take the unsafe addr
    result.tx_data = data.toSeq()
    result.trn.tx.buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself

proc newSpiTrans*(spi: spi_device_handle_t, data: seq[uint8]): SpiTrans =
  result.trn.length = data.len().csize_t()
  # This order is important, copy the seq then take the unsafe addr
  result.tx_data = data
  result.trn.tx.buffer = unsafeAddr(result.tx_data[0]) ## The data is the cmd itself


proc spiWrite*[N](spi: spi_device_handle_t, data: array[N, uint8]) =
  var ret: esp_err_t
  var trn: spi_transaction_t

  trn.length = data.len().csize_t() ## Command is 8 bits

  when data.len() <= 3:
    for i in 0..data.len():
      trn.tx.data[i] = data[i]
    ret = spi_device_polling_transmit(spi, addr(trn)) ## Transmit!
    if ret != ESP_OK:
      raise newException(SpiError, "SPI Error (" & $esp_err_to_name(ret) & ") ")
  else:
    trn.tx.buffer = unsafeAddr(data[0]) ## The data is the cmd itself
    ret = spi_device_polling_transmit(spi, addr(trn)) ## Transmit!
    if ret != ESP_OK:
      raise newException(SpiError, "SPI Error (" & $esp_err_to_name(ret) & ") ")

proc spiWrite*(spi: spi_device_handle_t, data: seq[uint8]) =
  var ret: esp_err_t
  var trn: spi_transaction_t
  trn.length = data.len().csize_t()
  trn.tx.buffer = unsafeAddr(data[0]) ## The data is the cmd itself
  ret = spi_device_polling_transmit(spi, addr(trn)) ## Transmit!

  if ret != ESP_OK:
    raise newException(SpiError, "SPI Error (" & $esp_err_to_name(ret) & ") ")

# proc getTransactionResults() = 
#   var rtrans: spi_transaction_t
#   var ret: esp_err_t
  # # //Wait for all 6 transactions to be done and get back the results.
  # for (int x=0; x<6; x++) {
  #   ret=spi_device_get_trans_result(spi, &rtrans, portMAX_DELAY);
  #   assert(ret==ESP_OK);
  #   //We could inspect rtrans now if we received any info back. The LCD is treated as write-only, though.
  # }

when isMainModule:
  var spi1: spi_device_handle_t
  spi1.spiWrite([1'u8, 2'u8, 3'u8])

  spi1.spiWrite([1'u8, 2'u8, 3'u8, 4'u8, 5'u8])
