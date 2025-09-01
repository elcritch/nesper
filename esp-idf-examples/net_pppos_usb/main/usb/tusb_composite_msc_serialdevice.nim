import nesper
import nesper/[general]
import nesper/esp/queue
import nesper/esp/esp_vfs_fat # for wl_handle_t and WL_INVALID_HANDLE
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "usb_composite"
  RXBufSz = 64
  BasePath = "/usb"

{.emit: """
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>
#include "esp_partition.h"
#include "wear_levelling/wear_levelling.h"
#include "tinyusb.h"
#include "tusb_cdc_acm.h"
#include "tusb_msc_storage.h"

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

// Init CDC-ACM with provided callbacks
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

// Init MSC storage on SPI flash and mount to base path
esp_err_t nesper_msc_init_and_mount_spiflash(wl_handle_t wl_handle, const char *base_path) {
  const tinyusb_msc_spiflash_config_t config_spi = { .wl_handle = wl_handle };
  esp_err_t err = tinyusb_msc_storage_init_spiflash(&config_spi);
  if (err != ESP_OK) return err;
  return tinyusb_msc_storage_mount(base_path);
}
""".}

proc nesper_tinyusb_install_default(): esp_err_t {.cdecl, importc.}
proc nesper_tinyusb_cdc_acm_init_default(usb_dev: cint; cdc_port: cint; rx_unread_buf_sz: csize_t;
                                         cb_rx, cb_line_state: proc (itf: cint; event: pointer) {.cdecl.}): esp_err_t {.cdecl, importc.}
proc nesper_msc_init_and_mount_spiflash(wl: wl_handle_t; basePath: cstring): esp_err_t {.cdecl, importc.}

proc esp_partition_find_first(ptype: uint8; psubtype: uint8; label: cstring): pointer {.cdecl, importc: "esp_partition_find_first", header: "esp_partition.h".}
proc wl_mount(partition: pointer; outHandle: ptr wl_handle_t): esp_err_t {.cdecl, importc: "wl_mount", header: "wear_levelling/wear_levelling.h".}

proc tinyusb_cdcacm_read(itf: cint; buf: ptr uint8; bufsize: csize_t; rx_size: ptr csize_t): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_read", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_queue(itf: cint; buf: ptr uint8; size: csize_t): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_write_queue", header: "tusb_cdc_acm.h".}
proc tinyusb_cdcacm_write_flush(itf: cint; timeout_ms: cint): esp_err_t {.cdecl, importc: "tinyusb_cdcacm_write_flush", header: "tusb_cdc_acm.h".}

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

proc onCdcLineState(itf: cint; event: pointer) {.cdecl.} =
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
  check: nesper_msc_init_and_mount_spiflash(wl, BasePath)
  fileOperations()

  logi(TAG, "USB Composite initialization")
  check: nesper_tinyusb_install_default()
  check: nesper_tinyusb_cdc_acm_init_default(0, 0, RXBufSz, onCdcRx, onCdcLineState)
  logi(TAG, "USB Composite initialization DONE")

  var msg: AppMessage
  while true:
    if xQueueReceive(appQueue, addr msg, portMAX_DELAY) == 1:
      if msg.bufLen > 0:
        logi(TAG, "Data from channel %d", msg.itf.int)
        discard tinyusb_cdcacm_write_queue(msg.itf.int, addr msg.buf[0], msg.bufLen)
        let err = tinyusb_cdcacm_write_flush(msg.itf.int, 0)
        if err != ESP_OK:
          loge(TAG, "CDC ACM write flush error: %s", esp_err_to_name(err))
