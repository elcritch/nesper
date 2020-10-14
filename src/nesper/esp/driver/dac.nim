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
  esp_err, soc/dac_periph

type
  dac_channel_t* {.size: sizeof(cint).} = enum
    DAC_CHANNEL_1 = 1,          ## !< DAC channel 1 is GPIO25
    DAC_CHANNEL_2,            ## !< DAC channel 2 is GPIO26
    DAC_CHANNEL_MAX


## *
##  @brief Get the gpio number of a specific DAC channel.
##
##  @param channel Channel to get the gpio number
##
##  @param gpio_num output buffer to hold the gpio number
##
##  @return
##    - ESP_OK if success
##    - ESP_ERR_INVALID_ARG if channal not valid
##

proc dac_pad_get_io_num*(channel: dac_channel_t; gpio_num: ptr gpio_num_t): esp_err_t {.
    importc: "dac_pad_get_io_num", header: "dac.h".}
## *
##  @brief Set DAC output voltage.
##
##  DAC output is 8-bit. Maximum (255) corresponds to VDD.
##
##  @note Need to configure DAC pad before calling this function.
##        DAC channel 1 is attached to GPIO25, DAC channel 2 is attached to GPIO26
##
##  @param channel DAC channel
##  @param dac_value DAC output value
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc dac_output_voltage*(channel: dac_channel_t; dac_value: uint8_t): esp_err_t {.
    importc: "dac_output_voltage", header: "dac.h".}
## *
##  @brief DAC pad output enable
##
##  @param channel DAC channel
##  @note DAC channel 1 is attached to GPIO25, DAC channel 2 is attached to GPIO26
##        I2S left channel will be mapped to DAC channel 2
##        I2S right channel will be mapped to DAC channel 1
##

proc dac_output_enable*(channel: dac_channel_t): esp_err_t {.
    importc: "dac_output_enable", header: "dac.h".}
## *
##  @brief DAC pad output disable
##
##  @param channel DAC channel
##  @note DAC channel 1 is attached to GPIO25, DAC channel 2 is attached to GPIO26
##

proc dac_output_disable*(channel: dac_channel_t): esp_err_t {.
    importc: "dac_output_disable", header: "dac.h".}
## *
##  @brief Enable DAC output data from I2S
##

proc dac_i2s_enable*(): esp_err_t {.importc: "dac_i2s_enable", header: "dac.h".}
## *
##  @brief Disable DAC output data from I2S
##

proc dac_i2s_disable*(): esp_err_t {.importc: "dac_i2s_disable", header: "dac.h".}