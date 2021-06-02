##  Ethernet Basic Example
##
##    This example code is in the Public Domain (or CC0 licensed, at your option.)
##
##    Unless required by applicable law or agreed to in writing, this
##    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.
##

import
  freertos/FreeRTOS, freertos/task, tcpip_adapter, esp_eth, esp_event, esp_log,
  driver/gpio, sdkconfig

var TAG*: cstring = "eth_example"

## * Event handler for Ethernet events

proc eth_event_handler*(arg: pointer; event_base: esp_event_base_t;
                       event_id: int32_t; event_data: pointer) =
  var mac_addr: array[6, uint8_t] = [0]
  ##  we can get the ethernet driver handle from event data
  var eth_handle: esp_eth_handle_t = cast[ptr esp_eth_handle_t](event_data)[]
  case event_id
  of ETHERNET_EVENT_CONNECTED:
    esp_eth_ioctl(eth_handle, ETH_CMD_G_MAC_ADDR, mac_addr)
    ESP_LOGI(TAG, "Ethernet Link Up")
    ESP_LOGI(TAG, "Ethernet HW Addr %02x:%02x:%02x:%02x:%02x:%02x", mac_addr[0],
             mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5])
  of ETHERNET_EVENT_DISCONNECTED:
    ESP_LOGI(TAG, "Ethernet Link Down")
  of ETHERNET_EVENT_START:
    ESP_LOGI(TAG, "Ethernet Started")
  of ETHERNET_EVENT_STOP:
    ESP_LOGI(TAG, "Ethernet Stopped")
  else:
    discard

## * Event handler for IP_EVENT_ETH_GOT_IP

proc got_ip_event_handler*(arg: pointer; event_base: esp_event_base_t;
                          event_id: int32_t; event_data: pointer) =
  var event: ptr ip_event_got_ip_t = cast[ptr ip_event_got_ip_t](event_data)

  var ip_info: ptr tcpip_adapter_ip_info_t = addr(event.ip_info)
  ESP_LOGI(TAG, "Ethernet Got IP Address")
  ESP_LOGI(TAG, "~~~~~~~~~~~")
  ESP_LOGI(TAG, "ETHIP:", IPSTR, IP2STR(addr(ip_info.ip)))
  ESP_LOGI(TAG, "ETHMASK:", IPSTR, IP2STR(addr(ip_info.netmask)))
  ESP_LOGI(TAG, "ETHGW:", IPSTR, IP2STR(addr(ip_info.gw)))
  ESP_LOGI(TAG, "~~~~~~~~~~~")

proc app_main*() =
  tcpip_adapter_init()
  check: esp_event_loop_create_default()
  check: tcpip_adapter_set_default_eth_handlers()
  ESP_ERROR_CHECK(esp_event_handler_register(ETH_EVENT, ESP_EVENT_ANY_ID,
      addr(eth_event_handler), nil))
  ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_ETH_GOT_IP,
      addr(got_ip_event_handler), nil))
  var mac_config: eth_mac_config_t = ETH_MAC_DEFAULT_CONFIG()
  var phy_config: eth_phy_config_t = ETH_PHY_DEFAULT_CONFIG()
  phy_config.phy_addr = CONFIG_EXAMPLE_ETH_PHY_ADDR
  phy_config.reset_gpio_num = CONFIG_EXAMPLE_ETH_PHY_RST_GPIO
  when CONFIG_EXAMPLE_USE_INTERNAL_ETHERNET:
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
  elif CONFIG_EXAMPLE_USE_DM9051:
    gpio_install_isr_service(0)
    var spi_handle: spi_device_handle_t = nil
    var buscfg: spi_bus_config_t = [miso_io_num: CONFIG_EXAMPLE_DM9051_MISO_GPIO,
                                mosi_io_num: CONFIG_EXAMPLE_DM9051_MOSI_GPIO,
                                sclk_io_num: CONFIG_EXAMPLE_DM9051_SCLK_GPIO,
                                quadwp_io_num: -1, quadhd_io_num: -1]
    ESP_ERROR_CHECK(spi_bus_initialize(CONFIG_EXAMPLE_DM9051_SPI_HOST,
                                       addr(buscfg), 1))
    var devcfg: spi_device_interface_config_t = [command_bits: 1, address_bits: 7,
        mode: 0,
        clock_speed_hz: CONFIG_EXAMPLE_DM9051_SPI_CLOCK_MHZ * 1000 * 1000,
        spics_io_num: CONFIG_EXAMPLE_DM9051_CS_GPIO, queue_size: 20]
    ESP_ERROR_CHECK(spi_bus_add_device(CONFIG_EXAMPLE_DM9051_SPI_HOST,
                                       addr(devcfg), addr(spi_handle)))
    ##  dm9051 ethernet driver is based on spi driver
    var dm9051_config: eth_dm9051_config_t = ETH_DM9051_DEFAULT_CONFIG(spi_handle)
    dm9051_config.int_gpio_num = CONFIG_EXAMPLE_DM9051_INT_GPIO
    var mac: ptr esp_eth_mac_t = esp_eth_mac_new_dm9051(addr(dm9051_config),
        addr(mac_config))
    var phy: ptr esp_eth_phy_t = esp_eth_phy_new_dm9051(addr(phy_config))
  var config: esp_eth_config_t = ETH_DEFAULT_CONFIG(mac, phy)
  var eth_handle: esp_eth_handle_t = nil
  check: esp_eth_driver_install(addr(config), addr(eth_handle))
  check: esp_eth_start(eth_handle)
