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


proc ethernetStart*(
      eth: EthernetType
    ) =
  networkConnectionName = "eth0" 

  check: tcpip_adapter_set_default_eth_handlers()

  ETH_EVENT.eventRegister(ESP_EVENT_ANY_ID, ethEventHandler)
  IP_EVENT.eventRegister(IP_EVENT_ETH_GOT_IP, ipReceivedHandler)

  # var
  #   mac_config: eth_mac_config_t = ETH_MAC_DEFAULT_CONFIG()
  #   phy_config: eth_phy_config_t = ETH_PHY_DEFAULT_CONFIG()

  # phy_config.phy_addr = EXAMPLE_ETH_PHY_ADDR
  # phy_config.reset_gpio_num = CONFIG_EXAMPLE_ETH_PHY_RST_GPIO

  when defined(CONFIG_EXAMPLE_USE_INTERNAL_ETHERNET):
    mac_config.smi_mdc_gpio_num = CONFIG_EXAMPLE_ETH_MDC_GPIO
    mac_config.smi_mdio_gpio_num = CONFIG_EXAMPLE_ETH_MDIO_GPIO

    var mac: ptr esp_eth_mac_t = esp_eth_mac_new_esp32(addr(mac_config))

    when CONFIG_EXAMPLE_ETH_PHY_IP101:
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_ip101(addr(phy_config))
    elif CONFIG_EXAMPLE_ETH_PHY_RTL8201:
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_rtl8201(addr(phy_config))
    elif CONFIG_EXAMPLE_ETH_PHY_LAN8720:
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_lan8720(addr(phy_config))
    elif CONFIG_EXAMPLE_ETH_PHY_DP83848:
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_dp83848(addr(phy_config))

  elif defined(ETHERNET_SPI):

    gpio_install_isr_service(0)
    var spi_handle: spi_device_handle_t = nil
    var buscfg: spi_bus_config_t = [miso_io_num: CONFIG_EXAMPLE_DM9051_MISO_GPIO,
                                mosi_io_num: CONFIG_EXAMPLE_DM9051_MOSI_GPIO,
                                sclk_io_num: CONFIG_EXAMPLE_DM9051_SCLK_GPIO,
                                quadwp_io_num: -1, quadhd_io_num: -1]
    check: spi_bus_initialize(CONFIG_EXAMPLE_DM9051_SPI_HOST,
                                       addr buscfg, 1)
    var devcfg: spi_device_interface_config_t = [command_bits: 1, address_bits: 7,
        mode: 0,
        clock_speed_hz: CONFIG_EXAMPLE_DM9051_SPI_CLOCK_MHZ * 1000 * 1000,
        spics_io_num: CONFIG_EXAMPLE_DM9051_CS_GPIO, queue_size: 20]

    check: spi_bus_add_device(CONFIG_EXAMPLE_DM9051_SPI_HOST,
                              addr devcfg, addr spi_handle)
    ##  dm9051 ethernet driver is based on spi driver
    var dm9051_config: eth_dm9051_config_t = ETH_DM9051_DEFAULT_CONFIG(spi_handle)
    dm9051_config.int_gpio_num = CONFIG_EXAMPLE_DM9051_INT_GPIO
    var mac: ptr esp_eth_mac_t = esp_eth_mac_new_dm9051(addr(dm9051_config),
        addr(mac_config))
    var phy: ptr esp_eth_phy_t = esp_eth_phy_new_dm9051(addr(phy_config))
  
  else:
    {.fatal: "compile this program with an ethernet type".}

  var config: esp_eth_config_t = ETH_DEFAULT_CONFIG(mac, phy)
  var eth_handle: esp_eth_handle_t = nil
  check: esp_eth_driver_install(addr(config), addr(eth_handle)))
  ESP_ERROR_CHECK(esp_eth_start(eth_handle)


proc ethernetStop*() =
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

