import locks

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

proc i2c_read_reg*(dev: ptr i2c_dev_t; reg: uint8): uint8 =
  var buf: array[2, uint8]
  var res: esp_err_t = i2c_dev_read_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not read from register 0x%02x", reg)
    raise newEspError[I2CDevError]("register: " & $esp_err_to_name(res), res)

  result = (buf[0] shl 8) or buf[1]

proc i2c_write_reg*(dev: ptr i2c_dev_t; reg: uint8; val: uint8) =
  var buf: array[2, uint8] = [uint8(val shr 8), val.uint8]
  var res: esp_err_t = i2c_dev_write_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not write 0x%04x to register 0x%02x", val, reg)
    raise newEspError[I2CDevError]("register: " & $esp_err_to_name(res), res)

proc i2c_read_reg16*(dev: ptr i2c_dev_t; reg: uint8): uint16 =
  var buf: array[2, uint8]
  var res: esp_err_t = i2c_dev_read_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not read from register 0x%02x", reg)
    raise newEspError[I2CDevError]("register: " & $esp_err_to_name(res), res)

  result = (buf[0] shl 8) or buf[1]

proc i2c_write_reg16*(dev: ptr i2c_dev_t; reg: uint8; val: uint16) =
  var buf: array[2, uint8] = [uint8(val shr 8), val.uint8]
  var res: esp_err_t = i2c_dev_write_reg(dev, reg, addr buf[0], 2)
  if res != ESP_OK:
    TAG.loge("Could not write 0x%04x to register 0x%02x", val, reg)
    raise newEspError[I2CDevError]("register: " & $esp_err_to_name(res), res)

proc readRegister*(dev: I2CDevice; reg: uint8): uint8 =
  
  I2C_DEV_TAKE_MUTEX(dev)
  result = i2c_read_reg(addr dev.dev, reg)
  I2C_DEV_GIVE_MUTEX(dev)


proc writeRegister*(dev: I2CDevice; reg: uint8; val: uint8) =
  i2c_write_reg(addr dev.dev, reg, val)

proc readRegister16*(dev: I2CDevice; reg: uint8): uint16 =
  return i2c_read_reg16(addr dev.dev, reg)

proc writeRegister16*(dev: I2CDevice; reg: uint8; val: uint16) =
  i2c_write_reg16(addr dev.dev, reg, val)

