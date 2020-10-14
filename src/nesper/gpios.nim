
import esp/driver/gpio

export gpio

proc setupGpios(pins: set[gpio_num_t]) =
  var pin_mux: uint64 
  for pin in pins:
    pin_mux = pin_mux | BITS(pin)

  var io_conf: gpio_config_t
  io_conf.intr_type = GPIO_PIN_INTR_DISABLE
  ## set as output mode
  io_conf.mode = GPIO_MODE_OUTPUT
  io_conf.pin_bit_mask = GPIO_OUTPUT_PIN_SEL
  ## disable pull-down mode
  io_conf.pull_down_en = 0
  ## disable pull-up mode
  io_conf.pull_up_en = 0
  ## configure GPIO with the given settings
  gpio_config(addr(io_conf))
  gpio_set_level(GPIO_PHY_CLK_EN, 1)
  gpio_set_level(GPIO_ITSY_RST, 0)



