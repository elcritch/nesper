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

const TAG: cstring = "Wifi Example"

const WIFI_CONNECTED = 1 shl 0
const WIFI_FAIL      = 1 shl 1

var sWifiEventGroup: EventGroupHandle_t
var sRetryNum = 0

proc eventHandler(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  logi(TAG, "Wifi Event Handler called: base: %s eventid: %s wifiEvent: %s ipEvent: %s",
              $event_base, $event_id, $(event_base == WIFI_EVENT), $(event_base == IP_EVENT))
  if event_base == WIFI_EVENT and wifi_event_t(event_id) == WIFI_EVENT_STA_START:
    discard esp_wifi_connect()
  elif event_base == WIFI_EVENT and wifi_event_t(event_id) == WIFI_EVENT_STA_DISCONNECTED:
    if sRetryNum < EXAMPLE_ESP_MAXIMUM_RETRY:
      discard esp_wifi_connect()
      inc sRetryNum
      loge(TAG, "retry to connect to the AP")
    else:
      discard xEventGroupSetBits(sWifiEventGroup, EventBits_t(WIFI_FAIL))
    loge(TAG, "Connect to the AP failed")
  elif event_base == IP_EVENT and ip_event_t(event_id) == IP_EVENT_STA_GOT_IP:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    logi(TAG, "Wifi Got IP: %s", $ev.ip_info.ip)
    sRetryNum = 0
    discard xEventGroupSetBits(sWifiEventGroup, EventBits_t(WIFI_CONNECTED))

proc wifiInitSta() =
  logw(TAG, "Wifi Init Sta starting...")
  sWifiEventGroup = xEventGroupCreate()

  check: esp_netif_init()

  check: esp_event_loop_create_default()
  let netif = esp_netif_create_default_wifi_sta()

  let cfg = WIFI_INIT_CONFIG_DEFAULT()
  check: esp_wifi_init(unsafeAddr cfg)

  # Register for all WIFI_EVENT IDs and for IP_EVENT_STA_GOT_IP
  var instance_any_id: esp_event_handler_instance_t
  var instance_got_ip: esp_event_handler_instance_t

  eventRegister(WIFI_EVENT,
                ESP_EVENT_ANY_ID.int32,
                eventHandler,
                nil, addr instance_any_id)
  eventRegister(IP_EVENT,
                ESP_EVENT_ANY_ID.int32,
                eventHandler,
                nil, addr instance_got_ip)

  var wifi_config: wifi_config_t
  wifi_config.sta.ssid.setFromString(EXAMPLE_ESP_WIFI_SSID)
  wifi_config.sta.password.setFromString(EXAMPLE_ESP_WIFI_PASS)
  wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA3_PSK
  wifi_config.sta.sae_pwe_h2e = WPA3_SAE_PWE_HUNT_AND_PECK
  wifi_config.sta.sae_h2e_identifier.setFromString("")

  check: esp_wifi_set_mode(WIFI_MODE_STA)
  check: esp_wifi_set_config(ESP_IF_WIFI_STA, addr wifi_config)
  check: esp_wifi_start()

  logw(TAG, "Wifi Init Sta finished.")

  logw(TAG, "Wifi Init Sta waiting for events...")
  let bits = xEventGroupWaitBits(sWifiEventGroup, EventBits_t(WIFI_CONNECTED or WIFI_FAIL), pdFALSE, pdFALSE, portMAX_DELAY)

  if (bits and EventBits_t(WIFI_CONNECTED)) != 0:
    logi(TAG, "connected to ap SSID:%s password:%s", EXAMPLE_ESP_WIFI_SSID, EXAMPLE_ESP_WIFI_PASS)
  elif (bits and EventBits_t(WIFI_FAIL)) != 0:
    logi(TAG, "Failed to connect to SSID:%s, password:%s", EXAMPLE_ESP_WIFI_SSID, EXAMPLE_ESP_WIFI_PASS)
  else:
    loge(TAG, "UNEXPECTED EVENT")

app_main():
  logw(TAG, "Running main app...")

  logi(TAG, "Initializing NVS...")
  initNVS()
  # var ret = nvs_flash_init()
  # if ret == ESP_ERR_NVS_NO_FREE_PAGES or ret == ESP_ERR_NVS_NEW_VERSION_FOUND:
  #   check: nvs_flash_erase()
  #   ret = nvs_flash_init()
  # check: ret

  when EXAMPLE_ESP_WIFI_SSID == "" or EXAMPLE_ESP_WIFI_PASS == "":
    {.error: "EXAMPLE_ESP_WIFI_SSID and EXAMPLE_ESP_WIFI_PASS are not set".}
  else:
    wifiInitSta()
  
  while true:
    echo "looping..."
    delayMillis(1000)
