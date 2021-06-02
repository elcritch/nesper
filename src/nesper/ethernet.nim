
import nesper
import nesper/gpios
import nesper/spis
import esp/driver/spi

import nesper/esp/net/esp_eth_com
import nesper/esp/net/esp_eth_mac
import nesper/esp/net/esp_eth
import nesper/esp/net/tcpip_adapter

export esp_eth_com
export esp_eth_mac
export esp_eth
export tcpip_adapter

type
  EthernetConfigType* = concept x
    x.config is EthernetConfig
    setupEthernet(x) is EthernetObj
  
  EthernetConfig* = ref object
    mac*: eth_mac_config_t
    phy*: eth_phy_config_t

  EthernetObj* = object
    phy*: ptr esp_eth_phy_t
    mac*: ptr esp_eth_mac_t

  # Internal Ethernet
  EthConfigIP101* = ref object
    config*: EthernetConfig
    
  EthConfigRTL8201* = ref object
    config*: EthernetConfig

  # External Ethernet
  EthConfigDM9051* = ref object
    config*: EthernetConfig
    intr_pin: GpioPin
    dma_channel: range[0..2]
    spi_host*: spi_host_device_t
    spi_miso*: GpioPin
    spi_mosi*: GpioPin
    spi_sclk*: GpioPin
    spi_cs*: GpioPin
    spi_mhz*: range[20..80]

proc ethernetDefaults*(): EthernetConfig =
  new(result)
  result.mac = ETH_MAC_DEFAULT_CONFIG()
  result.phy = ETH_PHY_DEFAULT_CONFIG()

proc setupEthernet*(eth: var EthConfigIP101): EthernetObj = 
  result.mac = esp_eth_mac_new_esp32(addr eth.config.mac)
  result.phy = esp_eth_phy_new_ip101(addr eth.config.phy)

proc setupEthernet*(eth: var EthConfigRTL8201): EthernetObj = 
  result.mac = esp_eth_mac_new_esp32(addr eth.config.mac)
  result.phy = esp_eth_phy_new_rtl8201(addr eth.config.phy)

proc setupEthernet*(eth: var EthConfigDM9051): EthernetObj = 
  check: gpio_install_isr_service(0.esp_intr_flags)

  var
    spi_handle: spi_device_handle_t = nil
    buscfg = spi_bus_config_t(
      miso_io_num: eth.spi_miso.cint,
      mosi_io_num: eth.spi_mosi.cint,
      sclk_io_num: eth.spi_sclk.cint,
      quadwp_io_num: -1,
      quadhd_io_num: -1
    )

  check: spi_bus_initialize(eth.spi_host, addr buscfg, eth.dma_channel)

  var
    devcfg = spi_device_interface_config_t(
      command_bits: 1,
      address_bits: 7,
      mode: 0,
      clock_speed_hz: 1_000_000'i32 * eth.spi_mhz.int32,
      spics_io_num: eth.spi_cs.cint,
      queue_size: 20
    )

  check: spi_bus_add_device(eth.spi_host, addr devcfg, addr spi_handle)

  ##  dm9051 ethernet driver is based on spi driver
  var dm9051_config = eth_dm9051_config_t(spi_hdl: spi_handle, int_gpio_num: eth.intr_pin.int32)

  result.mac = esp_eth_mac_new_dm9051(addr dm9051_config, addr eth.config.mac)
  result.phy = esp_eth_phy_new_dm9051(addr eth.config.phy)
