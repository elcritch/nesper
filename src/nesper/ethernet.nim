
import nesper/gpios
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
    initEthernet(x) is EthernetObj
  
  EthernetConfigInternalType* = concept x
    x.phy_config is eth_phy_config_t
    x.mac_config is eth_mac_config_t
    initEthernet(x) is EthernetObj
  
  EthernetObj* = object
    phy*: ptr esp_eth_phy_t
    mac*: ptr esp_eth_mac_t

  # Internal Ethernet
  EthConfigIP101* = ref object
    mac_config*: eth_mac_config_t
    phy_config*: eth_phy_config_t
    
  EthConfigRTL8201* = ref object
    mac_config*: eth_mac_config_t
    phy_config*: eth_phy_config_t

  # External Ethernet
  EthConfigDM9051* = ref object
    config*: eth_dm9051_config_t
    phy_config*: eth_phy_config_t

proc initDefaults*(eth: EthernetConfigInternalType) =
  eth.mac_config = ETH_MAC_DEFAULT_CONFIG()
  eth.phy_config = eth_phy_config_t(
        phy_addr: high(uint32),
        reset_timeout_ms: 100,
        autonego_timeout_ms: 4000,
        reset_gpio_num: -1)         


proc initEthernet*(
      eth: var EthConfigIP101,
      phy_addr: range[1..31] = 1,
      reset_gpio = GpioPin(-1)
    ): EthernetObj =
  eth.initDefaults()
  eth.phy_config.reset_gpio_num = reset_gpio.int32

proc initEthernet*(
      eth: var EthConfigRTL8201,
      phy_addr: range[1..31] = 1,
      reset_gpio = GpioPin(-1)
    ): ptr esp_eth_mac_t = 
  eth.phy_config.phy_addr = phy_addr.uint32
  eth.phy_config.reset_gpio_num = reset_gpio.int32
  eth.mac_config.smi_mdc_gpio_num = -1
  eth.mac_config.smi_mdio_gpio_num = -1

proc setupEthernet*(eth: EthernetConfigInternalType) = 
  assert eth.smi_mdc_gpio_num >= 0
  assert eth.smi_mdio_gpio_num >= 0
  eth.smi_mdio_gpio_num = 18


proc setupEthernet*(eth: EthConfigIP101) = 
  discard "todo"
