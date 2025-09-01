##
##  SPDX-FileCopyrightText: 2020-2022 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

type

  tinyusb_config_t* {.importc: "tinyusb_config_t", header: "tinyusb.h", bycopy.} = object ##
                              ##
                              ##  @brief Configuration structure of the TinyUSB core
                              ##
                              ##  USB specification mandates self-powered devices to monitor USB VBUS to detect connection/disconnection events.
                              ##  If you want to use this feature, connected VBUS to any free GPIO through a voltage divider or voltage comparator.
                              ##  The voltage divider output should be (0.75 * Vdd) if VBUS is 4.4V (lowest valid voltage at device port).
                              ##  The comparator thresholds should be set with hysteresis: 4.35V (falling edge) and 4.75V (raising edge).
                              ##
    device_descriptor* {.importc: "device_descriptor".}: ptr tusb_desc_device_t ##
                              ## !< Pointer to a device descriptor. If set to NULL, the TinyUSB device will use a default device descriptor whose values are set in Kconfig
    string_descriptor* {.importc: "string_descriptor".}: cstringArray ##
                              ## !< Pointer to an array of string descriptors
    external_phy* {.importc: "external_phy".}: bool ##
                              ## !< Should USB use an external PHY
    configuration_descriptor* {.importc: "configuration_descriptor".}: ptr uint8 ##
                              ## !< Pointer to a configuration descriptor. If set to NULL, TinyUSB device will use a default configuration descriptor whose values are set in Kconfig
    self_powered* {.importc: "self_powered".}: bool ##
                              ## !< This is a self-powered USB device. USB VBUS must be monitored.
    vbus_monitor_io* {.importc: "vbus_monitor_io".}: cint
    ## !< GPIO for VBUS monitoring. Ignored if not self_powered.



proc tinyusb_driver_install*(config: ptr tinyusb_config_t): esp_err_t {.cdecl,
    importc: "tinyusb_driver_install", header: "tinyusb.h".}
  ##
                              ##
                              ##  @brief This is an all-in-one helper function, including:
                              ##  1. USB device driver initialization
                              ##  2. Descriptors preparation
                              ##  3. TinyUSB stack initialization
                              ##  4. Creates and start a task to handle usb events
                              ##
                              ##  @note Don't change Custom descriptor, but if it has to be done,
                              ##        Suggest to define as follows in order to match the Interface Association Descriptor (IAD):
                              ##        bDeviceClass = TUSB_CLASS_MISC,
                              ##        bDeviceSubClass = MISC_SUBCLASS_COMMON,
                              ##
                              ##  @param config tinyusb stack specific configuration
                              ##  @retval ESP_ERR_INVALID_ARG Install driver and tinyusb stack failed because of invalid argument
                              ##  @retval ESP_FAIL Install driver and tinyusb stack failed because of internal error
                              ##  @retval ESP_OK Install driver and tinyusb stack successfully
                              ##
##  TODO esp_err_t tinyusb_driver_uninstall(void); (IDF-1474)
