import nesper
import nesper/net_utils
import nesper/events
import nesper/tasks
import nesper/ethernet

import setup_networking
export setup_networking

# Get Password

# const CONFIG_EXAMPLE_WIFI_SSID = getEnv("WIFI_SSID")
# const CONFIG_EXAMPLE_WIFI_PASSWORD = getEnv("WIFI_PASSWORD")

const TAG*: cstring = "eth"

proc ipReceivedHandler*(arg: pointer; event_base: esp_event_base_t; event_id: int32;
              event_data: pointer) {.cdecl.} =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)
  TAG.logi "event.ip_info.ip: %s", $(event.ip_info.ip)

  networkIpAddr = toIpAddress(event.ip_info.ip)
  # memcpy(addr(sIpAddr), addr(event.ip_info.ip), sizeof((sIpAddr)))
  TAG.logw "got event ip: %s", $networkIpAddr

  # var ip_info: ptr tcpip_adapter_ip_info_t = addr(event.ip_info)
  # TAG.logi "Ethernet Got IP Address")
  # TAG.logi "~~~~~~~~~~~")
  # TAG.logi "ETHIP:", IPSTR, IP2STR(addr(ip_info.ip)))
  # TAG.logi "ETHMASK:", IPSTR, IP2STR(addr(ip_info.netmask)))
  # TAG.logi "ETHGW:", IPSTR, IP2STR(addr(ip_info.gw)))
  # TAG.logi "~~~~~~~~~~~")
  discard xEventGroupSetBits(networkConnectEventGroup, GOT_IPV4_BIT)

proc ethEventHandler*(arg: pointer; event_base: esp_event_base_t; event_id: int32;
              event_data: pointer) {.cdecl.} =

  ##  we can get the ethernet driver handle from event data
  var
    mac_addr: array[6, uint8]
    eth_handle: esp_eth_handle_t = cast[ptr esp_eth_handle_t](event_data)[]

  case eth_event_t(event_id)
  of ETHERNET_EVENT_CONNECTED:
    check: esp_eth_ioctl(eth_handle, ETH_CMD_G_MAC_ADDR, addr mac_addr[0])
    TAG.logi "Ethernet Link Up"
    TAG.logi "Ethernet HW Addr %02x:%02x:%02x:%02x:%02x:%02x", mac_addr[0],
             mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5]
  of ETHERNET_EVENT_DISCONNECTED:
    TAG.logi "Ethernet Link Down"
  of ETHERNET_EVENT_START:
    TAG.logi "Ethernet Started"
  of ETHERNET_EVENT_STOP:
    TAG.logi "Ethernet Stopped"
  else:
    discard

proc onEthernetDisconnect*(arg: pointer;
                          event_base: esp_event_base_t;
                          event_id: int32;
                          event_data: pointer) {.cdecl.} =
  logi(TAG, "ethernet disconnected")
  # check: esp_wifi_connect()


proc ethernetStart*[ET](eth: var ET) =
  networkConnectionName = "eth0" 

  check: tcpip_adapter_set_default_eth_handlers()

  ETH_EVENT.eventRegister(ESP_EVENT_ANY_ID, ethEventHandler)
  IP_EVENT.eventRegister(IP_EVENT_ETH_GOT_IP, ipReceivedHandler)

  var
    ethobj = eth.setupEthernet()
    config: esp_eth_config_t = eth_default_config(ethobj.mac, ethobj.phy)

  var eth_handle: esp_eth_handle_t = nil
  check: esp_eth_driver_install(addr(config), addr(eth_handle)))
  ESP_ERROR_CHECK(esp_eth_start(eth_handle)

proc ethernetStop*() =
  ##  tear down connection, release resources
  ETH_EVENT.eventUnregister(ESP_EVENT_ANY_ID, ethEventHandler)
  IP_EVENT.eventUnregister(IP_EVENT_ETH_GOT_IP, ipReceivedHandler)

  discard "TODO: fixme... how do we stop the ethernets?"

proc networkingConnect*(): esp_err_t =
  if networkConnectEventGroup != nil:
    return ESP_ERR_INVALID_STATE

  networkConnectEventGroup = xEventGroupCreate()
  ethernetStart()
  # discard xEventGroupWaitBits(sConnectEventGroup, CONNECTED_BITS, 1, 1, portMAX_DELAY)
  return ESP_OK

proc networkingDisconnect*(): esp_err_t =
  if networkConnectEventGroup == nil:
    return ESP_ERR_INVALID_STATE

  vEventGroupDelete(networkConnectEventGroup)
  networkConnectEventGroup = nil
  wifiStop()
  logi(TAG, "Disconnected from %s", networkConnectionName)
  networkConnectionName = nil

  return ESP_OK

