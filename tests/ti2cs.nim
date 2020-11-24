
import nesper
import nesper/i2cs

export i2cs


var
  port1 = newI2CMaster(port = I2C_NUM_0,
                          sda_io_num = gpio_num_t(0), ## !< GPIO number for I2C sda signal
                          scl_io_num = gpio_num_t(1), ## !< GPIO number for I2C scl signal
                          clk_speed = 100_000.Hertz,
                          sda_pullup_en = false, ## !< Internal GPIO pull mode for I2C sda signal
                          scl_pullup_en = false, ## !< Internal GPIO pull mode for I2C scl signal
                          intr_alloc_flags = {})

var
  cmd1 = port1.newCmd()

cmd1.start()
cmd1.writeByte(0x22)
cmd1.write([0x12'u8, 0x13, 0x14])
cmd1.start()
cmd1.writeByte(0x23)

# var
#   b1 = cmd1.readByte(ACK)
#   b2 = cmd1.readByte(NACK)
#   b3 = cmd1.readByte(LAST_NACK)
#   b4 = cmd1.read(3, LAST_NACK)
# cmd1.stop()
# port1.submit(cmd1, 10.Millis)
# echo("bytes: ", b1, b2, b3, b4)

