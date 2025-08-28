import ./consts
import ./general
import ./esp/driver/gpio_driver

# Low-level v5 driver bindings
import ./esp/driver_v5/i2c_master
import ./esp/hal/i2c_types

export i2c_master
export consts.bits, consts.bytes, consts.TickType_t, consts.Millis
export general.toBits
export gpio_driver.gpio_num_t

const TAG = "i2cs_v5"

type
  I2cError* = object of OSError
    code*: esp_err_t

  I2cMasterBus* = ref object
    handle*: i2c_master_bus_handle_t
    conf*: i2c_master_bus_config_t

  I2cDevice* = ref object
    bus*: I2cMasterBus
    handle*: i2c_master_dev_handle_t
    conf*: i2c_device_config_t

converter toBusHandle*(b: I2cMasterBus): i2c_master_bus_handle_t = b.handle
converter toDevHandle*(d: I2cDevice): i2c_master_dev_handle_t = d.handle

proc `=destroy`(d: var typeof(I2cDevice()[])) =
  if d.handle != nil:
    discard i2c_master_bus_rm_device(d.handle)
    d.handle = nil

proc `=destroy`(b: var typeof(I2cMasterBus()[])) =
  if b.handle != nil:
    discard i2c_del_master_bus(b.handle)
    b.handle = nil

# Bus / Device creation
proc newI2cMasterBus*(
    i2cPort: i2c_port_num_t,
    sda, scl: gpio_num_t,
    enableInternalPullup: bool = false,
    glitchIgnoreCnt: uint8 = 7'u8,
    intrPriority: cint = 0,
    transQueueDepth: csize_t = 0
  ): I2cMasterBus =

  result = I2cMasterBus()
  result.conf.i2c_port = i2cPort
  result.conf.sda_io_num = sda
  result.conf.scl_io_num = scl
  result.conf.glitch_ignore_cnt = glitchIgnoreCnt
  result.conf.intr_priority = intrPriority
  result.conf.trans_queue_depth = transQueueDepth
  result.conf.flags.enable_internal_pullup = (if enableInternalPullup: 1'u32 else: 0'u32)

  var h: i2c_master_bus_handle_t
  let ret = i2c_new_master_bus(addr result.conf, addr h)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_new_master_bus failed (" & $esp_err_to_name(ret) & ")", ret)
  result.handle = h

proc addDevice*(
    bus: I2cMasterBus,
    deviceAddress: uint16,
    sclSpeedHz: uint32,
    addrLen: i2c_addr_bit_len_t = I2C_ADDR_BIT_LEN_7,
    sclWaitUs: uint32 = 0,
    disableAckCheck: bool = false
  ): I2cDevice =

  result = I2cDevice()
  result.bus = bus
  result.conf.dev_addr_length = addrLen
  result.conf.device_address = deviceAddress
  result.conf.scl_speed_hz = sclSpeedHz
  result.conf.scl_wait_us = sclWaitUs
  result.conf.flags.disable_ack_check = (if disableAckCheck: 1'u32 else: 0'u32)

  var h: i2c_master_dev_handle_t
  let ret = i2c_master_bus_add_device(bus.handle, addr result.conf, addr h)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_master_bus_add_device failed (" & $esp_err_to_name(ret) & ")", ret)
  result.handle = h

# Basic transactions
proc transmit*(dev: I2cDevice; data: openArray[uint8]; timeoutMs: int = -1): esp_err_t {.discardable.} =
  let ptrData = if data.len > 0: unsafeAddr data[0] else: nil
  let ret = i2c_master_transmit(dev.handle, cast[ptr uint8](ptrData), data.len.csize_t, timeoutMs.cint)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_master_transmit failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc receive*(dev: I2cDevice; size: int; timeoutMs: int = -1): seq[uint8] =
  result = newSeq[uint8](size)
  if size == 0: return
  let ret = i2c_master_receive(dev.handle, addr result[0], size.csize_t, timeoutMs.cint)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_master_receive failed (" & $esp_err_to_name(ret) & ")", ret)

proc receiveInto*(dev: I2cDevice; buf: var openArray[uint8]; timeoutMs: int = -1): esp_err_t {.discardable.} =
  let ptrBuf = if buf.len > 0: addr buf[0] else: nil
  let ret = i2c_master_receive(dev.handle, cast[ptr uint8](ptrBuf), buf.len.csize_t, timeoutMs.cint)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_master_receive failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc transmitReceive*(
    dev: I2cDevice,
    writeBuf: openArray[uint8],
    readBuf: var openArray[uint8],
    timeoutMs: int = -1
  ): esp_err_t {.discardable.} =
  let wptr = if writeBuf.len > 0: unsafeAddr writeBuf[0] else: nil
  let rptr = if readBuf.len > 0: addr readBuf[0] else: nil
  let ret = i2c_master_transmit_receive(dev.handle,
                                        cast[ptr uint8](wptr), writeBuf.len.csize_t,
                                        cast[ptr uint8](rptr), readBuf.len.csize_t,
                                        timeoutMs.cint)
  if ret != ESP_OK:
    raise newEspError[I2cError]("i2c_master_transmit_receive failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

# Convenience register helpers
proc readReg*(dev: I2cDevice; reg: uint8; len: int; timeoutMs: int = 1000): seq[uint8] =
  var r = newSeq[uint8](len)
  var w: array[1, uint8]
  w[0] = reg
  discard dev.transmitReceive(w, r, timeoutMs)
  r

proc writeReg*(dev: I2cDevice; reg: uint8; data: openArray[uint8]; timeoutMs: int = 1000): esp_err_t {.discardable.} =
  var tmp = newSeq[uint8](1 + data.len)
  tmp[0] = reg
  if data.len > 0:
    copyMem(addr tmp[1], unsafeAddr data[0], data.len)
  dev.transmit(tmp, timeoutMs)

# Probe helper on the bus
proc probe*(bus: I2cMasterBus; address: uint16; timeoutMs: int = 100): bool =
  let ret = i2c_master_probe(bus.handle, address, timeoutMs.cint)
  if ret == ESP_OK: true
  elif ret == ESP_ERR_NOT_FOUND: false
  else:
    raise newEspError[I2cError]("i2c_master_probe failed (" & $esp_err_to_name(ret) & ")", ret)


when ESP_IDF_VERSION < ESP_IDF_VERSION_VAL(5, 0, 0):
  import legacy/i2cs as i2cs_legacy
  export i2cs_legacy
else:

  import esp/driver_v5/i2c_master
