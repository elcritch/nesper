##
##  The MIT License (MIT)
##
##  Copyright (c) 2018 Ruslan V. Uss <unclerus@gmail.com>
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##  The above copyright notice and this permission notice shall be included in all
##  copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##  SOFTWARE.
##
## *
##  @file i2cdev.h
##  @defgroup i2cdev i2cdev
##  @{
##
##  ESP-IDF I2C master thread-safe functions for communication with I2C slave
##
##  Copyright (c) 2018 Ruslan V. Uss <unclerus@gmail.com>
##
##  MIT Licensed as described in the file LICENSE
##

import nesper
import nesper/esp/driver/i2c

const hdr = "<i2cdev.h>"

var I2CDEV_MAX_STRETCH_TIME* {.importc: "I2CDEV_MAX_STRETCH_TIME", header: hdr.}: cint



## *
##  I2C device descriptor
##

type
  i2c_dev_t* {.importc: "i2c_dev_t", header: hdr, bycopy.} = object
    port* {.importc: "port".}: i2c_port_t ## !< I2C port number
    cfg* {.importc: "cfg".}: i2c_config_t ## !< I2C driver configuration
    devAddr* {.importc: "addr".}: uint8 ## !< Unshifted address
    mutex* {.importc: "mutex".}: SemaphoreHandle_t ## !< Device mutex
    timeout_ticks* {.importc: "timeout_ticks".}: uint32 ## !< HW I2C bus timeout (stretch time), in ticks. 80MHz APB clock
                                                      ##                                   ticks for ESP-IDF, CPU ticks for ESP8266.
                                                      ##                                   When this value is 0, I2CDEV_MAX_STRETCH_TIME will be used


## *
##  @brief Init library
##
##  The function must be called before any other
##  functions of this library.
##
##  @return ESP_OK on success
##

proc i2cdev_init*(): esp_err_t {.importc: "i2cdev_init", header: hdr.}
## *
##  @brief Finish work with library
##
##  Uninstall i2c drivers.
##
##  @return ESP_OK on success
##

proc i2cdev_done*(): esp_err_t {.importc: "i2cdev_done", header: hdr.}
## *
##  @brief Create mutex for device descriptor
##
##  This function does nothing if option CONFIG_I2CDEV_NOLOCK is enabled.
##
##  @param dev Device descriptor
##  @return ESP_OK on success
##

proc i2c_dev_create_mutex*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "i2c_dev_create_mutex", header: hdr.}
## *
##  @brief Delete mutex for device descriptor
##
##  This function does nothing if option CONFIG_I2CDEV_NOLOCK is enabled.
##
##  @param dev Device descriptor
##  @return ESP_OK on success
##

proc i2c_dev_delete_mutex*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "i2c_dev_delete_mutex", header: hdr.}
## *
##  @brief Take device mutex
##
##  This function does nothing if option CONFIG_I2CDEV_NOLOCK is enabled.
##
##  @param dev Device descriptor
##  @return ESP_OK on success
##

proc i2c_dev_take_mutex*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "i2c_dev_take_mutex", header: hdr.}
## *
##  @brief Give device mutex
##
##  This function does nothing if option CONFIG_I2CDEV_NOLOCK is enabled.
##
##  @param dev Device descriptor
##  @return ESP_OK on success
##

proc i2c_dev_give_mutex*(dev: ptr i2c_dev_t): esp_err_t {.
    importc: "i2c_dev_give_mutex", header: hdr.}
## *
##  @brief Read from slave device
##
##  Issue a send operation of \p out_data register address, followed by reading \p in_size bytes
##  from slave into \p in_data .
##  Function is thread-safe.
##
##  @param dev Device descriptor
##  @param out_data Pointer to data to send if non-null
##  @param out_size Size of data to send
##  @param[out] in_data Pointer to input data buffer
##  @param in_size Number of byte to read
##  @return ESP_OK on success
##

proc i2c_dev_read*(dev: ptr i2c_dev_t; out_data: pointer; out_size: csize_t;
                  in_data: pointer; in_size: csize_t): esp_err_t {.
    importc: "i2c_dev_read", header: hdr.}
## *
##  @brief Write to slave device
##
##  Write \p out_size bytes from \p out_data to slave into \p out_reg register address.
##  Function is thread-safe.
##
##  @param dev Device descriptor
##  @param out_reg Pointer to register address to send if non-null
##  @param out_reg_size Size of register address
##  @param out_data Pointer to data to send
##  @param out_size Size of data to send
##  @return ESP_OK on success
##

proc i2c_dev_write*(dev: ptr i2c_dev_t; out_reg: pointer; out_reg_size: csize_t;
                   out_data: pointer; out_size: csize_t): esp_err_t {.
    importc: "i2c_dev_write", header: hdr.}
## *
##  @brief Read from register with an 8-bit address
##
##  Shortcut to ::i2c_dev_read().
##
##  @param dev Device descriptor
##  @param reg Register address
##  @param[out] in_data Pointer to input data buffer
##  @param in_size Number of byte to read
##  @return ESP_OK on success
##

proc i2c_dev_read_reg*(dev: ptr i2c_dev_t; reg: uint8; in_data: pointer;
                      in_size: csize_t): esp_err_t {.importc: "i2c_dev_read_reg",
    header: hdr.}
## *
##  @brief Write to register with an 8-bit address
##
##  Shortcut to ::i2c_dev_write().
##
##  @param dev Device descriptor
##  @param reg Register address
##  @param out_data Pointer to data to send
##  @param out_size Size of data to send
##  @return ESP_OK on success
##

proc i2c_dev_write_reg*(dev: ptr i2c_dev_t; reg: uint8; out_data: pointer;
                       out_size: csize_t): esp_err_t {.
    importc: "i2c_dev_write_reg", header: hdr.}
## *@}

proc I2C_DEV_TAKE_MUTEX*(dev: ptr i2c_dev_t): esp_err_t {.importc: "$1", header: hdr.}
proc I2C_DEV_GIVE_MUTEX*(dev: ptr i2c_dev_t): esp_err_t {.importc: "$1", header: hdr.}
proc I2C_DEV_CHECK*(dev: ptr i2c_dev_t, x: esp_err_t): esp_err_t {.importc: "$1", header: hdr.}
# proc I2C_DEV_CHECK_LOGE*(dev: ptr i2c_dev_t): esp_err_t {.importc: "$1", header: hdr.}
