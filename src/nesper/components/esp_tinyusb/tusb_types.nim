##
##  The MIT License (MIT)
##
##  Copyright (c) 2019 Ha Thach (tinyusb.org)
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
##  This file is part of the TinyUSB stack.
##

## ------------- Device DCache declaration -------------//

##  Declare an endpoint buffer with uint8_t[size]

##  Declare an endpoint buffer with a type

## ------------- Host DCache declaration -------------//

##  Declare an endpoint buffer with uint8_t[size]

##  Declare an endpoint buffer with a type

# const hdr_acm = "tusb_cdc_acm.h"
# const hdr = "tusb_types.h"
const hdr_acm = "tusb.h"
const hdr = "tusb.h"

type
  cdc_line_coding_t* {.importc: "cdc_line_coding_t", header: hdr_acm, bycopy.} = object
    bit_rate*: uint32
    stop_bits*: uint8
    parity*: uint8
    data_bits*: uint8

  cdc_line_control_state_t* {.importc: "cdc_line_control_state_t", header: hdr_acm, bycopy.} = object
    dtr*: bool
    rts*: bool


type

  tusb_role_t* {.size: sizeof(cint).} = enum ## ------------------------------------------------------------------
                                              ##  CONSTANTS
                                              ## ------------------------------------------------------------------
    TUSB_ROLE_INVALID = 0, TUSB_ROLE_DEVICE = 0x1, TUSB_ROLE_HOST = 0x2


type

  tusb_speed_t* {.size: sizeof(cint).} = enum ##  defined base on EHCI specs value for Endpoint Speed
    TUSB_SPEED_FULL = 0, TUSB_SPEED_LOW = 1, TUSB_SPEED_HIGH = 2,
    TUSB_SPEED_AUTO = 0xaa, TUSB_SPEED_INVALID = 0xff


type

  tusb_xfer_type_t* {.size: sizeof(cint).} = enum ##
                              ##  defined base on USB Specs Endpoint's bmAttributes
    TUSB_XFER_CONTROL = 0, TUSB_XFER_ISOCHRONOUS = 1, TUSB_XFER_BULK = 2,
    TUSB_XFER_INTERRUPT = 3

  tusb_dir_t* {.size: sizeof(cint).} = enum
    TUSB_DIR_OUT = 0, TUSB_DIR_IN = 1, TUSB_DIR_IN_MASK = 0x80

const
  TUSB_EPSIZE_BULK_FS* = 64
  TUSB_EPSIZE_BULK_HS* = 512
  TUSB_EPSIZE_ISO_FS_MAX* = 1023
  TUSB_EPSIZE_ISO_HS_MAX* = 1024

type

  tusb_iso_ep_attribute_t* {.size: sizeof(cint).} = enum ##
                              ##  Isochronous Endpoint Attributes
    TUSB_ISO_EP_ATT_NO_SYNC = 0x00, TUSB_ISO_EP_ATT_ASYNCHRONOUS = 0x04,
    TUSB_ISO_EP_ATT_ADAPTIVE = 0x08, TUSB_ISO_EP_ATT_SYNCHRONOUS = 0x0C, TUSB_ISO_EP_ATT_EXPLICIT_FB = 0x10, ##
                              ## < Feedback End Point
    TUSB_ISO_EP_ATT_IMPLICIT_FB = 0x20 ## < Data endpoint that also serves as an implicit feedback

const
  TUSB_ISO_EP_ATT_DATA = TUSB_ISO_EP_ATT_NO_SYNC

type

  tusb_desc_type_t* {.size: sizeof(cint).} = enum ##
                              ##  USB Descriptor Types
    TUSB_DESC_DEVICE = 0x01, TUSB_DESC_CONFIGURATION = 0x02,
    TUSB_DESC_STRING = 0x03, TUSB_DESC_INTERFACE = 0x04,
    TUSB_DESC_ENDPOINT = 0x05, TUSB_DESC_DEVICE_QUALIFIER = 0x06,
    TUSB_DESC_OTHER_SPEED_CONFIG = 0x07, TUSB_DESC_INTERFACE_POWER = 0x08,
    TUSB_DESC_OTG = 0x09, TUSB_DESC_DEBUG = 0x0A,
    TUSB_DESC_INTERFACE_ASSOCIATION = 0x0B, TUSB_DESC_BOS = 0x0F,
    TUSB_DESC_DEVICE_CAPABILITY = 0x10, TUSB_DESC_FUNCTIONAL = 0x21, ##
                              ##  Class Specific Descriptor
    TUSB_DESC_CS_CONFIGURATION = 0x22, TUSB_DESC_CS_STRING = 0x23,
    TUSB_DESC_CS_INTERFACE = 0x24, TUSB_DESC_CS_ENDPOINT = 0x25,
    TUSB_DESC_SUPERSPEED_ENDPOINT_COMPANION = 0x30,
    TUSB_DESC_SUPERSPEED_ISO_ENDPOINT_COMPANION = 0x31

  tusb_request_code_t* {.size: sizeof(cint).} = enum
    TUSB_REQ_GET_STATUS = 0, TUSB_REQ_CLEAR_FEATURE = 1, TUSB_REQ_RESERVED = 2,
    TUSB_REQ_SET_FEATURE = 3, TUSB_REQ_RESERVED2 = 4, TUSB_REQ_SET_ADDRESS = 5,
    TUSB_REQ_GET_DESCRIPTOR = 6, TUSB_REQ_SET_DESCRIPTOR = 7,
    TUSB_REQ_GET_CONFIGURATION = 8, TUSB_REQ_SET_CONFIGURATION = 9,
    TUSB_REQ_GET_INTERFACE = 10, TUSB_REQ_SET_INTERFACE = 11,
    TUSB_REQ_SYNCH_FRAME = 12

  tusb_request_feature_selector_t* {.size: sizeof(cint).} = enum
    TUSB_REQ_FEATURE_EDPT_HALT = 0, TUSB_REQ_FEATURE_REMOTE_WAKEUP = 1,
    TUSB_REQ_FEATURE_TEST_MODE = 2

  tusb_request_type_t* {.size: sizeof(cint).} = enum
    TUSB_REQ_TYPE_STANDARD = 0, TUSB_REQ_TYPE_CLASS, TUSB_REQ_TYPE_VENDOR,
    TUSB_REQ_TYPE_INVALID

  tusb_request_recipient_t* {.size: sizeof(cint).} = enum
    TUSB_REQ_RCPT_DEVICE = 0, TUSB_REQ_RCPT_INTERFACE, TUSB_REQ_RCPT_ENDPOINT,
    TUSB_REQ_RCPT_OTHER

const
  TUSB_DESC_CS_DEVICE = TUSB_DESC_FUNCTIONAL

type

  tusb_class_code_t* {.size: sizeof(cint).} = enum ##
                              ##  https://www.usb.org/defined-class-codes
    TUSB_CLASS_UNSPECIFIED = 0, TUSB_CLASS_AUDIO = 1, TUSB_CLASS_CDC = 2,
    TUSB_CLASS_HID = 3, TUSB_CLASS_RESERVED_4 = 4, TUSB_CLASS_PHYSICAL = 5,
    TUSB_CLASS_IMAGE = 6, TUSB_CLASS_PRINTER = 7, TUSB_CLASS_MSC = 8,
    TUSB_CLASS_HUB = 9, TUSB_CLASS_CDC_DATA = 10, TUSB_CLASS_SMART_CARD = 11,
    TUSB_CLASS_RESERVED_12 = 12, TUSB_CLASS_CONTENT_SECURITY = 13,
    TUSB_CLASS_VIDEO = 14, TUSB_CLASS_PERSONAL_HEALTHCARE = 15,
    TUSB_CLASS_AUDIO_VIDEO = 16, TUSB_CLASS_DIAGNOSTIC = 0xDC,
    TUSB_CLASS_WIRELESS_CONTROLLER = 0xE0, TUSB_CLASS_MISC = 0xEF,
    TUSB_CLASS_APPLICATION_SPECIFIC = 0xFE, TUSB_CLASS_VENDOR_SPECIFIC = 0xFF

  misc_subclass_type_t* {.size: sizeof(cint).} = enum
    MISC_SUBCLASS_COMMON = 2

  misc_protocol_type_t* {.size: sizeof(cint).} = enum
    MISC_PROTOCOL_IAD = 1

  app_subclass_type_t* {.size: sizeof(cint).} = enum
    APP_SUBCLASS_DFU_RUNTIME = 0x01, APP_SUBCLASS_USBTMC = 0x03

  device_capability_type_t* {.size: sizeof(cint).} = enum
    DEVICE_CAPABILITY_WIRELESS_USB = 0x01,
    DEVICE_CAPABILITY_USB20_EXTENSION = 0x02,
    DEVICE_CAPABILITY_SUPERSPEED_USB = 0x03,
    DEVICE_CAPABILITY_CONTAINER_id = 0x04, DEVICE_CAPABILITY_PLATFORM = 0x05,
    DEVICE_CAPABILITY_POWER_DELIVERY = 0x06,
    DEVICE_CAPABILITY_BATTERY_INFO = 0x07,
    DEVICE_CAPABILITY_PD_CONSUMER_PORT = 0x08,
    DEVICE_CAPABILITY_PD_PROVIDER_PORT = 0x09,
    DEVICE_CAPABILITY_SUPERSPEED_PLUS = 0x0A,
    DEVICE_CAPABILITY_PRECESION_TIME_MEASUREMENT = 0x0B,
    DEVICE_CAPABILITY_WIRELESS_USB_EXT = 0x0C,
    DEVICE_CAPABILITY_BILLBOARD = 0x0D, DEVICE_CAPABILITY_AUTHENTICATION = 0x0E,
    DEVICE_CAPABILITY_BILLBOARD_EX = 0x0F,
    DEVICE_CAPABILITY_CONFIGURATION_SUMMARY = 0x10

const
  TUSB_DESC_CONFIG_ATT_REMOTE_WAKEUP* = 1'u shl 5
  TUSB_DESC_CONFIG_ATT_SELF_POWERED* = 1'u shl 6

type

  tusb_feature_test_mode_t* {.size: sizeof(cint).} = enum ##
                              ##  USB 2.0 Spec Table 9-7: Test Mode Selectors
    TUSB_FEATURE_TEST_J = 1, TUSB_FEATURE_TEST_K = 2,
    TUSB_FEATURE_TEST_SE0_NAK = 3, TUSB_FEATURE_TEST_PACKET = 4,
    TUSB_FEATURE_TEST_FORCE_ENABLE = 5


type

  xfer_result_t* {.size: sizeof(cint).} = enum ## --------------------------------------------------------------------+
                                                ##
                                                ## --------------------------------------------------------------------+
    XFER_RESULT_SUCCESS = 0, XFER_RESULT_FAILED, XFER_RESULT_STALLED,
    XFER_RESULT_TIMEOUT, XFER_RESULT_INVALID

const
  DESC_OFFSET_LEN* = 0       ##  TODO remove
  DESC_OFFSET_TYPE* = 1
  DESC_OFFSET_SUBTYPE* = 2
  INTERFACE_INVALID_NUMBER* = 0xff

type

  microsoft_os_20_type_t* {.size: sizeof(cint).} = enum
    MS_OS_20_SET_HEADER_DESCRIPTOR = 0x00,
    MS_OS_20_SUBSET_HEADER_CONFIGURATION = 0x01,
    MS_OS_20_SUBSET_HEADER_FUNCTION = 0x02,
    MS_OS_20_FEATURE_COMPATBLE_ID = 0x03, MS_OS_20_FEATURE_REG_PROPERTY = 0x04,
    MS_OS_20_FEATURE_MIN_RESUME_TIME = 0x05, MS_OS_20_FEATURE_MODEL_ID = 0x06,
    MS_OS_20_FEATURE_CCGP_DEVICE = 0x07, MS_OS_20_FEATURE_VENDOR_REVISION = 0x08

const
  CONTROL_STAGE_IDLE* = 0
  CONTROL_STAGE_SETUP* = 1   ##  1
  CONTROL_STAGE_DATA* = 2    ##  2
  CONTROL_STAGE_ACK* = 3     ##  3
  TUSB_INDEX_INVALID_8* = 0xFF

type

  tusb_rhport_init_t* {.importc: "tusb_rhport_init_t", header: hdr,
                        bycopy.} = object ## --------------------------------------------------------------------+
                                           ##
                                           ## --------------------------------------------------------------------+
    role* {.importc: "role".}: tusb_role_t
    speed* {.importc: "speed".}: tusb_speed_t


  tusb_desc_device_t* {.importc: "tusb_desc_device_t", header: hdr,
                        bycopy.} = object ## --------------------------------------------------------------------+
                                           ##  USB Descriptors
                                           ## --------------------------------------------------------------------+
                                           ##  Start of all packed definitions for compiler without per-type packed
                                           ##  USB Device Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of this descriptor in bytes.
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < DEVICE Descriptor Type.
    bcdUSB* {.importc: "bcdUSB".}: uint16 ## < BUSB Specification Release Number in Binary-Coded Decimal (i.e., 2.10 is 210H).
    bDeviceClass* {.importc: "bDeviceClass".}: uint8 ##
                              ## < Class code (assigned by the USB-IF).
    bDeviceSubClass* {.importc: "bDeviceSubClass".}: uint8 ##
                              ## < Subclass code (assigned by the USB-IF).
    bDeviceProtocol* {.importc: "bDeviceProtocol".}: uint8 ##
                              ## < Protocol code (assigned by the USB-IF).
    bMaxPacketSize0* {.importc: "bMaxPacketSize0".}: uint8 ##
                              ## < Maximum packet size for endpoint zero (only 8, 16, 32, or 64 are valid). For HS devices is fixed to 64.
    idVendor* {.importc: "idVendor".}: uint16 ## < Vendor ID (assigned by the USB-IF).
    idProduct* {.importc: "idProduct".}: uint16 ## < Product ID (assigned by the manufacturer).
    bcdDevice* {.importc: "bcdDevice".}: uint16 ## < Device release number in binary-coded decimal.
    iManufacturer* {.importc: "iManufacturer".}: uint8 ##
                              ## < Index of string descriptor describing manufacturer.
    iProduct* {.importc: "iProduct".}: uint8 ## < Index of string descriptor describing product.
    iSerialNumber* {.importc: "iSerialNumber".}: uint8 ##
                              ## < Index of string descriptor describing the device's serial number.
    bNumConfigurations* {.importc: "bNumConfigurations".}: uint8
    ## < Number of possible configurations.


type

  tusb_desc_bos_t* {.importc: "tusb_desc_bos_t", header: hdr, bycopy.} = object ##
                              ##  USB Binary Device Object Store (BOS) Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of this descriptor in bytes
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < CONFIGURATION Descriptor Type
    wTotalLength* {.importc: "wTotalLength".}: uint16 ##
                              ## < Total length of data returned for this descriptor
    bNumDeviceCaps* {.importc: "bNumDeviceCaps".}: uint8
    ## < Number of device capability descriptors in the BOS


type

  tusb_desc_configuration_t* {.importc: "tusb_desc_configuration_t",
                               header: hdr, bycopy.} = object ##
                              ##  USB Configuration Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of this descriptor in bytes
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < CONFIGURATION Descriptor Type
    wTotalLength* {.importc: "wTotalLength".}: uint16 ##
                              ## < Total length of data returned for this configuration. Includes the combined length of all descriptors (configuration, interface, endpoint, and class- or vendor-specific) returned for this configuration.
    bNumInterfaces* {.importc: "bNumInterfaces".}: uint8 ##
                              ## < Number of interfaces supported by this configuration
    bConfigurationValue* {.importc: "bConfigurationValue".}: uint8 ##
                              ## < Value to use as an argument to the SetConfiguration() request to select this configuration.
    iConfiguration* {.importc: "iConfiguration".}: uint8 ##
                              ## < Index of string descriptor describing this configuration
    bmAttributes* {.importc: "bmAttributes".}: uint8 ##
                              ## < Configuration characteristics \n D7: Reserved (set to one)\n D6: Self-powered \n D5: Remote Wakeup \n D4...0: Reserved (reset to zero) \n D7 is reserved and must be set to one for historical reasons. \n A device configuration that uses power from the bus and a local source reports a non-zero value in bMaxPower to indicate the amount of bus power required and sets D6. The actual power source at runtime may be determined using the GetStatus(DEVICE) request (see USB 2.0 spec Section 9.4.5). \n If a device configuration supports remote wakeup, D5 is set to one.
    bMaxPower* {.importc: "bMaxPower".}: uint8
    ## < Maximum power consumption of the USB device from the bus in this specific configuration when the device is fully operational. Expressed in 2 mA units (i.e., 50 = 100 mA).


type

  tusb_desc_interface_t* {.importc: "tusb_desc_interface_t",
                           header: hdr, bycopy.} = object ##
                              ##  USB Interface Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of this descriptor in bytes
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < INTERFACE Descriptor Type
    bInterfaceNumber* {.importc: "bInterfaceNumber".}: uint8 ##
                              ## < Number of this interface. Zero-based value identifying the index in the array of concurrent interfaces supported by this configuration.
    bAlternateSetting* {.importc: "bAlternateSetting".}: uint8 ##
                              ## < Value used to select this alternate setting for the interface identified in the prior field
    bNumEndpoints* {.importc: "bNumEndpoints".}: uint8 ##
                              ## < Number of endpoints used by this interface (excluding endpoint zero). If this value is zero, this interface only uses the Default Control Pipe.
    bInterfaceClass* {.importc: "bInterfaceClass".}: uint8 ##
                              ## < Class code (assigned by the USB-IF). \li A value of zero is reserved for future standardization. \li If this field is set to FFH, the interface class is vendor-specific. \li All other values are reserved for assignment by the USB-IF.
    bInterfaceSubClass* {.importc: "bInterfaceSubClass".}: uint8 ##
                              ## < Subclass code (assigned by the USB-IF). \n These codes are qualified by the value of the bInterfaceClass field. \li If the bInterfaceClass field is reset to zero, this field must also be reset to zero. \li If the bInterfaceClass field is not set to FFH, all values are reserved for assignment by the USB-IF.
    bInterfaceProtocol* {.importc: "bInterfaceProtocol".}: uint8 ##
                              ## < Protocol code (assigned by the USB). \n These codes are qualified by the value of the bInterfaceClass and the bInterfaceSubClass fields. If an interface supports class-specific requests, this code identifies the protocols that the device uses as defined by the specification of the device class. \li If this field is reset to zero, the device does not use a class-specific protocol on this interface. \li If this field is set to FFH, the device uses a vendor-specific protocol for this interface.
    iInterface* {.importc: "iInterface".}: uint8
    ## < Index of string descriptor describing this interface


type

  TU_ATTR_PACKED_tusb_types_1* {.importc: "tusb_desc_endpoint_t::no_name",
                                 header: hdr, bycopy.} = object ##
                              ##  USB Endpoint Descriptor
    xfer* {.importc: "xfer", bitsize: 2.}: uint8 ##  Control, ISO, Bulk, Interrupt
    sync* {.importc: "sync", bitsize: 2.}: uint8 ##  None, Asynchronous, Adaptive, Synchronous
    usage* {.importc: "usage", bitsize: 2.}: uint8
    ##  Data, Feedback, Implicit feedback


  tusb_desc_endpoint_t* {.importc: "tusb_desc_endpoint_t",
                          header: hdr, bycopy.} = object
    bLength* {.importc: "bLength".}: uint8 ##  Size of this descriptor in bytes
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ##  ENDPOINT Descriptor Type
    bEndpointAddress* {.importc: "bEndpointAddress".}: uint8 ##
                              ##  The address of the endpoint
    bmAttributes* {.importc: "bmAttributes".}: TU_ATTR_PACKED_tusb_types_1
    wMaxPacketSize* {.importc: "wMaxPacketSize".}: uint16 ##
                              ##  Bit 10..0 : max packet size, bit 12..11 additional transaction per highspeed micro-frame
    bInterval* {.importc: "bInterval".}: uint8
    ##  Polling interval, in frames or microframes depending on the operating speed


type

  tusb_desc_other_speed_t* {.importc: "tusb_desc_other_speed_t",
                             header: hdr, bycopy.} = object ##
                              ##  USB Other Speed Configuration Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of descriptor
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < Other_speed_Configuration Type
    wTotalLength* {.importc: "wTotalLength".}: uint16 ##
                              ## < Total length of data returned
    bNumInterfaces* {.importc: "bNumInterfaces".}: uint8 ##
                              ## < Number of interfaces supported by this speed configuration
    bConfigurationValue* {.importc: "bConfigurationValue".}: uint8 ##
                              ## < Value to use to select configuration
    iConfiguration* {.importc: "iConfiguration".}: uint8 ##
                              ## < Index of string descriptor
    bmAttributes* {.importc: "bmAttributes".}: uint8 ##
                              ## < Same as Configuration descriptor
    bMaxPower* {.importc: "bMaxPower".}: uint8
    ## < Same as Configuration descriptor


  tusb_desc_device_qualifier_t* {.importc: "tusb_desc_device_qualifier_t",
                                  header: hdr, bycopy.} = object ##
                              ##  USB Device Qualifier Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of descriptor
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < Device Qualifier Type
    bcdUSB* {.importc: "bcdUSB".}: uint16 ## < USB specification version number (e.g., 0200H for V2.00)
    bDeviceClass* {.importc: "bDeviceClass".}: uint8 ##
                              ## < Class Code
    bDeviceSubClass* {.importc: "bDeviceSubClass".}: uint8 ##
                              ## < SubClass Code
    bDeviceProtocol* {.importc: "bDeviceProtocol".}: uint8 ##
                              ## < Protocol Code
    bMaxPacketSize0* {.importc: "bMaxPacketSize0".}: uint8 ##
                              ## < Maximum packet size for other speed
    bNumConfigurations* {.importc: "bNumConfigurations".}: uint8 ##
                              ## < Number of Other-speed Configurations
    bReserved* {.importc: "bReserved".}: uint8
    ## < Reserved for future use, must be zero



type

  tusb_desc_interface_assoc_t* {.importc: "tusb_desc_interface_assoc_t",
                                 header: hdr, bycopy.} = object ##
                              ##  USB Interface Association Descriptor (IAD ECN)
    bLength* {.importc: "bLength".}: uint8 ## < Size of descriptor
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < Other_speed_Configuration Type
    bFirstInterface* {.importc: "bFirstInterface".}: uint8 ##
                              ## < Index of the first associated interface.
    bInterfaceCount* {.importc: "bInterfaceCount".}: uint8 ##
                              ## < Total number of associated interfaces.
    bFunctionClass* {.importc: "bFunctionClass".}: uint8 ##
                              ## < Interface class ID.
    bFunctionSubClass* {.importc: "bFunctionSubClass".}: uint8 ##
                              ## < Interface subclass ID.
    bFunctionProtocol* {.importc: "bFunctionProtocol".}: uint8 ##
                              ## < Interface protocol ID.
    iFunction* {.importc: "iFunction".}: uint8
    ## < Index of the string descriptor describing the interface association.


type

  tusb_desc_string_t* {.importc: "tusb_desc_string_t", header: hdr,
                        bycopy.} = object ##  USB String Descriptor
    bLength* {.importc: "bLength".}: uint8 ## < Size of this descriptor in bytes
    bDescriptorType* {.importc: "bDescriptorType".}: uint8 ##
                              ## < Descriptor Type
    utf16le* {.importc: "utf16le".}: UncheckedArray[uint16]


  tusb_desc_bos_platform_t* {.importc: "tusb_desc_bos_platform_t",
                              header: hdr, bycopy.} = object ##
                              ##  USB Binary Device Object Store (BOS)
    bLength* {.importc: "bLength".}: uint8
    bDescriptorType* {.importc: "bDescriptorType".}: uint8
    bDevCapabilityType* {.importc: "bDevCapabilityType".}: uint8
    bReserved* {.importc: "bReserved".}: uint8
    PlatformCapabilityUUID* {.importc: "PlatformCapabilityUUID".}: array[16,
        uint8]
    CapabilityData* {.importc: "CapabilityData".}: UncheckedArray[uint8]


  tusb_desc_webusb_url_t* {.importc: "tusb_desc_webusb_url_t",
                            header: hdr, bycopy.} = object ##
                              ##  USB WebUSB URL Descriptor
    bLength* {.importc: "bLength".}: uint8
    bDescriptorType* {.importc: "bDescriptorType".}: uint8
    bScheme* {.importc: "bScheme".}: uint8
    url* {.importc: "url".}: UncheckedArray[char]


  TU_ATTR_PACKED_tusb_types_5* {.importc: "tusb_desc_dfu_functional_t::no_name",
                                 header: hdr, bycopy.} = object ##
                              ##  DFU Functional Descriptor
    bitCanDnload* {.importc: "bitCanDnload", bitsize: 1.}: uint8
    bitCanUpload* {.importc: "bitCanUpload", bitsize: 1.}: uint8
    bitManifestationTolerant* {.importc: "bitManifestationTolerant", bitsize: 1.}: uint8
    bitWillDetach* {.importc: "bitWillDetach", bitsize: 1.}: uint8
    reserved* {.importc: "reserved", bitsize: 4.}: uint8


  tusb_desc_dfu_functional_t* {.importc: "tusb_desc_dfu_functional_t",
                                header: hdr, bycopy.} = object
    bLength* {.importc: "bLength".}: uint8
    bDescriptorType* {.importc: "bDescriptorType".}: uint8
    bmAttributes* {.importc: "bmAttributes".}: TU_ATTR_PACKED_tusb_types_5
    bAttributes* {.importc: "bAttributes".}: uint8
    wDetachTimeOut* {.importc: "wDetachTimeOut".}: uint16
    wTransferSize* {.importc: "wTransferSize".}: uint16
    bcdDFUVersion* {.importc: "bcdDFUVersion".}: uint16


  TU_ATTR_PACKED_tusb_types_9* {.importc: "tusb_control_request_t::no_name",
                                 header: hdr, bycopy.} = object ##
                              ## --------------------------------------------------------------------+
                              ##
                              ## --------------------------------------------------------------------+
    recipient* {.importc: "recipient", bitsize: 5.}: uint8 ##
                              ## < Recipient type tusb_request_recipient_t.
    `type`* {.importc: "type", bitsize: 2.}: uint8 ##
                              ## < Request type tusb_request_type_t.
    direction* {.importc: "direction", bitsize: 1.}: uint8
    ## < Direction type. tusb_dir_t


  tusb_control_request_t* {.importc: "tusb_control_request_t",
                            header: hdr, bycopy.} = object
    bmRequestType_bit* {.importc: "bmRequestType_bit".}: TU_ATTR_PACKED_tusb_types_9
    bmRequestType* {.importc: "bmRequestType".}: uint8
    bRequest* {.importc: "bRequest".}: uint8
    wValue* {.importc: "wValue".}: uint16
    wIndex* {.importc: "wIndex".}: uint16
    wLength* {.importc: "wLength".}: uint16



proc tu_edpt_dir*(`addr`: uint8): tusb_dir_t {.inline, cdecl,
    importc: "tu_edpt_dir".}
  ## --------------------------------------------------------------------+
                            ##  Endpoint helper
                            ## --------------------------------------------------------------------+
                            ##  Get direction from Endpoint address

proc tu_edpt_number*(`addr`: uint8): uint8 {.inline, cdecl,
    importc: "tu_edpt_number".}
  ##  Get Endpoint number from address

proc tu_edpt_addr*(num: uint8; dir: uint8): uint8 {.inline, cdecl,
    importc: "tu_edpt_addr".}

proc tu_edpt_packet_size*(desc_ep: ptr tusb_desc_endpoint_t): uint16 {.inline,
    cdecl, importc: "tu_edpt_packet_size".}

proc tu_edpt_type_str*(t: tusb_xfer_type_t): cstring {.inline, cdecl,
    importc: "tu_edpt_type_str".}

proc tu_desc_next*(desc: pointer): ptr uint8 {.inline, cdecl, importc: "tu_desc_next".}
  ## --------------------------------------------------------------------+
                             ##  Descriptor helper
                             ## --------------------------------------------------------------------+
                             ##  return next descriptor

proc tu_desc_len*(desc: pointer): uint8 {.inline, cdecl, importc: "tu_desc_len".}
  ##
                              ##  get descriptor length

proc tu_desc_type*(desc: pointer): uint8 {.inline, cdecl,
    importc: "tu_desc_type".}
  ##  get descriptor type

proc tu_desc_subtype*(desc: pointer): uint8 {.inline, cdecl,
    importc: "tu_desc_subtype".}
  ##  get descriptor subtype

proc tu_desc_find*(desc: ptr uint8; `end`: ptr uint8; byte1: uint8): ptr uint8 {.
    cdecl, importc: "tu_desc_find", header: hdr.}
  ##
                              ##  find descriptor that match byte1 (type)

proc tu_desc_find2*(desc: ptr uint8; `end`: ptr uint8; byte1: uint8;
                    byte2: uint8): ptr uint8 {.cdecl, importc: "tu_desc_find2",
    header: hdr.}
  ##  find descriptor that match byte1 (type) and byte2

proc tu_desc_find3*(desc: ptr uint8; `end`: ptr uint8; byte1: uint8;
                    byte2: uint8; byte3: uint8): ptr uint8 {.cdecl,
    importc: "tu_desc_find3", header: hdr.}
  ##
                              ##  find descriptor that match byte1 (type) and byte2