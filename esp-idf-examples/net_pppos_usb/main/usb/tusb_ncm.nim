import nesper
import nesper/[general, events, wifi]
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/net_utils
import nesper/components/esp_tinyusb/tinyusb
import nesper/consts
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "USB_NCM"
  WIFI_SSID {.strdefine.}: string = "NOSSID"
  WIFI_PASS {.strdefine.}: string = ""

# TinyUSB NET type/procs (no emit)
type
  tinyusb_net_config_t* {.importc: "tinyusb_net_config_t", header: "tinyusb_net.h", bycopy.} = object
    on_recv_callback* {.importc: "on_recv_callback".}: proc (buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.}
    free_tx_buffer* {.importc: "free_tx_buffer".}: proc (eb: pointer; ctx: pointer) {.cdecl.}
    user_context* {.importc: "user_context".}: pointer
    mac_addr* {.importc: "mac_addr".}: array[6, uint8]

proc tinyusb_net_init*(dev: tinyusb_usbdev_t; cfg: ptr tinyusb_net_config_t): esp_err_t {.cdecl, importc: "tinyusb_net_init", header: "tinyusb_net.h".}
proc tinyusb_net_send_sync*(buffer: pointer; len: uint16; eb: pointer; timeout_ticks: uint32): esp_err_t {.cdecl, importc: "tinyusb_net_send_sync", header: "tinyusb_net.h".}

# WiFi internal helpers (signatures only)
proc esp_wifi_internal_tx(ifx: wifi_interface_t; buffer: pointer; len: uint16): esp_err_t {.cdecl, importc: "esp_wifi_internal_tx", header: "esp_private/wifi.h".}
proc esp_wifi_internal_reg_rxcb(ifx: wifi_interface_t;
                                rx_cb: proc (buffer: pointer; len: uint16; eb: pointer): esp_err_t {.cdecl.}): esp_err_t {.cdecl, importc: "esp_wifi_internal_reg_rxcb", header: "esp_private/wifi.h".}
proc esp_wifi_internal_free_rx_buffer(eb: pointer) {.cdecl, importc: "esp_wifi_internal_free_rx_buffer", header: "esp_private/wifi.h".}

var sIsWifiConnected {.volatile.}: bool = false

# USB -> WiFi callback: forward received USB frame to WiFi TX when connected
proc usbRecvCallback(buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.} =
  let isConnected = cast[ptr bool](ctx)
  if isConnected[]:
    discard esp_wifi_internal_tx(WIFI_IF_STA, buffer, len)
  return ESP_OK

# Free WiFi RX buffer after USB send completes or on failure
proc wifiPktFree(eb: pointer; ctx: pointer) {.cdecl.} =
  esp_wifi_internal_free_rx_buffer(eb)

# WiFi -> USB path: send WiFi RX packet out over USB NCM
proc pktWifi2Usb(buffer: pointer; len: uint16; eb: pointer): esp_err_t {.cdecl.} =
  if tinyusb_net_send_sync(buffer, len, eb, portMAX_DELAY.uint32) != ESP_OK:
    esp_wifi_internal_free_rx_buffer(eb)
  return ESP_OK

# WiFi event handler to manage link and RX callback registration
proc wifiEventHandler(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  let isConnected = cast[ptr bool](arg)
  if event_base == WIFI_EVENT:
    if event_id == WIFI_EVENT_STA_DISCONNECTED.int32:
      logi(TAG, "WiFi STA disconnected")
      isConnected[] = false
      discard esp_wifi_internal_reg_rxcb(WIFI_IF_STA, nil)
      discard esp_wifi_connect()
    elif event_id == WIFI_EVENT_STA_CONNECTED.int32:
      logi(TAG, "WiFi STA connected")
      discard esp_wifi_internal_reg_rxcb(WIFI_IF_STA, pktWifi2Usb)
      isConnected[] = true

proc startWifi(isConnected: ptr bool): esp_err_t =
  check: esp_event_loop_create_default()

  var wcfg = wifi_init_config_default()
  check: esp_wifi_init(addr wcfg)
  check: esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, wifiEventHandler, cast[pointer](isConnected))
  check: esp_wifi_set_mode(WIFI_MODE_STA)
  check: esp_wifi_start()

  var wifiConfig: wifi_config_t
  wifiConfig.sta.ssid.setFromString(WIFI_SSID)
  wifiConfig.sta.password.setFromString(WIFI_PASS)
  check: esp_wifi_set_config(ESP_IF_WIFI_STA, addr wifiConfig)
  return esp_wifi_connect()

proc runUsbNcmBridge*() =
  # Initialize NVS (PHY calibration data)
  var ret = nvs_flash_init()
  if ret == ESP_ERR_NVS_NO_FREE_PAGES or ret == ESP_ERR_NVS_NEW_VERSION_FOUND:
    check: nvs_flash_erase()
    ret = nvs_flash_init()
  check: ret

  logi(TAG, "USB NCM device initialization")
  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  var mac: array[6, uint8]
  check: esp_read_mac(addr mac[0], ESP_MAC_WIFI_STA)
  logi(TAG, "Network interface HW address: %02x:%02x:%02x:%02x:%02x:%02x",
       mac[0].int, mac[1].int, mac[2].int, mac[3].int, mac[4].int, mac[5].int)

  # Initialize TinyUSB NET class with callbacks and MAC
  var ncfg: tinyusb_net_config_t
  ncfg.on_recv_callback = usbRecvCallback
  ncfg.free_tx_buffer = wifiPktFree
  ncfg.user_context = addr sIsWifiConnected
  for i in 0..5: ncfg.mac_addr[i] = mac[i]
  check: tinyusb_net_init(TINYUSB_USBDEV_0, addr ncfg)

  logi(TAG, "WiFi initialization")
  check: startWifi(addr sIsWifiConnected)

  logi(TAG, "USB NCM and WiFi initialized and started")
