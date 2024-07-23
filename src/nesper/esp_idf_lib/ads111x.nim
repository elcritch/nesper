##
##  Copyright (c) 2016 Ruslan V. Uss <unclerus@gmail.com>
##  Copyright (c) 2020 Lucio Tarantino <https://github.com/dianlight>
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##  3. Neither the name of the copyright holder nor the names of itscontributors
##     may be used to endorse or promote products derived from this software without
##     specific prior written permission.
##
##  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
##  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
##  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
##  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
##  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
##  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## *
##  @file ads111x.h
##  @defgroup ads111x ads111x
##  @{
##
##  ESP-IDF driver for ADS1113/ADS1114/ADS1115, ADS1013/ADS1014/ADS1015 I2C ADC
##
##  Ported from esp-open-rtos
##
##  Copyright (c) 2016, 2018 Ruslan V. Uss <unclerus@gmail.com>
##  Copyright (c) 2020 Lucio Tarantino <https://github.com/dianlight>
##
##  BSD Licensed as described in the file LICENSE
##

import nesper
import nesper/gpios
import nesper/i2cs

import i2cdev

const hdr = "<ads111x.h>"

const
  ADS111X_ADDR_GND* = 0x00000048
  ADS111X_ADDR_VCC* = 0x00000049
  ADS111X_ADDR_SDA* = 0x0000004A
  ADS111X_ADDR_SCL* = 0x0000004B

  ADS111X_MAX_VALUE* = 0x00007FFF
  ADS101X_MAX_VALUE* = 0x000007FF

##  ADS101X overrides

## *
##  Gain amplifier
##

type
  ads111x_gain_t* {.size: sizeof(cint).} = enum
    ADS111X_GAIN_6V144 = 0,     ## !< +-6.144V
    ADS111X_GAIN_4V096,       ## !< +-4.096V
    ADS111X_GAIN_2V048,       ## !< +-2.048V (default)
    ADS111X_GAIN_1V024,       ## !< +-1.024V
    ADS111X_GAIN_0V512,       ## !< +-0.512V
    ADS111X_GAIN_0V256,       ## !< +-0.256V
    ADS111X_GAIN_0V256_2,     ## !< +-0.256V (same as ADS111X_GAIN_0V256)
    ADS111X_GAIN_0V256_3      ## !< +-0.256V (same as ADS111X_GAIN_0V256)


## *
##  Gain amplifier values
##

let ads111x_gain_values*: array[ads111x_gain_t, float32] = [
    ADS111X_GAIN_6V144: 6.144'f32,
    ADS111X_GAIN_4V096: 4.096,
    ADS111X_GAIN_2V048: 2.048,
    ADS111X_GAIN_1V024: 1.024,
    ADS111X_GAIN_0V512: 0.512,
    ADS111X_GAIN_0V256: 0.256,
    ADS111X_GAIN_0V256_2: 0.256,
    ADS111X_GAIN_0V256_3: 0.256]

## *
##  Input multiplexer configuration (ADS1115 only)
##

type
  ads111x_mux_t* {.size: sizeof(cint).} = enum
    ADS111X_MUX_0_1 = 0,        ## !< positive = AIN0, negative = AIN1 (default)
    ADS111X_MUX_0_3,          ## !< positive = AIN0, negative = AIN3
    ADS111X_MUX_1_3,          ## !< positive = AIN1, negative = AIN3
    ADS111X_MUX_2_3,          ## !< positive = AIN2, negative = AIN3
    ADS111X_MUX_0_GND,        ## !< positive = AIN0, negative = GND
    ADS111X_MUX_1_GND,        ## !< positive = AIN1, negative = GND
    ADS111X_MUX_2_GND,        ## !< positive = AIN2, negative = GND
    ADS111X_MUX_3_GND         ## !< positive = AIN3, negative = GND


## *
##  Data rate
##

type
  ads111x_data_rate_t* {.size: sizeof(cint).} = enum
    ADS111X_DATA_RATE_8 = 0,    ## !< 8 samples per second
    ADS111X_DATA_RATE_16,     ## !< 16 samples per second
    ADS111X_DATA_RATE_32,     ## !< 32 samples per second
    ADS111X_DATA_RATE_64,     ## !< 64 samples per second
    ADS111X_DATA_RATE_128,    ## !< 128 samples per second (default)
    ADS111X_DATA_RATE_250,    ## !< 250 samples per second
    ADS111X_DATA_RATE_475,    ## !< 475 samples per second
    ADS111X_DATA_RATE_860     ## !< 860 samples per second


const
  ADS101X_DATA_RATE_128* = ADS111X_DATA_RATE_8
  ADS101X_DATA_RATE_250* = ADS111X_DATA_RATE_16
  ADS101X_DATA_RATE_490* = ADS111X_DATA_RATE_32
  ADS101X_DATA_RATE_920* = ADS111X_DATA_RATE_64
  ADS101X_DATA_RATE_1600* = ADS111X_DATA_RATE_128
  ADS101X_DATA_RATE_2400* = ADS111X_DATA_RATE_250
  ADS101X_DATA_RATE_3300* = ADS111X_DATA_RATE_475

## *
##  Operational mode
##

type
  ads111x_mode_t* {.size: sizeof(cint).} = enum
    ADS111X_MODE_CONTINUOUS = 0, ## !< Continuous conversion mode
    ADS111X_MODE_SINGLE_SHOT  ## !< Power-down single-shot mode (default)


## *
##  Comparator mode (ADS1114 and ADS1115 only)
##

type
  ads111x_comp_mode_t* {.size: sizeof(cint).} = enum
    ADS111X_COMP_MODE_NORMAL = 0, ## !< Traditional comparator with hysteresis (default)
    ADS111X_COMP_MODE_WINDOW  ## !< Window comparator


## *
##  Comparator polarity (ADS1114 and ADS1115 only)
##

type
  ads111x_comp_polarity_t* {.size: sizeof(cint).} = enum
    ADS111X_COMP_POLARITY_LOW = 0, ## !< Active low (default)
    ADS111X_COMP_POLARITY_HIGH ## !< Active high


## *
##  Comparator latch (ADS1114 and ADS1115 only)
##

type
  ads111x_comp_latch_t* {.size: sizeof(cint).} = enum
    ADS111X_COMP_LATCH_DISABLED = 0, ## !< Non-latching comparator (default)
    ADS111X_COMP_LATCH_ENABLED ## !< Latching comparator


## *
##  Comparator queue
##

type
  ads111x_comp_queue_t* {.size: sizeof(cint).} = enum
    ADS111X_COMP_QUEUE_1 = 0,   ## !< Assert ALERT/RDY pin after one conversion
    ADS111X_COMP_QUEUE_2,     ## !< Assert ALERT/RDY pin after two conversions
    ADS111X_COMP_QUEUE_4,     ## !< Assert ALERT/RDY pin after four conversions
    ADS111X_COMP_QUEUE_DISABLED ## !< Disable comparator (default)


## *
##  @brief Initialize device descriptor
##
##  @param dev Device descriptor
##  @param addr Device address
##  @param port I2C port number
##  @param sda_gpio GPIO pin for SDA
##  @param scl_gpio GPIO pin for SCL
##  @return `ESP_OK` on success
##

proc ads111x_init_desc*(dev: ptr i2c_dev_t; `addr`: uint8; port: i2c_port_t;
                       sda_gpio: gpio_num_t; scl_gpio: gpio_num_t): esp_err_t {.
    importc: "ads111x_init_desc", header: hdr.}
## *
##  @brief Free device descriptor
##
##  @param dev Device descriptor
##  @return `ESP_OK` on success
##

proc ads111x_free_desc*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "ads111x_free_desc", header: hdr.}
## *
##  @brief Get device operational status
##
##  @param dev Device descriptor
##  @param[out] busy True when device performing conversion
##  @return `ESP_OK` on success
##

proc ads111x_is_busy*(dev: ptr i2c_dev_t; busy: ptr bool): esp_err_t {.
    importc: "ads111x_is_busy", header: hdr.}
## *
##  @brief Begin a single conversion
##
##  Only in single-shot mode.
##
##  @param dev Device descriptor
##  @return `ESP_OK` on success
##

proc ads111x_start_conversion*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "ads111x_start_conversion", header: hdr.}
## *
##  @brief Read last conversion result
##
##  @param dev Device descriptor
##  @param[out] value Last conversion result
##  @return `ESP_OK` on success
##

proc ads111x_get_value*(dev: ptr i2c_dev_t; value: ptr int16): esp_err_t {.
    importc: "ads111x_get_value", header: hdr.}
## *
##  @brief Read last conversion result for ADS101x
##
##  @param dev Device descriptor
##  @param[out] value Last conversion result
##  @return `ESP_OK` on success
##

proc ads101x_get_value*(dev: ptr i2c_dev_t; value: ptr int16): esp_err_t {.
    importc: "ads101x_get_value", header: hdr.}
## *
##  @brief Read the programmable gain amplifier configuration
##
##  ADS1114 and ADS1115 only.
##  Use ::ads111x_gain_values[] for real voltage.
##
##  @param dev Device descriptor
##  @param[out] gain Gain value
##  @return `ESP_OK` on success
##

proc ads111x_get_gain*(dev: ptr i2c_dev_t; gain: ptr ads111x_gain_t): esp_err_t {.
    importc: "ads111x_get_gain", header: hdr.}
## *
##  @brief Configure the programmable gain amplifier
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param gain Gain value
##  @return `ESP_OK` on success
##

proc ads111x_set_gain*(dev: ptr i2c_dev_t; gain: ads111x_gain_t): esp_err_t {.
    importc: "ads111x_set_gain", header: hdr.}
## *
##  @brief Read the input multiplexer configuration
##
##  ADS1115 only.
##
##  @param dev Device descriptor
##  @param[out] mux Input multiplexer configuration
##  @return `ESP_OK` on success
##

proc ads111x_get_input_mux*(dev: ptr i2c_dev_t; mux: ptr ads111x_mux_t): esp_err_t {.
    importc: "ads111x_get_input_mux", header: hdr.}
## *
##  @brief Configure the input multiplexer configuration
##
##  ADS1115 only.
##
##  @param dev Device descriptor
##  @param mux Input multiplexer configuration
##  @return `ESP_OK` on success
##

proc ads111x_set_input_mux*(dev: ptr i2c_dev_t; mux: ads111x_mux_t): esp_err_t {.
    importc: "ads111x_set_input_mux", header: hdr.}
## *
##  @brief Read the device operating mode
##
##  @param dev Device descriptor
##  @param[out] mode Device operating mode
##  @return `ESP_OK` on success
##

proc ads111x_get_mode*(dev: ptr i2c_dev_t; mode: ptr ads111x_mode_t): esp_err_t {.
    importc: "ads111x_get_mode", header: hdr.}
## *
##  @brief Set the device operating mode
##
##  @param dev Device descriptor
##  @param mode Device operating mode
##  @return `ESP_OK` on success
##

proc ads111x_set_mode*(dev: ptr i2c_dev_t; mode: ads111x_mode_t): esp_err_t {.
    importc: "ads111x_set_mode", header: hdr.}
## *
##  @brief Read the data rate
##
##  @param dev Device descriptor
##  @param[out] rate Data rate
##  @return `ESP_OK` on success
##

proc ads111x_get_data_rate*(dev: ptr i2c_dev_t; rate: ptr ads111x_data_rate_t): esp_err_t {.
    importc: "ads111x_get_data_rate", header: hdr.}
## *
##  @brief Configure the data rate
##
##  @param dev Device descriptor
##  @param rate Data rate
##  @return `ESP_OK` on success
##

proc ads111x_set_data_rate*(dev: ptr i2c_dev_t; rate: ads111x_data_rate_t): esp_err_t {.
    importc: "ads111x_set_data_rate", header: hdr.}
## *
##  @brief Get comparator mode
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param[out] mode Comparator mode
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_mode*(dev: ptr i2c_dev_t; mode: ptr ads111x_comp_mode_t): esp_err_t {.
    importc: "ads111x_get_comp_mode", header: hdr.}
## *
##  @brief Set comparator mode
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param mode Comparator mode
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_mode*(dev: ptr i2c_dev_t; mode: ads111x_comp_mode_t): esp_err_t {.
    importc: "ads111x_set_comp_mode", header: hdr.}
## *
##  @brief Get polarity of the comparator output pin ALERT/RDY
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param[out] polarity Comparator output pin polarity
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_polarity*(dev: ptr i2c_dev_t;
                               polarity: ptr ads111x_comp_polarity_t): esp_err_t {.
    importc: "ads111x_get_comp_polarity", header: hdr.}
## *
##  @brief Set polarity of the comparator output pin ALERT/RDY
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param polarity Comparator output pin polarity
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_polarity*(dev: ptr i2c_dev_t;
                               polarity: ads111x_comp_polarity_t): esp_err_t {.
    importc: "ads111x_set_comp_polarity", header: hdr.}
## *
##  @brief Get comparator output latch mode
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param[out] latch Comparator output latch mode
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_latch*(dev: ptr i2c_dev_t; latch: ptr ads111x_comp_latch_t): esp_err_t {.
    importc: "ads111x_get_comp_latch", header: hdr.}
## *
##  @brief Set comparator output latch mode
##
##  ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param latch Comparator output latch mode
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_latch*(dev: ptr i2c_dev_t; latch: ads111x_comp_latch_t): esp_err_t {.
    importc: "ads111x_set_comp_latch", header: hdr.}
## *
##  @brief Get comparator queue size
##
##  Get number of the comparator conversions before pin ALERT/RDY
##  assertion. ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param[out] queue Number of the comparator conversions
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_queue*(dev: ptr i2c_dev_t; queue: ptr ads111x_comp_queue_t): esp_err_t {.
    importc: "ads111x_get_comp_queue", header: hdr.}
## *
##  @brief Set comparator queue size
##
##  Set number of the comparator conversions before pin ALERT/RDY
##  assertion or disable comparator. ADS1114 and ADS1115 only.
##
##  @param dev Device descriptor
##  @param queue Number of the comparator conversions
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_queue*(dev: ptr i2c_dev_t; queue: ads111x_comp_queue_t): esp_err_t {.
    importc: "ads111x_set_comp_queue", header: hdr.}
## *
##  @brief Get the lower threshold value used by comparator
##
##  @param dev Device descriptor
##  @param[out] th Lower threshold value
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_low_thresh*(dev: ptr i2c_dev_t; th: ptr int16): esp_err_t {.
    importc: "ads111x_get_comp_low_thresh", header: hdr.}
## *
##  @brief Set the lower threshold value used by comparator
##
##  @param dev Device descriptor
##  @param th Lower threshold value
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_low_thresh*(dev: ptr i2c_dev_t; th: int16): esp_err_t {.
    importc: "ads111x_set_comp_low_thresh", header: hdr.}
## *
##  @brief Get the upper threshold value used by comparator
##
##  @param dev Device descriptor
##  @param[out] th Upper threshold value
##  @return `ESP_OK` on success
##

proc ads111x_get_comp_high_thresh*(dev: ptr i2c_dev_t; th: ptr int16): esp_err_t {.
    importc: "ads111x_get_comp_high_thresh", header: hdr.}
## *
##  @brief Set the upper threshold value used by comparator
##
##  @param dev Device descriptor
##  @param th Upper threshold value
##  @return `ESP_OK` on success
##

proc ads111x_set_comp_high_thresh*(dev: ptr i2c_dev_t; th: int16): esp_err_t {.
    importc: "ads111x_set_comp_high_thresh", header: hdr.}
## *@}

