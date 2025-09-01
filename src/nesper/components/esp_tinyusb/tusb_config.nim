##
##  The MIT License (MIT)
##
##  Copyright (c) 2019 Ha Thach (tinyusb.org),
##  Additions Copyright (c) 2020, Espressif Systems (Shanghai) PTE LTD
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##
##  The above copyright notice and this permission notice shall be included in
##  all copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
##  THE SOFTWARE.
##
##

import ../../consts

# when not defined(CONFIG_TINYUSB_CDC_ENABLED):
#   const
#     CONFIG_TINYUSB_CDC_ENABLED* = 0
# when not defined(CONFIG_TINYUSB_CDC_COUNT):
#   const
#     CONFIG_TINYUSB_CDC_COUNT* = 0
# when not defined(CONFIG_TINYUSB_MSC_ENABLED):
#   const
#     CONFIG_TINYUSB_MSC_ENABLED* = 0
# when not defined(CONFIG_TINYUSB_HID_COUNT):
#   const
#     CONFIG_TINYUSB_HID_COUNT* = 0
# when not defined(CONFIG_TINYUSB_MIDI_COUNT):
#   const
#     CONFIG_TINYUSB_MIDI_COUNT* = 0
# when not defined(CONFIG_TINYUSB_CUSTOM_CLASS_ENABLED):
#   const
#     CONFIG_TINYUSB_CUSTOM_CLASS_ENABLED* = 0
# when not defined(CONFIG_TINYUSB_DEBUG_LEVEL):
#   const
#     CONFIG_TINYUSB_DEBUG_LEVEL* = 0

# const
#   CFG_TUSB_RHPORT0_MODE* = OPT_MODE_DEVICE or OPT_MODE_FULL_SPEED
#   CFG_TUSB_OS* = OPT_OS_FREERTOS

##  USB DMA on some MCUs can only access a specific SRAM region with restriction on alignment.
##  Tinyusb use follows macros to declare transferring memory so that they can be put
##  into those specific section.
##  e.g
##  - CFG_TUSB_MEM SECTION : __attribute__ (( section(".usb_ram") ))
##  - CFG_TUSB_MEM_ALIGN   : __attribute__ ((aligned(4)))
##

when not defined(CFG_TUSB_MEM_ALIGN):
  const
    CFG_TUSB_MEM_ALIGN* = TU_ATTR_ALIGNED(4)
when not defined(CFG_TUD_ENDPOINT0_SIZE):
  const
    CFG_TUD_ENDPOINT0_SIZE* = 64
const
  CFG_TUSB_DEBUG* = CONFIG_TINYUSB_DEBUG_LEVEL ##  Debug Level
  CFG_TUD_CDC_RX_BUFSIZE* = CONFIG_TINYUSB_CDC_RX_BUFSIZE ##
                              ##  CDC FIFO size of TX and RX
  CFG_TUD_CDC_TX_BUFSIZE* = CONFIG_TINYUSB_CDC_TX_BUFSIZE
  CFG_TUD_MSC_BUFSIZE* = CONFIG_TINYUSB_MSC_BUFSIZE ##
                              ##  MSC Buffer size of Device Mass storage
  CFG_TUD_MIDI_EP_BUFSIZE* = 64
  CFG_TUD_MIDI_EPSIZE* = CFG_TUD_MIDI_EP_BUFSIZE
  CFG_TUD_MIDI_RX_BUFSIZE* = 64
  CFG_TUD_MIDI_TX_BUFSIZE* = 64
  CFG_TUD_CDC* = CONFIG_TINYUSB_CDC_COUNT ##  Enabled device class driver
  CFG_TUD_MSC* = CONFIG_TINYUSB_MSC_ENABLED
  CFG_TUD_HID* = CONFIG_TINYUSB_HID_COUNT
  CFG_TUD_MIDI* = CONFIG_TINYUSB_MIDI_COUNT
  CFG_TUD_CUSTOM_CLASS* = CONFIG_TINYUSB_CUSTOM_CLASS_ENABLED
