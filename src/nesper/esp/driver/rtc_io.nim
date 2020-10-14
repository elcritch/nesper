##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
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

import
  esp_err, driver/gpio, soc/rtc_periph

type
  rtc_gpio_mode_t* {.size: sizeof(cint).} = enum
    RTC_GPIO_MODE_INPUT_ONLY, ## !< Pad input
    RTC_GPIO_MODE_OUTPUT_ONLY, ## !< Pad output
    RTC_GPIO_MODE_INPUT_OUTPUT, ## !< Pad pull input + output
    RTC_GPIO_MODE_DISABLED    ## !< Pad (output + input) disable


## *
##  @brief Determine if the specified GPIO is a valid RTC GPIO.
##
##  @param gpio_num GPIO number
##  @return true if GPIO is valid for RTC GPIO use. false otherwise.
##

proc rtc_gpio_is_valid_gpio*(gpio_num: gpio_num_t): bool {.inline.} =
  return gpio_num < GPIO_PIN_COUNT and rtc_gpio_desc[gpio_num].reg != 0

template RTC_GPIO_IS_VALID_GPIO*(gpio_num: untyped): untyped =
  rtc_gpio_is_valid_gpio(gpio_num) ##  Deprecated, use rtc_gpio_is_valid_gpio()

## *
##  @brief Init a GPIO as RTC GPIO
##
##  This function must be called when initializing a pad for an analog function.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_init*(gpio_num: gpio_num_t): esp_err_t {.importc: "rtc_gpio_init",
    header: "rtc_io.h".}
## *
##  @brief Init a GPIO as digital GPIO
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_deinit*(gpio_num: gpio_num_t): esp_err_t {.importc: "rtc_gpio_deinit",
    header: "rtc_io.h".}
## *
##  @brief Get the RTC IO input level
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - 1 High level
##      - 0 Low level
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_get_level*(gpio_num: gpio_num_t): uint32_t {.
    importc: "rtc_gpio_get_level", header: "rtc_io.h".}
## *
##  @brief Set the RTC IO output level
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##  @param  level output level
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_set_level*(gpio_num: gpio_num_t; level: uint32_t): esp_err_t {.
    importc: "rtc_gpio_set_level", header: "rtc_io.h".}
## *
##  @brief    RTC GPIO set direction
##
##  Configure RTC GPIO direction, such as output only, input only,
##  output and input.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##  @param  mode GPIO direction
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_set_direction*(gpio_num: gpio_num_t; mode: rtc_gpio_mode_t): esp_err_t {.
    importc: "rtc_gpio_set_direction", header: "rtc_io.h".}
## *
##  @brief  RTC GPIO pullup enable
##
##  This function only works for RTC IOs. In general, call gpio_pullup_en,
##  which will work both for normal GPIOs and RTC IOs.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_pullup_en*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_pullup_en", header: "rtc_io.h".}
## *
##  @brief  RTC GPIO pulldown enable
##
##  This function only works for RTC IOs. In general, call gpio_pulldown_en,
##  which will work both for normal GPIOs and RTC IOs.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_pulldown_en*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_pulldown_en", header: "rtc_io.h".}
## *
##  @brief  RTC GPIO pullup disable
##
##  This function only works for RTC IOs. In general, call gpio_pullup_dis,
##  which will work both for normal GPIOs and RTC IOs.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_pullup_dis*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_pullup_dis", header: "rtc_io.h".}
## *
##  @brief  RTC GPIO pulldown disable
##
##  This function only works for RTC IOs. In general, call gpio_pulldown_dis,
##  which will work both for normal GPIOs and RTC IOs.
##
##  @param  gpio_num GPIO number (e.g. GPIO_NUM_12)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_pulldown_dis*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_pulldown_dis", header: "rtc_io.h".}
## *
##  @brief Enable hold function on an RTC IO pad
##
##  Enabling HOLD function will cause the pad to latch current values of
##  input enable, output enable, output value, function, drive strength values.
##  This function is useful when going into light or deep sleep mode to prevent
##  the pin configuration from changing.
##
##  @param gpio_num GPIO number (e.g. GPIO_NUM_12)
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_hold_en*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_hold_en", header: "rtc_io.h".}
## *
##  @brief Disable hold function on an RTC IO pad
##
##  Disabling hold function will allow the pad receive the values of
##  input enable, output enable, output value, function, drive strength from
##  RTC_IO peripheral.
##
##  @param gpio_num GPIO number (e.g. GPIO_NUM_12)
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG GPIO is not an RTC IO
##

proc rtc_gpio_hold_dis*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_hold_dis", header: "rtc_io.h".}
## *
##  @brief Helper function to disconnect internal circuits from an RTC IO
##  This function disables input, output, pullup, pulldown, and enables
##  hold feature for an RTC IO.
##  Use this function if an RTC IO needs to be disconnected from internal
##  circuits in deep sleep, to minimize leakage current.
##
##  In particular, for ESP32-WROVER module, call
##  rtc_gpio_isolate(GPIO_NUM_12) before entering deep sleep, to reduce
##  deep sleep current.
##
##  @param gpio_num GPIO number (e.g. GPIO_NUM_12).
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if GPIO is not an RTC IO
##

proc rtc_gpio_isolate*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_isolate", header: "rtc_io.h".}
## *
##  @brief Disable force hold signal for all RTC IOs
##
##  Each RTC pad has a "force hold" input signal from the RTC controller.
##  If this signal is set, pad latches current values of input enable,
##  function, output enable, and other signals which come from the RTC mux.
##  Force hold signal is enabled before going into deep sleep for pins which
##  are used for EXT1 wakeup.
##

proc rtc_gpio_force_hold_dis_all*() {.importc: "rtc_gpio_force_hold_dis_all",
                                    header: "rtc_io.h".}
## *
##  @brief Set RTC GPIO pad drive capability
##
##  @param gpio_num GPIO number, only support output GPIOs
##  @param strength Drive capability of the pad
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc rtc_gpio_set_drive_capability*(gpio_num: gpio_num_t;
                                   strength: gpio_drive_cap_t): esp_err_t {.
    importc: "rtc_gpio_set_drive_capability", header: "rtc_io.h".}
## *
##  @brief Get RTC GPIO pad drive capability
##
##  @param gpio_num GPIO number, only support output GPIOs
##  @param strength Pointer to accept drive capability of the pad
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc rtc_gpio_get_drive_capability*(gpio_num: gpio_num_t;
                                   strength: ptr gpio_drive_cap_t): esp_err_t {.
    importc: "rtc_gpio_get_drive_capability", header: "rtc_io.h".}
## *
##  @brief Enable wakeup from sleep mode using specific GPIO
##  @param gpio_num  GPIO number
##  @param intr_type  Wakeup on high level (GPIO_INTR_HIGH_LEVEL) or low level
##                    (GPIO_INTR_LOW_LEVEL)
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if gpio_num is not an RTC IO, or intr_type is not
##         one of GPIO_INTR_HIGH_LEVEL, GPIO_INTR_LOW_LEVEL.
##

proc rtc_gpio_wakeup_enable*(gpio_num: gpio_num_t; intr_type: gpio_int_type_t): esp_err_t {.
    importc: "rtc_gpio_wakeup_enable", header: "rtc_io.h".}
## *
##  @brief Disable wakeup from sleep mode using specific GPIO
##  @param gpio_num  GPIO number
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if gpio_num is not an RTC IO
##

proc rtc_gpio_wakeup_disable*(gpio_num: gpio_num_t): esp_err_t {.
    importc: "rtc_gpio_wakeup_disable", header: "rtc_io.h".}