import locks, strutils

import nesper
import nesper/gpios
import nesper/i2cs
import nesper/tasks

import i2cdev

export i2cdev
export gpios
export i2cs

const
  TAG = "I2CD"

type
  I2CErrorType* = tuple[val: uint8, err: esp_err_t]

  I2CDevConfig* = object
    port*: i2c_port_t
    sda*: gpio_num_t
    scl*: gpio_num_t

  I2CDevice* = ref object
    config*: I2CDevConfig
    dev*: i2c_dev_t

  I2CDevError* = object of OSError
    code*: esp_err_t

var i2cStarted: bool 

proc i2cDeviceInit*() =
  if not i2cStarted:
    check: i2cdev_init()


i2cDeviceInit()

proc i2c_read_reg*(dev: ptr i2c_dev_t; reg: uint8, val: var uint8): esp_err_t =
  var buf: array[2, uint8]
  var res: esp_err_t = i2c_dev_read_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.logd("Could not read from register 0x%02x", reg)
    return res

  val = (buf[0] shl 8) or buf[1]
  return ESP_OK

proc i2c_write_reg*(dev: ptr i2c_dev_t; reg: uint8; val: uint8): esp_err_t =
  var buf: array[2, uint8] = [uint8(val shr 8), val.uint8]
  var res: esp_err_t = i2c_dev_write_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.logd("Could not write 0x%04x to register 0x%02x", val, reg)
    return res
  return ESP_OK

proc i2c_read_reg16*(dev: ptr i2c_dev_t; reg: uint8, val: var uint16): esp_err_t =
  var buf: array[2, uint8]
  var res: esp_err_t = i2c_dev_read_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not read from register 0x%02x", reg)
    return res
  val = (buf[0] shl 8) or buf[1]
  return ESP_OK

proc i2c_write_reg16*(dev: ptr i2c_dev_t; reg: uint8; val: uint16): esp_err_t =
  var buf: array[2, uint8] = [uint8(val shr 8), val.uint8]
  var res: esp_err_t = i2c_dev_write_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not write 0x%04x to register 0x%02x", val, reg)
    return res
  return ESP_OK

proc readRegister*[T: uint8 | uint16](dev: I2CDevice; reg: byte): T =
  let devptr = addr dev.dev
  
  discard I2C_DEV_TAKE_MUTEX(devptr)
  when T == uint8:
    let res = i2c_read_reg(addr dev.dev, reg, result)
  elif T == uint16:
    let res = i2c_read_reg(addr dev.dev, reg, result)
  else:
    {.fatal: "incorrect type".}

  discard I2C_DEV_GIVE_MUTEX(devptr)

  if result != ESP_OK:
    # TAG.logd("Could not read from register 0x%02x", reg)
    raise newEspError[I2CDevError]("could not read register: " & reg.toHex() & "ret:" & $esp_err_to_name(res), res)

proc writeRegister*[T: uint8 | uint16](dev: I2CDevice; reg: uint8; value: T) =
  let devptr = addr dev.dev
  
  discard I2C_DEV_TAKE_MUTEX(devptr)
  when T is uint8:
    let res = i2c_write_reg(addr dev.dev, reg, value)
  elif T is uint16:
    let res = i2c_write_reg16(addr dev.dev, reg, value)
  else:
    {.fatal: "incorrect type".}

  discard I2C_DEV_GIVE_MUTEX(devptr)

  if res != ESP_OK:
    # TAG.logd("Could not write to register 0x%02x", reg)
    raise newEspError[I2CDevError]("could not write register: " & reg.toHex() & "ret:" & $esp_err_to_name(res), res)


# proc readRegister16*(dev: I2CDevice; reg: uint8): uint16 =
#   let devptr = addr dev.dev
  
#   discard I2C_DEV_TAKE_MUTEX(devptr)
#   let res = i2c_read_reg16(addr dev.dev, reg, result)

#   discard I2C_DEV_GIVE_MUTEX(devptr)

#   if result != ESP_OK:
#     # TAG.logd("Could not read from register 0x%02x", reg)
#     raise newEspError[I2CDevError]("could not read register: " & reg.toHex() & "ret:" & $esp_err_to_name(res), res)

# proc writeRegister16*(dev: I2CDevice; reg: uint8; value: uint16) =
#   let devptr = addr dev.dev
  
#   discard I2C_DEV_TAKE_MUTEX(devptr)
#   let res = i2c_write_reg16(addr dev.dev, reg, value)

#   discard I2C_DEV_GIVE_MUTEX(devptr)

#   if res != ESP_OK:
#     # TAG.logd("Could not write to register 0x%02x", reg)
#     raise newEspError[I2CDevError]("could not write register: " & reg.toHex() & "ret:" & $esp_err_to_name(res), res)