import nesper

import nesper/nvs_utils
import nesper/events
import nesper/tasks

proc networkingStart*(startNvs=true) =

  # Networking will generally utilize NVS for storing net info
  # so it's best to start it first
  if startNvs:
    initNvs()

  # Initialize TCP/IP network interface (should be called only once in application)
  when defined(ESP_IDF_V4_0):
    tcpip_adapter_init()
  else:
    check: esp_netif_init()

  # Create default event loop that runs in background
  check: esp_event_loop_create_default()

