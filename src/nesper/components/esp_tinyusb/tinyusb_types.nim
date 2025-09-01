
const hdr_acm = "tusb_cdc_acm.h"

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


type
  cdc_line_coding_t* {.importc: "cdc_line_coding_t", header: hdr_acm, bycopy.} = object
    bit_rate*: uint32
    stop_bits*: uint8
    parity*: uint8
    data_bits*: uint8

  cdc_line_control_state_t* {.importc: "cdc_line_control_state_t", header: hdr_acm, bycopy.} = object
    dtr*: bool
    rts*: bool
