import nesper
import nesper/net_utils
import nesper/nvs_utils
import nesper/events
import nesper/wifi
import nesper/tasks
import os

import server

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
  check:
    networkingConnect()

  # Connect networking
  onNetworking():
    logi(TAG, "Connected to %s", networkConnectionName)
    logi(TAG, "IPv4 address: %s", $$networkIpAddr)
    logi(TAG, "network setup!\n")
    run_server()

  # turn off networking 
  check:
    networkingDisconnect()

  assert false, "shouldn't reach here!"
