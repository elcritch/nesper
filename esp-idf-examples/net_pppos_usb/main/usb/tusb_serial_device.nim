import nesper
import nesper/[general]
import nesper/esp/queue
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "usb_serial"
  RXBufSz = 64 # Match example default; align with Kconfig if changed

# C includes and tinyusb helper wrappers
{.emit: """
#include <stddef.h>
#include "tinyusb.h"
#include "tusb_cdc_acm.h"

// Install TinyUSB with default descriptors from Kconfig
esp_err_t nesper_tinyusb_install_default(void) {
  const tinyusb_config_t tusb_cfg = {
    .device_descriptor = NULL,
    .string_descriptor = NULL,
    .string_descriptor_count = 0,
    .external_phy = false,
#if (TUD_OPT_HIGH_SPEED)
    .fs_configuration_descriptor = NULL,
    .hs_configuration_descriptor = NULL,
    .qualifier_descriptor = NULL,
#else
    .configuration_descriptor = NULL,
#endif
  };
  return tinyusb_driver_install(&tusb_cfg);
}

// Init CDC-ACM port with provided callbacks
esp_err_t nesper_tinyusb_cdc_acm_init_default(tinyusb_usbdev_t usb_dev,
                                              tinyusb_cdcacm_itf_t cdc_port,
                                              size_t rx_unread_buf_sz,
                                              cdcacm_event_callback_t cb_rx,
                                              cdcacm_event_callback_t cb_line_state) {
  tinyusb_config_cdcacm_t acm_cfg = {
    .usb_dev = usb_dev,
    .cdc_port = cdc_port,
    .rx_unread_buf_sz = rx_unread_buf_sz,
    .callback_rx = cb_rx,
    .callback_rx_wanted_char = NULL,
    .callback_line_state_changed = cb_line_state,
    .callback_line_coding_changed = NULL,
  };
  return tusb_cdc_acm_init(&acm_cfg);
}
""".}

proc nesper_tinyusb_install_default(): esp_err_t {.cdecl, importc.}
proc nesper_tinyusb_cdc_acm_init_default(usb_dev: cint; cdc_port: cint; rx_unread_buf_sz: csize_t;
                                         cb_rx, cb_line_state: proc (itf: cint; event: pointer) {.cdecl.}): esp_err_t {.cdecl, importc.}

proc tinyusb_cdcacm_read(itf: cint; buf: ptr uint8; bufsize: csize_t; rx_size: ptr csize_t): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_read", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_queue(itf: cint; buf: ptr uint8; size: csize_t): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_write_queue", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_flush(itf: cint; timeout_ms: cint): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_write_flush", header: "tusb_cdc_acm.h".}

type
  AppMessage = object
    buf: array[RXBufSz + 1, uint8]
    bufLen: csize_t
    itf: uint8

var
  appQueue: QueueHandle_t
  rxBuf {.volatile.}: array[RXBufSz + 1, uint8]

# RX callback: read bytes and forward to application queue
proc onCdcRx(itf: cint; event: pointer) {.cdecl.} =
  var rxSize: csize_t = 0
  let ret = tinyusb_cdcacm_read(itf, addr rxBuf[0], RXBufSz.csize_t, addr rxSize)
  if ret == ESP_OK:
    var msg: AppMessage
    msg.bufLen = rxSize
    msg.itf = uint8(itf)
    if rxSize > 0 and rxSize <= RXBufSz.csize_t:
      copyMem(addr msg.buf[0], unsafeAddr rxBuf[0], rxSize)
    discard xQueueSendToBack(appQueue, addr msg, 0)
  else:
    loge(TAG, "Read Error")

# Line state change callback (log only)
proc onCdcLineState(itf: cint; event: pointer) {.cdecl.} =
  logi(TAG, "Line state changed on channel %d", itf)

proc runUsbSerialDevice*() =
  # Create queue for app messages
  appQueue = xQueueCreate(UBaseType_t(5), UBaseType_t(sizeof(AppMessage)))
  assert appQueue != nil

  logi(TAG, "USB initialization")
  check: nesper_tinyusb_install_default()
  check: nesper_tinyusb_cdc_acm_init_default(0, 0, RXBufSz, onCdcRx, onCdcLineState)

  logi(TAG, "USB initialization DONE")

  var msg: AppMessage
  while true:
    if xQueueReceive(appQueue, addr msg, portMAX_DELAY) == 1: # pdTRUE
      if msg.bufLen > 0:
        logi(TAG, "Data from channel %d", msg.itf.int)
        discard tinyusb_cdcacm_write_queue(msg.itf.int, addr msg.buf[0], msg.bufLen)
        let err = tinyusb_cdcacm_write_flush(msg.itf.int, 0)
        if err != ESP_OK:
          loge(TAG, "CDC ACM write flush error: %s", esp_err_to_name(err))

