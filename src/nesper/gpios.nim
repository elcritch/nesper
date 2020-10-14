import nesper/consts
import nesper/general

# import esp/driver/gpio
import esp/driver/gpio_consts
import esp/gpio

export gpio
export gpio_consts

type
  GpioError* = object of OSError
    code*: esp_err_t

proc setupGpios(pins: set[gpio_num_t]) =
  var pin_mask: uint64 
  for pin in pins:
    pin_mask = pin_mask or BIT(pin.int())

  var io_conf: gpio_config_t
  io_conf.intr_type = GPIO_INTR_DISABLE
  ## set as output mode
  io_conf.mode = GPIO_MODE_OUTPUT
  io_conf.pin_bit_mask = pin_mask
  ## disable pull-down mode
  io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE
  ## disable pull-up mode
  io_conf.pull_up_en = GPIO_PULLUP_DISABLE
  ## configure GPIO with the given settings
  let ret: esp_err_t
  
  ret = gpio_config(addr(io_conf))
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio config:" $esp_err_to_name(nvs_error) )

  ret = gpio_set_level(GPIO_PHY_CLK_EN, 1)
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio set level:" $esp_err_to_name(nvs_error) )

  ret = gpio_set_level(GPIO_ITSY_RST, 0)
  if ret != ESP_OK:
    raise newEspError[GpioError]("gpio set level:" $esp_err_to_name(nvs_error) )



