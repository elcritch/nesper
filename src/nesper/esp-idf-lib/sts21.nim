
import nesper
import nesper/gpios
import nesper/i2cs

import i2cdev
import i2cdev_utils

const TAG = "STS21"

const 
  STS21_ADDR* = 0x43


proc initSts21*(cfg: I2CDevConfig, clock_hz: Hertz): I2CDevice = 

  new(result)
  result.dev.port = cfg.port
  result.dev.devAddr = STS21_ADDR
  result.dev.cfg.sda_io_num = cfg.sda
  result.dev.cfg.scl_io_num = cfg.scl

  result.dev.cfg.master.clk_speed = 100_000

  check: i2c_dev_create_mutex(addr result.dev)
