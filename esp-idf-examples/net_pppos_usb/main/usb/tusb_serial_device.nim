import nesper
import nesper/[general]
import nesper/esp/queue
import nesper/components/esp_tinyusb/tinyusb
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "usb_serial"
  RXBufSz = 64 # Match example default; align with Kconfig if changed

# Use tinyusb wrappers from nesper/components/esp_tinyusb

type
  AppMessage = object
    buf: array[RXBufSz + 1, uint8]
    bufLen: csize_t
    itf: uint8

var
  appQueue: QueueHandle_t
  rxBuf {.volatile.}: array[RXBufSz + 1, uint8]

# RX callback: read bytes and forward to application queue
proc onCdcRx(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  var rxSize: csize_t = 0
  let ret = tinyusb_cdcacm_read(tinyusb_cdcacm_itf_t(itf), addr rxBuf[0], RXBufSz.csize_t, addr rxSize)
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
proc onCdcLineState(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  logi(TAG, "Line state changed on channel %d", itf)

proc runUsbSerialDevice*() =
  # Create queue for app messages
  appQueue = xQueueCreate(UBaseType_t(5), UBaseType_t(sizeof(AppMessage)))
  assert appQueue != nil

  logi(TAG, "USB initialization")
  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  var acmCfg: tinyusb_config_cdcacm_t
  acmCfg.usb_dev = TINYUSB_USBDEV_0
  acmCfg.cdc_port = TINYUSB_CDC_ACM_0
  acmCfg.rx_unread_buf_sz = RXBufSz
  acmCfg.callback_rx = onCdcRx
  acmCfg.callback_rx_wanted_char = nil
  acmCfg.callback_line_state_changed = onCdcLineState
  acmCfg.callback_line_coding_changed = nil
  check: tusb_cdc_acm_init(addr acmCfg)

  logi(TAG, "USB initialization DONE")

  var msg: AppMessage
  while true:
    if xQueueReceive(appQueue, addr msg, portMAX_DELAY) == 1: # pdTRUE
      if msg.bufLen > 0:
        logi(TAG, "Data from channel %d", msg.itf.int)
        discard tinyusb_cdcacm_write_queue(tinyusb_cdcacm_itf_t(msg.itf.int), addr msg.buf[0], msg.bufLen)
        let err = tinyusb_cdcacm_write_flush(tinyusb_cdcacm_itf_t(msg.itf.int), 0)
        if err != ESP_OK:
          loge(TAG, "CDC ACM write flush error: %s", esp_err_to_name(err))
