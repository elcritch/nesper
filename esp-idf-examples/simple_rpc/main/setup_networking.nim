import nesper

import nesper/net_utils
import nesper/nvs_utils
import nesper/events
import nesper/tasks

const
  GOT_IPV4_BIT* = EventBits_t(BIT(1))
  CONNECTED_BITS* = (GOT_IPV4_BIT)

var networkConnectEventGroup*: EventGroupHandle_t
var networkIpAddr*: IpAddress
var networkConnectionName*: cstring

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


template onNetworking*(code: untyped) =
  discard xEventGroupWaitBits(networkConnectEventGroup, CONNECTED_BITS, 1, 1, portMAX_DELAY)

  code
