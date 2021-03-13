import nesper
import nesper/net_utils
import nesper/nvs_utils
import nesper/events
import nesper/wifi
import nesper/tasks
import os

import server

import setup_networking
export setup_networking

# Get Password
const WIFI_SSID {.strdefine.}: string = "NOSSID"
const WIFI_PASS  {.strdefine.}: string = "" 

# const CONFIG_EXAMPLE_WIFI_SSID = getEnv("WIFI_SSID")
# const CONFIG_EXAMPLE_WIFI_PASSWORD = getEnv("WIFI_PASSWORD")

const TAG*: cstring = "wifi"

proc ipReceivedHandler*(arg: pointer; event_base: esp_event_base_t; event_id: int32;
              event_data: pointer) {.cdecl.} =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)
  logi TAG, "event.ip_info.ip: %s", $$(event.ip_info.ip)

  networkIpAddr = toIpAddress(event.ip_info.ip)
  # memcpy(addr(sIpAddr), addr(event.ip_info.ip), sizeof((sIpAddr)))
  logw TAG, "got event ip: %s", $$networkIpAddr
  discard xEventGroupSetBits(networkConnectEventGroup, GOT_IPV4_BIT)

proc onWifiDisconnect*(arg: pointer;
                          event_base: esp_event_base_t;
                          event_id: int32;
                          event_data: pointer) {.cdecl.} =
  logi(TAG, "Wi-Fi disconnected, trying to reconnect...")
  check: esp_wifi_connect()

proc wifiStart*() =
  ##  set up connection, Wi-Fi or Ethernet
  let wcfg: wifi_init_config_t = wifi_init_config_default()

  discard esp_wifi_init(unsafeAddr(wcfg))

  WIFI_EVENT_STA_DISCONNECTED.eventRegister(onWifiDisconnect, nil)
  IP_EVENT_STA_GOT_IP.eventRegister(ipReceivedHandler, nil)

  check: esp_wifi_set_storage(WIFI_STORAGE_RAM)

  var wifi_config: wifi_config_t
  wifi_config.sta.ssid.setFromString(WIFI_SSID)
  wifi_config.sta.password.setFromString(WIFI_PASS)

  logi(TAG, "Connecting to %s...", wifi_config.sta.ssid)
  check: esp_wifi_set_mode(WIFI_MODE_STA)
  check: esp_wifi_set_config(ESP_IF_WIFI_STA, addr(wifi_config))
  check: esp_wifi_start()
  check: esp_wifi_connect()

  networkConnectionName = WIFI_SSID 

proc wifiStop*() =
  ##  tear down connection, release resources
  WIFI_EVENT_STA_DISCONNECTED.eventUnregister(onWifiDisconnect) 
  IP_EVENT_STA_GOT_IP.eventUnregister(ipReceivedHandler)

  check: esp_wifiStop()
  check: esp_wifi_deinit()

proc networkingConnect*(): esp_err_t =
  if networkConnectEventGroup != nil:
    return ESP_ERR_INVALID_STATE

  networkConnectEventGroup = xEventGroupCreate()

  wifiStart()

  # discard xEventGroupWaitBits(sConnectEventGroup, CONNECTED_BITS, 1, 1, portMAX_DELAY)


  # return ESP_OK

proc networkingDisconnect*(): esp_err_t =
  if networkConnectEventGroup == nil:
    return ESP_ERR_INVALID_STATE

  vEventGroupDelete(networkConnectEventGroup)
  networkConnectEventGroup = nil
  wifiStop()
  logi(TAG, "Disconnected from %s", networkConnectionName)
  networkConnectionName = nil

  return ESP_OK

