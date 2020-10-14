
import esp/driver/gpio

export gpio

proc setupPins() =
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
  ## gpio_set_level(GPIO_OUTPUT_IO_5, 0);
  vTaskDelay(100)



