import nesper
import nesper/consts
import nesper/net_utils
import nesper/events
import nesper/wifi
import nesper/nvs
import nesper/tasks
import os

import server

# Get Password
const WIFI_SSID {.strdefine.}: string = "NOSSID"
const WIFI_PASSWORD  {.strdefine.}: string = "" 

# const CONFIG_EXAMPLE_WIFI_SSID = getEnv("WIFI_SSID")
# const CONFIG_EXAMPLE_WIFI_PASSWORD = getEnv("WIFI_PASSWORD")

const
  GOT_IPV4_BIT* = EventBits_t(BIT(0))
  CONNECTED_BITS* = (GOT_IPV4_BIT)

const TAG*: cstring = "example"
var sConnectEventGroup*: EventGroupHandle_t
var sIpAddr*: IpAddress
var sConnectionName*: cstring


proc ipReceivedHandler*(arg: pointer; event_base: esp_event_base_t; event_id: int32;
               event_data: pointer) {.cdecl.} =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)

  # echo "event.ip_info.ip: " & repr(event.ip_info.ip)
  sIpAddr = toIpAddress(event.ip_info.ip)
  # memcpy(addr(sIpAddr), addr(event.ip_info.ip), sizeof((sIpAddr)))
  discard xEventGroupSetBits(sConnectEventGroup, GOT_IPV4_BIT)

proc onWifiDisconnect*(arg: pointer;
                          event_base: esp_event_base_t;
                          event_id: int32;
                          event_data: pointer) {.cdecl.} =
  logi(TAG, "Wi-Fi disconnected, trying to reconnect...")
  check: esp_wifi_connect()

proc wifi_start*() =
  ##  set up connection, Wi-Fi or Ethernet
  let wcfg: wifi_init_config_t = wifi_init_config_default()

  discard esp_wifi_init(unsafeAddr(wcfg))

  WIFI_EVENT_STA_DISCONNECTED.eventRegister(onWifiDisconnect, nil)
  IP_EVENT_STA_GOT_IP.eventRegister(ipReceivedHandler, nil)

  check: esp_wifi_set_storage(WIFI_STORAGE_RAM)

  var wifi_config: wifi_config_t
  wifi_config.sta.ssid.setFromString(WIFI_SSID)
  wifi_config.sta.password.setFromString(WIFI_PASSWORD)

  logi(TAG, "Connecting to %s...", wifi_config.sta.ssid)
  check: esp_wifi_set_mode(WIFI_MODE_STA)
  check: esp_wifi_set_config(ESP_IF_WIFI_STA, addr(wifi_config))
  check: esp_wifi_start()
  check: esp_wifi_connect()

  sConnectionName = WIFI_SSID 

proc wifiStop*() =
  ##  tear down connection, release resources
  WIFI_EVENT_STA_DISCONNECTED.eventUnregister(onWifiDisconnect) 
  IP_EVENT_STA_GOT_IP.eventUnregister(ipReceivedHandler)

  check: esp_wifiStop()
  check: esp_wifi_deinit()

proc exampleConnect*(): esp_err_t =
  if sConnectEventGroup != nil:
    return ESP_ERR_INVALID_STATE

  sConnectEventGroup = xEventGroupCreate()

  wifi_start()
  discard xEventGroupWaitBits(sConnectEventGroup, CONNECTED_BITS, 1, 1, portMAX_DELAY)

  logi(TAG, "Connected to %s", sConnectionName)
  logi(TAG, "IPv4 address: %s", $sIpAddr)

  echo("run_http_server\n")
  run_http_server()

  return ESP_OK

proc exampleDisconnect*(): esp_err_t =
  if sConnectEventGroup == nil:
    return ESP_ERR_INVALID_STATE

  vEventGroupDelete(sConnectEventGroup)
  sConnectEventGroup = nil

  wifiStop()
  logi(TAG, "Disconnected from %s", sConnectionName)
  sConnectionName = nil

  return ESP_OK

proc nim_app_main*() {.exportc.} =
  initNvs()
  tcpip_adapter_init()

  check: esp_event_loop_create_default()
  check: exampleConnect()

  ##  Register event handlers to stop the server when Wi-Fi or Ethernet is disconnected,
  ##  and re-start it upon connection.
  ##
  IP_EVENT_STA_GOT_IP.eventRegister(ipReceivedHandler, nil)
  WIFI_EVENT_STA_DISCONNECTED.eventRegister(onWifiDisconnect,nil)

  echo("wifi setup!\n")
  echo("Wait for wifi\n")
  # vTaskDelay(10000 div portTICK_PERIOD_MS)
