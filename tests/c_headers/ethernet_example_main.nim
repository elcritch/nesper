##  Ethernet Basic Example
##
##    This example code is in the Public Domain (or CC0 licensed, at your option.)
##
##    Unless required by applicable law or agreed to in writing, this
##    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.
##

import
  freertos/FreeRTOS, freertos/task, esp_netif, esp_eth, esp_event, esp_log,
  driver/gpio, sdkconfig

when CONFIG_ETH_USE_SPI_ETHERNET:
  import
    driver/spi_master

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
  var ip_info: ptr esp_netif_ip_info_t = addr(event.ip_info)
  ESP_LOGI(TAG, "Ethernet Got IP Address")
  ESP_LOGI(TAG, "~~~~~~~~~~~")
  ESP_LOGI(TAG, "ETHIP:", IPSTR, IP2STR(addr(ip_info.ip)))
  ESP_LOGI(TAG, "ETHMASK:", IPSTR, IP2STR(addr(ip_info.netmask)))
  ESP_LOGI(TAG, "ETHGW:", IPSTR, IP2STR(addr(ip_info.gw)))
  ESP_LOGI(TAG, "~~~~~~~~~~~")

proc app_main*() =
  ##  Initialize TCP/IP network interface (should be called only once in application)
  ESP_ERROR_CHECK(esp_netif_init())
  ##  Create default event loop that running in background
  ESP_ERROR_CHECK(esp_event_loop_create_default())
  var cfg: esp_netif_config_t = ESP_NETIF_DEFAULT_ETH()
  var eth_netif: ptr esp_netif_t = esp_netif_new(addr(cfg))
  ##  Set default handlers to process TCP/IP stuffs
  ESP_ERROR_CHECK(esp_eth_set_default_handlers(eth_netif))
  ##  Register user defined event handers
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
    elif CONFIG_EXAMPLE_ETH_PHY_KSZ8041:
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_ksz8041(addr(phy_config))
  elif CONFIG_ETH_USE_SPI_ETHERNET:
    gpio_install_isr_service(0)
    var spi_handle: spi_device_handle_t = nil
    var buscfg: spi_bus_config_t = [miso_io_num: CONFIG_EXAMPLE_ETH_SPI_MISO_GPIO,
                                mosi_io_num: CONFIG_EXAMPLE_ETH_SPI_MOSI_GPIO,
                                sclk_io_num: CONFIG_EXAMPLE_ETH_SPI_SCLK_GPIO,
                                quadwp_io_num: -1, quadhd_io_num: -1]
    ESP_ERROR_CHECK(spi_bus_initialize(CONFIG_EXAMPLE_ETH_SPI_HOST, addr(buscfg),
                                       1))
    when CONFIG_EXAMPLE_USE_DM9051:
      var devcfg: spi_device_interface_config_t = [command_bits: 1, address_bits: 7,
          mode: 0, clock_speed_hz: CONFIG_EXAMPLE_ETH_SPI_CLOCK_MHZ * 1000 * 1000,
          spics_io_num: CONFIG_EXAMPLE_ETH_SPI_CS_GPIO, queue_size: 20]
      ESP_ERROR_CHECK(spi_bus_add_device(CONFIG_EXAMPLE_ETH_SPI_HOST,
          addr(devcfg), addr(spi_handle)))
      ##  dm9051 ethernet driver is based on spi driver
      var dm9051_config: eth_dm9051_config_t = ETH_DM9051_DEFAULT_CONFIG(spi_handle)
      dm9051_config.int_gpio_num = CONFIG_EXAMPLE_ETH_SPI_INT_GPIO
      var mac: ptr esp_eth_mac_t = esp_eth_mac_new_dm9051(addr(dm9051_config),
          addr(mac_config))
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_dm9051(addr(phy_config))
    elif CONFIG_EXAMPLE_USE_W5500:
      var devcfg: spi_device_interface_config_t = [command_bits: 16, address_bits: 8,
          mode: 0, clock_speed_hz: CONFIG_EXAMPLE_ETH_SPI_CLOCK_MHZ * 1000 * 1000,
          spics_io_num: CONFIG_EXAMPLE_ETH_SPI_CS_GPIO, queue_size: 20]
      ESP_ERROR_CHECK(spi_bus_add_device(CONFIG_EXAMPLE_ETH_SPI_HOST,
          addr(devcfg), addr(spi_handle)))
      ##  w5500 ethernet driver is based on spi driver
      var w5500_config: eth_w5500_config_t = ETH_W5500_DEFAULT_CONFIG(spi_handle)
      w5500_config.int_gpio_num = CONFIG_EXAMPLE_ETH_SPI_INT_GPIO
      var mac: ptr esp_eth_mac_t = esp_eth_mac_new_w5500(addr(w5500_config),
          addr(mac_config))
      var phy: ptr esp_eth_phy_t = esp_eth_phy_new_w5500(addr(phy_config))
  var config: esp_eth_config_t = ETH_DEFAULT_CONFIG(mac, phy)
  var eth_handle: esp_eth_handle_t = nil
  ESP_ERROR_CHECK(esp_eth_driver_install(addr(config), addr(eth_handle)))
  when not CONFIG_EXAMPLE_USE_INTERNAL_ETHERNET:
    ##  The SPI Ethernet module might doesn't have a burned factory MAC address, we cat to set it manually.
    ##        02:00:00 is a Locally Administered OUI range so should not be used except when testing on a LAN under your control.
    ##
    ESP_ERROR_CHECK(esp_eth_ioctl(eth_handle, ETH_CMD_S_MAC_ADDR, cast[UncheckedArray[
        uint8_t]]((0x02, 0x00, 0x00, 0x12, 0x34, 0x56))))
  ##  attach Ethernet driver to TCP/IP stack
  ESP_ERROR_CHECK(esp_netif_attach(eth_netif, esp_eth_new_netif_glue(eth_handle)))
  ##  start Ethernet driver state machine
  ESP_ERROR_CHECK(esp_eth_start(eth_handle))
