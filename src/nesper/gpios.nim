import nesper/consts
import nesper/general

# import esp/driver/gpio
import esp/gpio

export gpio

type
  GpioError* = object of OSError
    code*: esp_err_t

proc config(pins: set[gpio_num_t],
    mode: gpio_mode_t, ## !< GPIO mode: set input/output mode
    pull_up_en: gpio_pullup_t = GPIO_PULLUP_DISABLE, ## !< GPIO pull-up
    pull_down_en: gpio_pulldown_t = GPIO_PULLDOWN_DISABLE, ## !< GPIO pull-down
    intr_type: gpio_int_type_t = GPIO_INTR_DISABLE, ## !< GPIO interrupt type
) =
  var pin_mask: uint64 
  for pin in pins:
    pin_mask = pin_mask or BIT(pin.int())

  var io_conf: gpio_config_t
  io_conf.intr_type = intr_type
  io_conf.mode = mode
  io_conf.pin_bit_mask = pin_mask
  io_conf.pull_down_en = pull_down_en
  io_conf.pull_up_en = pull_up_en
  
  var ret: esp_err_t
  
  ret = gpio_config(addr(io_conf))
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio config:" & $esp_err_to_name(ret), ret )

proc set(pin: gpio_num_t, value: bool) =
  var ret: esp_err_t

  ret = gpio_set_level(pin, value.uint32())
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio set level:" & $esp_err_to_name(ret), ret )


