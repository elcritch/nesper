
const
  USB_ESPRESSIF_VID* = 0x303A ##
                              ##  SPDX-FileCopyrightText: 2020-2022 Espressif Systems (Shanghai) CO LTD
                              ##
                              ##  SPDX-License-Identifier: Apache-2.0
                              ##
  USB_STRING_DESCRIPTOR_ARRAY_SIZE* = 8

type

  tinyusb_usbdev_t* {.size: sizeof(cint).} = enum
    TINYUSB_USBDEV_0

  tusb_desc_strarray_device_t* = array[USB_STRING_DESCRIPTOR_ARRAY_SIZE, cstring]

