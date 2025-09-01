import nesper
import nesper/[general, events, wifi]
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/net_utils
import nesper/components/esp_tinyusb/tinyusb

const
  TAG* = "USB_NCM"
  WIFI_SSID {.strdefine.}: string = "NOSSID"
  WIFI_PASS {.strdefine.}: string = ""

# C includes and helper wrappers for TinyUSB NET and internal WiFi APIs
{.emit: """
#include <string.h>
#include "tinyusb.h"
#include "tinyusb_net.h"
#include "esp_private/wifi.h"

typedef esp_err_t (*nesper_ncm_recv_cb_t)(void *buffer, uint16_t len, void *ctx);
typedef void (*nesper_ncm_free_cb_t)(void *eb, void *ctx);

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

// Initialize NCM with provided callbacks and MAC address
esp_err_t nesper_tinyusb_net_init_bridge(tinyusb_usbdev_t dev,
                                         uint8_t mac_addr[6],
                                         nesper_ncm_recv_cb_t on_recv,
                                         nesper_ncm_free_cb_t free_tx_buf,
                                         void *user_ctx) {
  tinyusb_net_config_t cfg = {
    .on_recv_callback = on_recv,
    .free_tx_buffer = free_tx_buf,
    .user_context = user_ctx,
  };
  memcpy(cfg.mac_addr, mac_addr, 6);
  return tinyusb_net_init(dev, &cfg);
}

// Thin wrapper to expose send_sync
static inline esp_err_t nesper_tinyusb_net_send_sync(void *buffer, uint16_t len, void *eb, uint32_t timeout_ticks) {
  return tinyusb_net_send_sync(buffer, len, eb, timeout_ticks);
}

// WiFi internal helpers (signatures only, implemented by IDF)
esp_err_t esp_wifi_internal_tx(wifi_interface_t ifx, void *buffer, uint16_t len);
esp_err_t esp_wifi_internal_reg_rxcb(wifi_interface_t ifx, esp_wifi_rxcb_t rx_cb);
void esp_wifi_internal_free_rx_buffer(void *eb);
""".}

proc nesper_tinyusb_install_default(): esp_err_t {.cdecl, importc.}
proc nesper_tinyusb_net_init_bridge(dev: cint;
                                    mac: ptr uint8;
                                    on_recv: proc (buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.};
                                    free_tx: proc (eb: pointer; ctx: pointer) {.cdecl.};
                                    user_ctx: pointer): esp_err_t {.cdecl, importc.}
proc nesper_tinyusb_net_send_sync(buffer: pointer; len: uint16; eb: pointer; timeoutTicks: uint32): esp_err_t {.cdecl, importc.}

proc esp_wifi_internal_tx(ifx: wifi_interface_t; buffer: pointer; len: uint16): esp_err_t {.cdecl, importc.}
proc esp_wifi_internal_reg_rxcb(ifx: wifi_interface_t;
                                rx_cb: proc (buffer: pointer; len: uint16; eb: pointer): esp_err_t {.cdecl.}): esp_err_t {.cdecl, importc.}
proc esp_wifi_internal_free_rx_buffer(eb: pointer) {.cdecl, importc.}

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
  if nesper_tinyusb_net_send_sync(buffer, len, eb, portMAX_DELAY.uint32) != ESP_OK:
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
  check: nesper_tinyusb_install_default()

  var mac: array[6, uint8]
  check: esp_read_mac(addr mac[0], ESP_MAC_WIFI_STA)
  logi(TAG, "Network interface HW address: %02x:%02x:%02x:%02x:%02x:%02x",
       mac[0].int, mac[1].int, mac[2].int, mac[3].int, mac[4].int, mac[5].int)

  # Initialize TinyUSB NET class with callbacks and MAC
  check: nesper_tinyusb_net_init_bridge(0, addr mac[0], usbRecvCallback, wifiPktFree, addr sIsWifiConnected)

  logi(TAG, "WiFi initialization")
  check: startWifi(addr sIsWifiConnected)

  logi(TAG, "USB NCM and WiFi initialized and started")

