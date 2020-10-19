import nesper/consts
import nesper/general

# import esp/driver/gpio
import esp/gpio

export gpio

type
  GpioError* = object of OSError
    code*: esp_err_t

  GPIO_PIN* = gpio_num_t

proc configure*(pins: set[gpio_num_t],
        mode: gpio_mode_t, ## !< GPIO mode: set input/output mode
        pull_up: bool = false, ## !< GPIO pull-up
        pull_down: bool = false, ## !< GPIO pull-down
        interrupt: gpio_int_type_t = GPIO_INTR_DISABLE, ## !< GPIO interrupt type
      ) =
  var pin_mask: uint64 = 0U
  for pin in pins:
    pin_mask = pin_mask or BIT64(pin.int())

  var io_conf: gpio_config_t
  io_conf.mode = mode
  io_conf.pin_bit_mask = pin_mask
  io_conf.pull_up_en = if pull_up: GPIO_PULLUP_ENABLE else: GPIO_PULLUP_DISABLE
  io_conf.pull_down_en  = if pull_down: GPIO_PULLDOWN_ENABLE else: GPIO_PULLDOWN_DISABLE
  io_conf.intr_type = interrupt
  
  var ret: esp_err_t
  
  ret = gpio_config(addr(io_conf))
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio config:" & $esp_err_to_name(ret), ret )

proc setLevel*(pin: gpio_num_t, value: uint32) =
  var ret: esp_err_t

  ret = gpio_setLevel(pin, value.uint32())
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio set level:" & $esp_err_to_name(ret), ret )

proc setLevel*(pin: gpio_num_t, value: bool) =
  setLevel(pin, uint32(value))
proc setLevel*(pin: gpio_num_t, value: SomeInteger) =
  setLevel(pin, uint32(value))

proc getLevel*(pin: gpio_num_t): bool =
  var ret: cint = gpio_getLevel(pin)

  return
    if ret == 0:
      false
    else:
      true

