import nesper
import nesper/[general]
import nesper/esp/queue
import nesper/esp/esp_vfs_fat # for wl_handle_t and WL_INVALID_HANDLE
import nesper/components/esp_tinyusb/tinyusb
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "usb_composite"
  RXBufSz = 64
  BasePath = "/usb"

## C stdlib and ESP-IDF imports needed by the example

proc esp_partition_find_first(ptype: uint8; psubtype: uint8; label: cstring): pointer {.cdecl, importc: "esp_partition_find_first", header: "esp_partition.h".}
proc wl_mount(partition: pointer; outHandle: ptr wl_handle_t): esp_err_t {.cdecl, importc: "wl_mount", header: "wear_levelling/wear_levelling.h".}

## TinyUSB CDC ACM from wrappers
proc tinyusb_cdcacm_read(itf: tinyusb_cdcacm_itf_t; buf: ptr uint8; bufsize: csize_t; rx_size: ptr csize_t): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_read", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_queue(itf: tinyusb_cdcacm_itf_t; buf: ptr uint8; size: csize_t): csize_t {.cdecl, importc: "tinyusb_cdcacm_write_queue", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_flush(itf: tinyusb_cdcacm_itf_t; timeout_ticks: uint32): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_write_flush", header: "tusb_cdc_acm.h".}

## TinyUSB MSC storage minimal imports (no emit)
type
  tinyusb_msc_spiflash_config_t* {.importc: "tinyusb_msc_spiflash_config_t", header: "tusb_msc_storage.h", bycopy.} = object
    wl_handle* {.importc: "wl_handle".}: wl_handle_t

proc tinyusb_msc_storage_init_spiflash*(cfg: ptr tinyusb_msc_spiflash_config_t): esp_err_t {.cdecl, importc: "tinyusb_msc_storage_init_spiflash", header: "tusb_msc_storage.h".}
proc tinyusb_msc_storage_mount*(base_path: cstring): esp_err_t {.cdecl, importc: "tinyusb_msc_storage_mount", header: "tusb_msc_storage.h".}

# C stdlib helpers used by the example file operations
type Stat* {.importc: "struct stat", header: "sys/stat.h", bycopy.} = object
proc stat*(path: cstring; st: ptr Stat): cint {.cdecl, importc: "stat", header: "sys/stat.h".}
proc mkdir*(path: cstring; mode: cint): cint {.cdecl, importc: "mkdir", header: "sys/stat.h".}
proc strerror*(errnum: cint): cstring {.cdecl, importc: "strerror", header: "string.h".}
proc fopen*(path, mode: cstring): pointer {.cdecl, importc: "fopen", header: "stdio.h".}
proc fprintf*(f: pointer; fmt: cstring): cint {.varargs, cdecl, importc: "fprintf", header: "stdio.h".}
proc fclose*(f: pointer): cint {.cdecl, importc: "fclose", header: "stdio.h".}
proc fgets*(s: cstring; n: cint; f: pointer): cstring {.cdecl, importc: "fgets", header: "stdio.h".}
proc strchr*(s: cstring; c: cint): cstring {.cdecl, importc: "strchr", header: "string.h".}
var errno* {.importc: "errno", header: "errno.h".}: cint

const
  ESP_PARTITION_TYPE_DATA* = 0x01'u8
  ESP_PARTITION_SUBTYPE_DATA_FAT* = 0x81'u8

type
  AppMessage = object
    buf: array[RXBufSz + 1, uint8]
    bufLen: csize_t
    itf: uint8

var
  appQueue: QueueHandle_t
  rxBuf {.volatile.}: array[RXBufSz + 1, uint8]

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

proc onCdcLineState(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  logi(TAG, "Line state changed on channel %d", itf)

proc fileExists(path: cstring): bool =
  var s: Stat
  result = stat(path, addr s) == 0

proc fileOperations() =
  let directory = "/usb/esp"
  let filePath = "/usb/esp/test.txt"

  var s: Stat
  let directoryExists = (stat(directory, addr s) == 0)
  if not directoryExists:
    if mkdir(directory, 0o775) != 0:
      loge(TAG, "mkdir failed: %s", strerror(errno))

  if not fileExists(filePath):
    logi(TAG, "Creating file")
    let f = fopen(filePath, "w")
    if f == nil:
      loge(TAG, "Failed to open file for writing")
      return
    discard fprintf(f, "Hello World!\n")
    discard fclose(f)

  logi(TAG, "Reading file")
  let f = fopen(filePath, "r")
  if f == nil:
    loge(TAG, "Failed to open file for reading")
    return
  var line: array[64, char]
  discard fgets(cast[cstring](addr line[0]), line.len.cint, f)
  discard fclose(f)
  var p = strchr(cast[cstring](addr line[0]), '\n'.int)
  if p != nil:
    p[] = '\0'
  logi(TAG, "Read from file: '%s'", cast[cstring](addr line[0]))

proc storageInitSpiFlash(wlOut: var wl_handle_t): esp_err_t =
  logi(TAG, "Initializing wear levelling")
  let part = esp_partition_find_first(ESP_PARTITION_TYPE_DATA, ESP_PARTITION_SUBTYPE_DATA_FAT, nil)
  if part == nil:
    loge(TAG, "Failed to find FATFS partition. Check the partition table.")
    return ESP_ERR_NOT_FOUND
  result = wl_mount(part, addr wlOut)

proc runUsbCompositeMscSerial*() =
  appQueue = xQueueCreate(UBaseType_t(5), UBaseType_t(sizeof(AppMessage)))
  assert appQueue != nil

  logi(TAG, "Initializing storage...")
  var wl: wl_handle_t = WL_INVALID_HANDLE
  check: storageInitSpiFlash(wl)
  var mscCfg: tinyusb_msc_spiflash_config_t
  mscCfg.wl_handle = wl
  check: tinyusb_msc_storage_init_spiflash(addr mscCfg)
  check: tinyusb_msc_storage_mount(BasePath)
  fileOperations()

  logi(TAG, "USB Composite initialization")
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
  logi(TAG, "USB Composite initialization DONE")

  var msg: AppMessage
  while true:
    if xQueueReceive(appQueue, addr msg, portMAX_DELAY) == 1:
      if msg.bufLen > 0:
        logi(TAG, "Data from channel %d", msg.itf.int)
        discard tinyusb_cdcacm_write_queue(tinyusb_cdcacm_itf_t(msg.itf.int), addr msg.buf[0], msg.bufLen)
        let err = tinyusb_cdcacm_write_flush(tinyusb_cdcacm_itf_t(msg.itf.int), 0)
        if err != ESP_OK:
          loge(TAG, "CDC ACM write flush error: %s", esp_err_to_name(err))
