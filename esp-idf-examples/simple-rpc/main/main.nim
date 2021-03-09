import nesper
import nesper/net_utils
import nesper/nvs_utils
import nesper/events
import nesper/wifi
import nesper/tasks
import os

import server

import setup_networking
when defined(ESP32_ETHERNET):
  import setup_eth
else:
  import setup_wifi

# const CONFIG_EXAMPLE_WIFI_SSID = getEnv("WIFI_SSID")
# const CONFIG_EXAMPLE_WIFI_PASSWORD = getEnv("WIFI_PASSWORD")

const TAG*: cstring = "main"

app_main():

  networkingStart() 

  # Other startup code
  # ...

  # Connect networking
  logi(TAG, "network setup!\n")
  check: networkConnect()

  echo("Wait done\n")
  # vTaskDelay(10000 div portTICK_PERIOD_MS)
