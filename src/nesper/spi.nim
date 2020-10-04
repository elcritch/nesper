
import endians
import nesper
import nesper/esp/spi

export spi_host_device_t, spi_device_t, spi_bus_config_t, spi_transaction_t

type
  SpiError* = object of Exception

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

when isMainModule:
  var spi1: spi_device_handle_t
  spi1.spiWrite([1'u8, 2'u8, 3'u8])

  spi1.spiWrite([1'u8, 2'u8, 3'u8, 4'u8, 5'u8])
