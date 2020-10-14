##  Copyright 2010-2016 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

import ../consts
import driver/gpio_driver

export gpio_driver

## * \defgroup gpio_apis, uart configuration and communication related apis

## TODO: the closes for these appear to be uint32, but may be wrong?!
proc GPIO_REG_READ*(reg: uint32): uint32 {.importc: "$1", header: "gpio.h".}
proc GPIO_REG_WRITE*(reg: uint32, val: uint32) {.importc: "$1", header: "gpio.h".}

var
  GPIO_ID_PIN0* {.importc: "$1", header: "gpio.h".} = 0

template GPIO_ID_PIN*(n: untyped): untyped =
  (GPIO_ID_PIN0 + (n))

template GPIO_PIN_ADDR*(i: untyped): untyped =
  (GPIO_PIN0_REG + i * 4)

const
  GPIO_FUNC_IN_HIGH* = 0x00000038
  GPIO_FUNC_IN_LOW* = 0x00000030

template GPIO_ID_IS_PIN_REGISTER*(reg_id: untyped): untyped =
  ((reg_id >= GPIO_ID_PIN0) and (reg_id <= GPIO_ID_PIN(GPIO_PIN_COUNT - 1)))

template GPIO_REGID_TO_PINIDX*(reg_id: untyped): untyped =
  ((reg_id) - GPIO_ID_PIN0)

## Note: This appears to be duplicated in the esp-idf
# type
  # GPIO_INT_TYPE* {.size: sizeof(cint).} = enum
    # GPIO_PIN_INTR_DISABLE = 0, GPIO_PIN_INTR_POSEDGE = 1, GPIO_PIN_INTR_NEGEDGE = 2,
    # GPIO_PIN_INTR_ANYEDGE = 3, GPIO_PIN_INTR_LOLEVEL = 4, GPIO_PIN_INTR_HILEVEL = 5


template GPIO_OUTPUT_SET*(gpio_no, bit_value: untyped): untyped =
  (if (gpio_no < 32): gpio_output_set(bit_value shl gpio_no,
                                  (if bit_value: 0 else: 1) shl gpio_no,
                                  1 shl gpio_no, 0) else: gpio_output_set_high(
      bit_value shl (gpio_no - 32), (if bit_value: 0 else: 1) shl (gpio_no - 32),
      1 shl (gpio_no - 32), 0))

template GPIO_DIS_OUTPUT*(gpio_no: untyped): untyped =
  (if (gpio_no < 32): gpio_output_set(0, 0, 0, 1 shl gpio_no) else: gpio_output_set_high(
      0, 0, 0, 1 shl (gpio_no - 32)))

template GPIO_INPUT_GET*(gpio_no: untyped): untyped =
  (if (gpio_no < 32): ((gpio_input_get() shr gpio_no) and BIT0) else: (
      (gpio_input_get_high() shr (gpio_no - 32)) and BIT0))

##  GPIO interrupt handler, registered through gpio_intr_handler_register

type
  gpio_intr_handler_fn_t* = proc (intr_mask: uint32; high: bool; arg: pointer)

## *
##  @brief Initialize GPIO. This includes reading the GPIO Configuration DataSet
##         to initialize "output enables" and pin configurations for each gpio pin.
##         Please do not call this function in SDK.
##
##  @param  None
##
##  @return None
##

proc gpio_init*() {.importc: "gpio_init", header: "gpio.h".}
## *
##  @brief Change GPIO(0-31) pin output by setting, clearing, or disabling pins, GPIO0<->BIT(0).
##          There is no particular ordering guaranteed; so if the order of writes is significant,
##          calling code should divide a single call into multiple calls.
##
##  @param  uint32 set_mask : the gpios that need high level.
##
##  @param  uint32 clear_mask : the gpios that need low level.
##
##  @param  uint32 enable_mask : the gpios that need be changed.
##
##  @param  uint32 disable_mask : the gpios that need diable output.
##
##  @return None
##

proc gpio_output_set*(set_mask: uint32; clear_mask: uint32;
                     enable_mask: uint32; disable_mask: uint32) {.
    importc: "gpio_output_set", header: "gpio.h".}
## *
##  @brief Change GPIO(32-39) pin output by setting, clearing, or disabling pins, GPIO32<->BIT(0).
##          There is no particular ordering guaranteed; so if the order of writes is significant,
##          calling code should divide a single call into multiple calls.
##
##  @param  uint32 set_mask : the gpios that need high level.
##
##  @param  uint32 clear_mask : the gpios that need low level.
##
##  @param  uint32 enable_mask : the gpios that need be changed.
##
##  @param  uint32 disable_mask : the gpios that need diable output.
##
##  @return None
##

proc gpio_output_set_high*(set_mask: uint32; clear_mask: uint32;
                          enable_mask: uint32; disable_mask: uint32) {.
    importc: "gpio_output_set_high", header: "gpio.h".}
## *
##  @brief Sample the value of GPIO input pins(0-31) and returns a bitmask.
##
##  @param None
##
##  @return uint32 : bitmask for GPIO input pins, BIT(0) for GPIO0.
##

proc gpio_input_get*(): uint32 {.importc: "gpio_input_get", header: "gpio.h".}
## *
##  @brief Sample the value of GPIO input pins(32-39) and returns a bitmask.
##
##  @param None
##
##  @return uint32 : bitmask for GPIO input pins, BIT(0) for GPIO32.
##

proc gpio_input_get_high*(): uint32 {.importc: "gpio_input_get_high",
                                     header: "gpio.h".}
## *
##  @brief Register an application-specific interrupt handler for GPIO pin interrupts.
##         Once the interrupt handler is called, it will not be called again until after a call to gpio_intr_ack.
##         Please do not call this function in SDK.
##
##  @param gpio_intr_handler_fn_t fn : gpio application-specific interrupt handler
##
##  @param void *arg : gpio application-specific interrupt handler argument.
##
##  @return None
##

proc gpio_intr_handler_register*(fn: gpio_intr_handler_fn_t; arg: pointer) {.
    importc: "gpio_intr_handler_register", header: "gpio.h".}
## *
##  @brief Get gpio interrupts which happens but not processed.
##         Please do not call this function in SDK.
##
##  @param None
##
##  @return uint32 : bitmask for GPIO pending interrupts, BIT(0) for GPIO0.
##

proc gpio_intr_pending*(): uint32 {.importc: "gpio_intr_pending", header: "gpio.h".}
## *
##  @brief Get gpio interrupts which happens but not processed.
##         Please do not call this function in SDK.
##
##  @param None
##
##  @return uint32 : bitmask for GPIO pending interrupts, BIT(0) for GPIO32.
##

proc gpio_intr_pending_high*(): uint32 {.importc: "gpio_intr_pending_high",
                                        header: "gpio.h".}
## *
##  @brief Ack gpio interrupts to process pending interrupts.
##         Please do not call this function in SDK.
##
##  @param uint32 ack_mask: bitmask for GPIO ack interrupts, BIT(0) for GPIO0.
##
##  @return None
##

proc gpio_intr_ack*(ack_mask: uint32) {.importc: "gpio_intr_ack", header: "gpio.h".}
## *
##  @brief Ack gpio interrupts to process pending interrupts.
##         Please do not call this function in SDK.
##
##  @param uint32 ack_mask: bitmask for GPIO ack interrupts, BIT(0) for GPIO32.
##
##  @return None
##

proc gpio_intr_ack_high*(ack_mask: uint32) {.importc: "gpio_intr_ack_high",
    header: "gpio.h".}
## *
##  @brief Set GPIO to wakeup the ESP32.
##         Please do not call this function in SDK.
##
##  @param uint32 i: gpio number.
##
##  @param GPIO_INT_TYPE intr_state : only GPIO_PIN_INTR_LOLEVEL\GPIO_PIN_INTR_HILEVEL can be used
##
##  @return None
##

proc gpio_pin_wakeup_enable*(i: uint32; intr_state: gpio_int_type_t) {.
    importc: "gpio_pin_wakeup_enable", header: "gpio.h".}
## *
##  @brief disable GPIOs to wakeup the ESP32.
##         Please do not call this function in SDK.
##
##  @param None
##
##  @return None
##

proc gpio_pin_wakeup_disable*() {.importc: "gpio_pin_wakeup_disable",
                                header: "gpio.h".}
## *
##  @brief set gpio input to a signal, one gpio can input to several signals.
##
##  @param uint32 gpio : gpio number, 0~0x27
##                         gpio == 0x30, input 0 to signal
##                         gpio == 0x34, ???
##                         gpio == 0x38, input 1 to signal
##
##  @param uint32 signal_idx : signal index.
##
##  @param bool inv : the signal is inv or not
##
##  @return None
##

proc gpio_matrix_in*(gpio: uint32; signal_idx: uint32; inv: bool) {.
    importc: "gpio_matrix_in", header: "gpio.h".}
## *
##  @brief set signal output to gpio, one signal can output to several gpios.
##
##  @param uint32 gpio : gpio number, 0~0x27
##
##  @param uint32 signal_idx : signal index.
##                         signal_idx == 0x100, cancel output put to the gpio
##
##  @param bool out_inv : the signal output is inv or not
##
##  @param bool oen_inv : the signal output enable is inv or not
##
##  @return None
##

proc gpio_matrix_out*(gpio: uint32; signal_idx: uint32; out_inv: bool;
                     oen_inv: bool) {.importc: "gpio_matrix_out", header: "gpio.h".}
## *
##  @brief Select pad as a gpio function from IOMUX.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @return None
##

proc gpio_pad_select_gpio*(gpio_num: uint8) {.importc: "gpio_pad_select_gpio",
    header: "gpio.h".}
## *
##  @brief Set pad driver capability.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @param uint8 drv : 0-3
##
##  @return None
##

proc gpio_pad_set_drv*(gpio_num: uint8; drv: uint8) {.
    importc: "gpio_pad_set_drv", header: "gpio.h".}
## *
##  @brief Pull up the pad from gpio number.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @return None
##

proc gpio_pad_pullup*(gpio_num: uint8) {.importc: "gpio_pad_pullup",
                                        header: "gpio.h".}
## *
##  @brief Pull down the pad from gpio number.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @return None
##

proc gpio_pad_pulldown*(gpio_num: uint8) {.importc: "gpio_pad_pulldown",
    header: "gpio.h".}
## *
##  @brief Unhold the pad from gpio number.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @return None
##

proc gpio_pad_unhold*(gpio_num: uint8) {.importc: "gpio_pad_unhold",
                                        header: "gpio.h".}
## *
##  @brief Hold the pad from gpio number.
##
##  @param uint32 gpio_num : gpio number, 0~0x27
##
##  @return None
##

proc gpio_pad_hold*(gpio_num: uint8) {.importc: "gpio_pad_hold", header: "gpio.h".}
## *
##  @}
##
