import ../../consts

import ./tinyusb_types
import ./tusb_cdc_acm

# TinyUSB NET (NCM) imports
type
  tinyusb_net_config_t* {.importc: "tinyusb_net_config_t", header: "tinyusb_net.h", bycopy.} = object
    mac_addr* {.importc: "mac_addr".}: array[6, uint8]
    on_recv_callback* {.importc: "on_recv_callback".}: proc (buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.}
    free_tx_buffer* {.importc: "free_tx_buffer".}: proc (eb: pointer; ctx: pointer) {.cdecl.}
    on_init_callback* {.importc: "on_init_callback".}: proc (ctx: pointer) {.cdecl.}
    user_context* {.importc: "user_context".}: pointer

proc tinyusb_net_init*(dev: tinyusb_usbdev_t; cfg: ptr tinyusb_net_config_t): esp_err_t {.cdecl, importc: "tinyusb_net_init", header: "tinyusb_net.h".}
proc tinyusb_net_send_sync*(buffer: pointer; len: uint16; eb: pointer; timeout_ticks: uint32): esp_err_t {.cdecl, importc: "tinyusb_net_send_sync", header: "tinyusb_net.h".}

# tinyusb console helpers (not wrapped):
proc esp_tusb_init_console*(itf: tinyusb_cdcacm_itf_t): esp_err_t {.cdecl, importc: "esp_tusb_init_console", header: "tusb_console.h".}
proc esp_tusb_deinit_console*(itf: tinyusb_cdcacm_itf_t): esp_err_t {.cdecl, importc: "esp_tusb_deinit_console", header: "tusb_console.h".}