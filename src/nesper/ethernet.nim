
import consts
import general
import esp/esp_log

import gpios
import spis
import esp/driver/spi

import esp/net/esp_eth_com
import esp/net/esp_eth_mac
import esp/net/esp_eth

export esp_eth_com
export esp_eth_mac
export esp_eth

when defined(ESP_IDF_V4_0):
  import nesper/esp/net/tcpip_adapter
  export tcpip_adapter
else:
  import nesper/esp/net/esp_netif_types
  import nesper/esp/net/esp_netif
  export esp_netif_types
  export esp_netif

type
  # EthernetConfigType* = concept x
  #   x.config is EthernetConfig
  #   setupEthernet(x) is EthernetObj
  
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
  EthernetSpiConfig* = ref object
    intr_pin*: GpioPin
    dma_channel*: range[0..2]
    host*: spi_host_device_t
    miso*: GpioPin
    mosi*: GpioPin
    sclk*: GpioPin
    cs*: GpioPin
    mhz*: range[20..80]

  EthConfigDM9051* = ref object
    config*: EthernetConfig
    spi*: EthernetSpiConfig

when not defined(ESP_IDF_V4_0):
  type
    EthConfigW5500* = ref object
      config*: EthernetConfig
      spi*: EthernetSpiConfig

proc initEthernetConfig*(): EthernetConfig =
  new(result)
  result.mac = ethMacDefaultConfig()
  result.phy = ETH_PHY_DEFAULT_CONFIG()

# proc initEthernet*[T](): T =
#   new(result)
#   result.config = initEthernetConfig()

# proc setupEthernet*(eth: var EthConfigIP101): EthernetObj = 
#   result.mac = esp_eth_mac_new_esp32(addr eth.config.mac)
#   result.phy = esp_eth_phy_new_ip101(addr eth.config.phy)

# proc setupEthernet*(eth: var EthConfigRTL8201): EthernetObj = 
#   result.mac = esp_eth_mac_new_esp32(addr eth.config.mac)
#   result.phy = esp_eth_phy_new_rtl8201(addr eth.config.phy)

proc setupEthernet*(eth: var EthConfigDM9051): EthernetObj = 
  check: gpio_install_isr_service(0.esp_intr_flags)

  var
    spi_handle: spi_device_handle_t = nil
    buscfg = spi_bus_config_t(
      miso_io_num: eth.spi.miso.cint,
      mosi_io_num: eth.spi.mosi.cint,
      sclk_io_num: eth.spi.sclk.cint,
      quadwp_io_num: -1,
      quadhd_io_num: -1
    )

  check: spi_bus_initialize(eth.spi.host, addr buscfg, eth.spi.dma_channel)

  var
    devcfg = spi_device_interface_config_t(
      command_bits: 1,
      address_bits: 7,
      mode: 0,
      clock_speed_hz: 1_000_000'i32 * eth.spi.mhz.int32,
      spics_io_num: eth.spi.cs.cint,
      queue_size: 20
    )

  check: spi_bus_add_device(eth.spi.host, addr devcfg, addr spi_handle)

  ##  dm9051 ethernet driver is based on spi driver
  var dm9051_config = eth_dm9051_config_t(spi_hdl: spi_handle, int_gpio_num: eth.spi.intr_pin.int32)

  result.mac = esp_eth_mac_new_dm9051(addr dm9051_config, addr eth.config.mac)
  result.phy = esp_eth_phy_new_dm9051(addr eth.config.phy)

when not defined(ESP_IDF_V4_0):
  proc setupEthernet*(eth: var EthConfigW5500): EthernetObj = 
    check: gpio_install_isr_service(0.esp_intr_flags)

    var
      spi_handle: spi_device_handle_t = nil
      buscfg = spi_bus_config_t(
        miso_io_num: eth.spi.miso.cint,
        mosi_io_num: eth.spi.mosi.cint,
        sclk_io_num: eth.spi.sclk.cint,
        quadwp_io_num: -1,
        quadhd_io_num: -1
      )

    check: spi_bus_initialize(eth.spi.host, addr buscfg, eth.spi.dma_channel)

    var
      devcfg = spi_device_interface_config_t(
        command_bits: 16,
        address_bits: 8,
        mode: 0,
        clock_speed_hz: 1_000_000'i32 * eth.spi.mhz.int32,
        spics_io_num: eth.spi.cs.cint,
        queue_size: 20
      )

    check: spi_bus_add_device(eth.spi.host, addr devcfg, addr spi_handle)

    # /* w5500 ethernet driver is based on spi driver */
    var
      w5500_config = eth_w5500_config_t(spi_hdl: spi_handle, int_gpio_num: 4)


    w5500_config.int_gpio_num = eth.spi.intr_pin.int32

    result.mac = esp_eth_mac_new_w5500(addr w5500_config, addr eth.config.mac)
    result.phy = esp_eth_phy_new_w5500(addr eth.config.phy)

