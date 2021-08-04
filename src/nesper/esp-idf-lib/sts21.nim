
import nesper
import nesper/gpios
import nesper/i2cs
import nesper/timers

import i2cdev
import i2cdev_utils

const TAG = "STS21"

const 
  STS21_ADDR* = 0x4A

type
  ConfigSTS21* = ref object
    device: I2CDevice

proc initSts21*(cfg: I2CDevConfig, clock_hz = Hertz(100_000)): ConfigSTS21 = 

  new(result)
  new(result.device)
  result.device.dev.port = cfg.port
  result.device.dev.devAddr = STS21_ADDR
  result.device.dev.cfg.sda_io_num = cfg.sda
  result.device.dev.cfg.scl_io_num = cfg.scl

  result.device.dev.cfg.master.clk_speed = clock_hz.uint32

  check: i2c_dev_create_mutex(addr result.device.dev)

proc takeReading*(cfg: var ConfigSTS21): float =
  let
    devptr = addr cfg.device.dev

  # check: i2c_dev_take_mutex(devptr)

  var rst_data = @[0xFE'u8]
  check: i2c_dev_write(devptr, nil, 0, addr rst_data[0], 1)

  delayMillis(20)

  var in_data = @[0xF3'u8]
  check: i2c_dev_write(devptr, nil, 0, addr in_data[0], 1)
  # check: i2c_dev_give_mutex(devptr)

  delayMillis(300)

  var data = newSeq[byte](2)
  check: i2c_dev_read(devptr, nil, 0, addr data[0], 2)

  # "TEMP".logi("read: %s", $data)
  # // Convert the data
  let
    rawtmp = data[0] * 256 + data[1]
    value = float(rawtmp and 0xFFFC)
    cTemp = -46.85 + (175.72 * (value / 65536.0))

  return cTemp


when isMainModule:
  proc setup_sts21() =

    var 
      port1 = I2CDevConfig(
        port: I2C_NUM_1,
        sda: GpioPin(23),
        scl: GpioPin(22),
      )
      sts21 = initSts21(port1)

    while true:
      try:
        delayMillis(1_000)
        "TEMP".logi("setup: ", )
        discard sts21.takeReading()
        "TEMP".logi("restart: ", )
      except:
        echo getCurrentExceptionMsg() #invalid integer: 133a
        delayMillis(1000)

  setup_sts21() 
