import nesper
import nesper/esp/event_groups

const
  GOT_IPV4_BIT* = BIT(0)
  CONNECTED_BITS* = (GOT_IPV4_BIT)

var s_connect_event_group*: EventGroupHandle_t

var s_ip_addr*: ip4_addr_t

var s_connection_name*: cstring

var TAG*: cstring = "example"

##  set up connection, Wi-Fi or Ethernet

proc start*()
##  tear down connection, release resources

proc stop*()
proc on_got_ip*(arg: pointer; event_base: esp_event_base_t; event_id: int32_t;
               event_data: pointer) =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)
  memcpy(addr(s_ip_addr), addr(event.ip_info.ip), sizeof((s_ip_addr)))
  xEventGroupSetBits(s_connect_event_group, GOT_IPV4_BIT)

proc example_connect*(): esp_err_t =
  if s_connect_event_group != nil:
    return ESP_ERR_INVALID_STATE
  s_connect_event_group = xEventGroupCreate()
  start()
  xEventGroupWaitBits(s_connect_event_group, CONNECTED_BITS, true, true,
                      portMAX_DELAY)
  ESP_LOGI(TAG, "Connected to %s", s_connection_name)
  ESP_LOGI(TAG, "IPv4 address: ", IPSTR, IP2STR(addr(s_ip_addr)))
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
                        event_id: int32_t; event_data: pointer) =
  ESP_LOGI(TAG, "Wi-Fi disconnected, trying to reconnect...")
  ESP_ERROR_CHECK(esp_wifi_connect())

proc start*() =
  var cfg: wifi_init_config_t = WIFI_INIT_CONFIG_DEFAULT()
  ESP_ERROR_CHECK(esp_wifi_init(addr(cfg)))
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT,
      WIFI_EVENT_STA_DISCONNECTED, addr(on_wifi_disconnect), nil))
  ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP,
      addr(on_got_ip), nil))
  ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM))
  var wifi_config: wifi_config_t
  wifi_config.sta.ssid = CONFIG_EXAMPLE_WIFI_SSID
  wifi_config.sta.password = CONFIG_EXAMPLE_WIFI_PASSWORD
  ESP_LOGI(TAG, "Connecting to %s...", wifi_config.sta.ssid)
  ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA))
  ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, addr(wifi_config)))
  ESP_ERROR_CHECK(esp_wifi_start())
  ESP_ERROR_CHECK(esp_wifi_connect())
  s_connection_name = CONFIG_EXAMPLE_WIFI_SSID

proc stop*() =
  ESP_ERROR_CHECK(esp_event_handler_unregister(WIFI_EVENT,
      WIFI_EVENT_STA_DISCONNECTED, addr(on_wifi_disconnect)))
  ESP_ERROR_CHECK(esp_event_handler_unregister(IP_EVENT, IP_EVENT_STA_GOT_IP,
      addr(on_got_ip)))
  ESP_ERROR_CHECK(esp_wifi_stop())
  ESP_ERROR_CHECK(esp_wifi_deinit())

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
