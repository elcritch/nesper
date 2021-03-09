import nesper
import nesper/net_utils
import nesper/nvs_utils
import nesper/events
import nesper/wifi
import nesper/tasks
import os

import server

when defined(ESP32_ETHERNET):
  import eth_setup
else:
  import wifi_setup

# const CONFIG_EXAMPLE_WIFI_SSID = getEnv("WIFI_SSID")
# const CONFIG_EXAMPLE_WIFI_PASSWORD = getEnv("WIFI_PASSWORD")

const TAG*: cstring = "main"

app_main():
  initNvs()

  when defined(ESP_IDF_V4_0):
    tcpip_adapter_init()
  else:
    # Initialize TCP/IP network interface (should be called only once in application)
    check: esp_netif_init()

  # Create default event loop that runs in background
  check: esp_event_loop_create_default()

  logi(TAG, "network setup!\n")
  check: networkConnect()

  ##  Register event handlers to stop the server when Wi-Fi or Ethernet is disconnected,
  ##  and re-start it upon connection.
  ##
  # IP_EVENT_STA_GOT_IP.eventRegister(ipReceivedHandler, nil)

  echo("Wait done\n")
  # vTaskDelay(10000 div portTICK_PERIOD_MS)
