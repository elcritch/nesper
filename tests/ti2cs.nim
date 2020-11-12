
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
cmd1.write(0x22)
cmd1.write(@[0x12'u8, 0x13, 0x14])
cmd1.start()
cmd1.write(0x23)
cmd1.read()


    i2c_master_start(cmd)
    i2c_master_write_byte(cmd, chip_addr shl 1 or WRITE_BIT, ACK_CHECK_EN)
    i2c_master_write_byte(cmd, data_addr, ACK_CHECK_EN)
    i2c_master_start(cmd)
    i2c_master_write_byte(cmd, chip_addr shl 1 or READ_BIT, ACK_CHECK_EN)
    if size > 1:
      i2c_master_read(cmd, data, size - 1, ACK_VAL)
    i2c_master_read_byte(cmd, data + size - 1, NACK_VAL)
    i2c_master_stop(cmd)
    var ret: esp_err_t = i2c_master_cmd_begin(i2c_port, cmd, 50 div
        portTICK_RATE_MS)
    i2c_cmd_link_delete(cmd)