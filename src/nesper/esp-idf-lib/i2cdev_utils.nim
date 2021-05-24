
import nesper/gpios
import nesper/i2cs

import i2cdev

export i2cdev
export gpios
export i2cs

type
  I2CDevConfig* = object
    port*: i2c_port_t
    sda*: gpio_num_t
    scl*: gpio_num_t

