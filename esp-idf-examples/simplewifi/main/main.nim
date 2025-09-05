import nesper
import nesper/general
import nesper/timers
import nesper/events
import nesper/wifi
import nesper/net_utils
import nesper/esp/nvs
import nesper/esp/nvs_flash
import nesper/nvs_utils

# Config (match the C example names)
const EXAMPLE_ESP_WIFI_SSID* {.strdefine.}: string = ""
const EXAMPLE_ESP_WIFI_PASS* {.strdefine.}: string = ""
const EXAMPLE_ESP_MAXIMUM_RETRY* {.intdefine.}: int = 5

const TAG: cstring = "wifi station"

const WIFI_CONNECTED = 1 shl 0
const WIFI_FAIL      = 1 shl 1

var sWifiEventGroup: EventGroupHandle_t
var sRetryNum = 0

proc eventHandler(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  if event_base == WIFI_EVENT and wifi_event_t(event_id) == WIFI_EVENT_STA_START:
    discard esp_wifi_connect()
  elif event_base == WIFI_EVENT and wifi_event_t(event_id) == WIFI_EVENT_STA_DISCONNECTED:
    if sRetryNum < EXAMPLE_ESP_MAXIMUM_RETRY:
      discard esp_wifi_connect()
      inc sRetryNum
      logi(TAG, "retry to connect to the AP")
    else:
      discard xEventGroupSetBits(sWifiEventGroup, EventBits_t(WIFI_FAIL))
    logi(TAG, "connect to the AP fail")
  elif event_base == IP_EVENT and ip_event_t(event_id) == IP_EVENT_STA_GOT_IP:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    logi(TAG, "got ip: %s", $ev.ip_info.ip)
    sRetryNum = 0
    discard xEventGroupSetBits(sWifiEventGroup, EventBits_t(WIFI_CONNECTED))

proc wifiInitSta() =
  sWifiEventGroup = xEventGroupCreate()

  when defined(ESP_IDF_V4_0):
    tcpip_adapter_init()
  else:
    check: esp_netif_init()

  check: esp_event_loop_create_default()

  let cfg = wifi_init_config_default()
  check: esp_wifi_init(unsafeAddr cfg)

  # Register for all WIFI_EVENT IDs and for IP_EVENT_STA_GOT_IP
  check: esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID.cint, cast[esp_event_handler_t](eventHandler), nil, nil)
  check: esp_event_handler_instance_register(IP_EVENT, int32(IP_EVENT_STA_GOT_IP), cast[esp_event_handler_t](eventHandler), nil, nil)

  var wifi_config: wifi_config_t
  wifi_config.sta.ssid.setFromString(EXAMPLE_ESP_WIFI_SSID)
  wifi_config.sta.password.setFromString(EXAMPLE_ESP_WIFI_PASS)

  check: esp_wifi_set_mode(WIFI_MODE_STA)
  check: esp_wifi_set_config(ESP_IF_WIFI_STA, addr wifi_config)
  check: esp_wifi_start()

  logi(TAG, "wifi_init_sta finished.")

  let bits = xEventGroupWaitBits(sWifiEventGroup, EventBits_t(WIFI_CONNECTED or WIFI_FAIL), pdFALSE, pdFALSE, portMAX_DELAY)

  if (bits and EventBits_t(WIFI_CONNECTED)) != 0:
    logi(TAG, "connected to ap SSID:%s password:%s", EXAMPLE_ESP_WIFI_SSID, EXAMPLE_ESP_WIFI_PASS)
  elif (bits and EventBits_t(WIFI_FAIL)) != 0:
    logi(TAG, "Failed to connect to SSID:%s, password:%s", EXAMPLE_ESP_WIFI_SSID, EXAMPLE_ESP_WIFI_PASS)
  else:
    loge(TAG, "UNEXPECTED EVENT")

app_main():
  logi(TAG, "Running main app...")

  logi(TAG, "Initializing NVS...")
  initNVS()
  # var ret = nvs_flash_init()
  # if ret == ESP_ERR_NVS_NO_FREE_PAGES or ret == ESP_ERR_NVS_NEW_VERSION_FOUND:
  #   check: nvs_flash_erase()
  #   ret = nvs_flash_init()
  # check: ret

  logi(TAG, "ESP_WIFI_MODE_STA")
  when EXAMPLE_ESP_WIFI_SSID == "" or EXAMPLE_ESP_WIFI_PASS == "":
    {.error: "EXAMPLE_ESP_WIFI_SSID and EXAMPLE_ESP_WIFI_PASS are not set".}
  else:
    wifiInitSta()
  
  while true:
    echo "looping..."
    delayMillis(1000)
