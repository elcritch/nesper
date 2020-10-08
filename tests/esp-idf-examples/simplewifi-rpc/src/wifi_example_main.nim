import nesper
import nesper/consts
import nesper/net_utils
import nesper/events

import nesper/esp/esp_event
import nesper/esp/event_groups
import nesper/esp/net/tcpip_adapter
import nesper/esp/net/esp_wifi
import nesper/esp/net/esp_wifi_types

#  array[33, uint8]
var CONFIG_EXAMPLE_WIFI_SSID {.importc: "CONFIG_EXAMPLE_WIFI_SSID".}: cstring 
var CONFIG_EXAMPLE_WIFI_PASSWORD {.importc: "CONFIG_EXAMPLE_WIFI_PASSWORD".}: cstring 

const
  GOT_IPV4_BIT* = EventBits_t(BIT(0))
  CONNECTED_BITS* = (GOT_IPV4_BIT)

var s_connect_event_group*: EventGroupHandle_t

var s_ip_addr*: IpAddress

var s_connection_name*: cstring

var TAG*: cstring = "example"

##  set up connection, Wi-Fi or Ethernet
proc start*()

##  tear down connection, release resources
proc stop*()

proc on_got_ip*(arg: pointer; event_base: esp_event_base_t; event_id: int32;
               event_data: pointer) {.cdecl.} =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)

  s_ip_addr = toIpAddress(event.ip_info.ip)
  # memcpy(addr(s_ip_addr), addr(event.ip_info.ip), sizeof((s_ip_addr)))
  discard xEventGroupSetBits(s_connect_event_group, GOT_IPV4_BIT)

proc example_connect*(): esp_err_t =
  if s_connect_event_group != nil:
    return ESP_ERR_INVALID_STATE

  s_connect_event_group = xEventGroupCreate()

  start()
  discard xEventGroupWaitBits(s_connect_event_group, CONNECTED_BITS, 1, 1, portMAX_DELAY)

  ESP_LOGI(TAG, "Connected to %s", s_connection_name)
  ESP_LOGI(TAG, "IPv4 address: ", $s_ip_addr)

  return ESP_OK

proc example_disconnect*(): esp_err_t =
  if s_connect_event_group == nil:
    return ESP_ERR_INVALID_STATE
  vEventGroupDelete(s_connect_event_group)
  s_connect_event_group = nil
  stop()
  ESP_LOGI(TAG, "Disconnected from %s", s_connection_name)
  s_connection_name = nil
  return ESP_OK

proc on_wifi_disconnect*(arg: pointer; event_base: esp_event_base_t;
                        event_id: int32; event_data: pointer) {.cdecl.} =
  ESP_LOGI(TAG, "Wi-Fi disconnected, trying to reconnect...")
  ESP_ERROR_CHECK(esp_wifi_connect())

proc start*() =
  var cfg: wifi_init_config_t = wifi_init_config_default()

  ESP_ERROR_CHECK esp_wifi_init(addr(cfg))
  ESP_ERROR_CHECK WIFI_EVENT_STA_DISCONNECTED.eventRegister( on_wifi_disconnect, nil)
  ESP_ERROR_CHECK IP_EVENT_STA_GOT_IP.eventRegister(on_got_ip, nil)

  ESP_ERROR_CHECK esp_wifi_set_storage(WIFI_STORAGE_RAM)

  var wifi_config: wifi_config_t
  # copyMem(addr(wifi_config.sta.ssid[0]), CONFIG_EXAMPLE_WIFI_SSID, len(CONFIG_EXAMPLE_WIFI_SSID))
  # copyMem(addr(wifi_config.sta.password[0]), CONFIG_EXAMPLE_WIFI_PASSWORD, len(CONFIG_EXAMPLE_WIFI_PASSWORD))
  wifi_config.sta.ssid.setFromString(CONFIG_EXAMPLE_WIFI_SSID)
  wifi_config.sta.password.setFromString(CONFIG_EXAMPLE_WIFI_PASSWORD)

  ESP_LOGI(TAG, "Connecting to %s...", wifi_config.sta.ssid)
  ESP_ERROR_CHECK esp_wifi_set_mode(WIFI_MODE_STA)
  ESP_ERROR_CHECK esp_wifi_set_config(ESP_IF_WIFI_STA, addr(wifi_config))
  ESP_ERROR_CHECK esp_wifi_start()
  ESP_ERROR_CHECK esp_wifi_connect()

  s_connection_name = CONFIG_EXAMPLE_WIFI_SSID

proc stop*() =
  ESP_ERROR_CHECK eventUnregister(
      WIFI_EVENT_STA_DISCONNECTED,
      on_wifi_disconnect)

  ESP_ERROR_CHECK eventUnregister(
      IP_EVENT_STA_GOT_IP,
      on_got_ip)

  ESP_ERROR_CHECK esp_wifi_stop()
  ESP_ERROR_CHECK esp_wifi_deinit()

proc app_main*() =
  ESP_ERROR_CHECK(nvs_flash_init())
  tcpip_adapter_init()
  ESP_ERROR_CHECK(esp_event_loop_create_default())
  ESP_ERROR_CHECK(example_connect())
  ##  Register event handlers to stop the server when Wi-Fi or Ethernet is disconnected,
  ##  and re-start it upon connection.
  ##
  ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP,
      addr(on_got_ip), nil))
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT,
      WIFI_EVENT_STA_DISCONNECTED, addr(on_wifi_disconnect), nil))
  echo("wifi setup!\n")
  vTaskDelay(10000 div portTICK_PERIOD_MS)
  echo("Wait for wifi\n")
  NimMain()
  echo("NimMain!\n")
  # run_http_server()
  echo("run_http_server\n")
