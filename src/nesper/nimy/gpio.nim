import ../gpios
import errors

type Pin* = object
  gpio*: GPIO_PIN
  ##More erganomic wrapper around esp gpio pin functions

proc newPin*(num:static uint8):static Pin=
  ##Create a pin that maps to `num` gpio pin on the
  return Pin(gpio:gpio_num_t(num))

proc high*(pin: Pin) = setLevel(pin.gpio, 1)
  ##Set pin output to 1/on 

proc low*(pin: Pin) = setLevel(pin.gpio, 0)
  ##Set pin output to 0/off 

proc input*(pin: Pin)= discard pin.gpio.gpio_set_direction GPIO_MODE_INPUT
  ##Sets the pin to input mode 


proc output*(pin: Pin,openDrain=false): EspError = 
  ##Sets the pin to output mode 
  let mode = if openDrain: GPIO_MODE_INPUT_OUTPUT_OD else: GPIO_MODE_INPUT_OUTPUT
  discard pin.gpio.gpio_set_direction mode

proc inputOutput*(pin: Pin, openDrain = false) =
  ##Sets the pin to be both input and output mode
  let mode = if openDrain: GPIO_MODE_INPUT_OUTPUT_OD else: GPIO_MODE_INPUT_OUTPUT
  discard pin.gpio.gpio_set_direction(mode)

proc pullUp*(pin:Pin) = discard pin.gpio.gpio_set_pull_mode(PULLUP_ONLY)
  ## Enables the internal pullup resistor for the pin

proc pullDown*(pin:Pin) = discard pin.gpio.gpio_set_pull_mode(PULLDOWN_ONLY)
  ## Enables the internal pulldown resistor for the pin

proc pullUpDown*(pin:Pin) = discard pin.gpio.gpio_set_pull_mode(PULLUP_PULLDOWN)
  ##Configure GPIO pull-up/pull-down resistors

proc pullFloat*(pin:Pin) = discard pin.gpio.gpio_set_pull_mode(GPIO_FLOATING)
  ##Disable the internal pullup and pulldown resistors

proc read*(pin:Pin):cint=return pin.gpio.gpio_get_level()
  ##Read the value of the pin
proc isHigh*(pin:Pin):bool=return pin.read()==1
  ##Read the value of the pin and check if it is equal to 1
  ##Same as `pin.read()==1`
proc isLow*(pin:Pin):bool=return pin.read()==0
  ##Read the value of the pin and check if it is equal to 0
  ##Same as `pin.read()==0`
proc resetCfg*(pin:Pin):cint=return pin.gpio.gpio_reset_pin()
  ##Reset configuration of the pin. 
  ##Do this before using a pin if you don't know what it is set to by the system on startup