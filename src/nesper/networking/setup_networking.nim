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

template networkingInit*(
      startNvs=true,
      dhcp_client=true,
      dhcp_server=false,
      wifi_adapters=true,
      eth_adapters=true,
      test_adapters=true
    ) =

  # Networking will generally utilize NVS for storing net info
  # so it's best to start it first
  when startNvs == true:
    initNvs()

  # Initialize TCP/IP network interface (should be called only once in application)
  when defined(ESP_IDF_V4_0):
    tcpip_adapter_init()

    when dhcp_server:
      when wifi_adapters:
        check: tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_AP)
      when eth_adapters:
        check: tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_ETH)
      when test_adapters:
        check: tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_TEST)

    when dhcp_client:
      when wifi_adapters:
        check: tcpip_adapter_dhcpc_stop(TCPIP_ADAPTER_IF_STA)
      when eth_adapters:
        check: tcpip_adapter_dhcpc_stop(TCPIP_ADAPTER_IF_ETH)
      when test_adapters:
        check: tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_TEST)

  else:
    # Support for networking setup on ESP-IDF v4.1+ (v4.2+?)
    check: esp_netif_init()
    when dhcp_client:
      # check: tcpip_adapter_dhcps_stop(TCPIP_ADAPTER_IF_AP)
      # check: tcpip_adapter_dhcpc_stop(TCPIP_ADAPTER_IF_STA)
      discard "TODO: implement"


  # Create default event loop that runs in background
  check: esp_event_loop_create_default()


template onNetworking*(code: untyped) =
  discard xEventGroupWaitBits(networkConnectEventGroup, CONNECTED_BITS, 1, 1, portMAX_DELAY)

  code
