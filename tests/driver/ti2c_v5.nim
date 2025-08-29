import nesper
import nesper/i2cs

export i2cs

# Compile-only sanity for the v5 I2C wrapper
block:
  let bus = newI2cMasterBus(
    i2cPort = i2c_port_num_t(0),
    sda = gpio_num_t(0),
    scl = gpio_num_t(1),
    enableInternalPullup = true,
    glitchIgnoreCnt = 7'u8
  )

  let dev = bus.addDevice(
    deviceAddress = 0x68'u16,
    sclSpeedHz = 100_000.Hertz,
    addrLen = I2C_ADDR_BIT_LEN_7
  )

  # Basic write
  discard dev.transmit([0x6B'u8, 0x00'u8], timeoutMs = 100)

  # Write-Read transaction (read WHO_AM_I)
  var rx: array[1, uint8]
  discard dev.transmitReceive([0x75'u8], rx, timeoutMs = 100)

  # Convenience helpers
  let _ = dev.readReg(0x75'u8, 1, timeoutMs = 100)
  discard dev.writeReg(0x6B'u8, [0x80'u8], timeoutMs = 100)

  echo repr(dev)