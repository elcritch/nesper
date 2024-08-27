import strutils 

import general
import esp/esp_system

import net
export net 

when not defined(ESP_IDF_V4_0):
  import esp/net/esp_netif
  export esp_netif 


## * This is the aligned version of ip4_addr_t,
##    used as local variable, on the stack, etc.
type
  ip4_addr_t* {.importc: "ip4_addr_t", header: "lwip/ip4_addr.h", bycopy.} = object
    address* {.importc: "addr".}: uint32

  ip6_addr_t* {.importc: "ip6_addr_t", header: "lwip/ip6_addr.h", bycopy.} = object
    address* {.importc: "addr".}: array[4, uint32]

type
  lwip_ip_addr_type* {.size: sizeof(cint).} = enum ## * IPv4
    IPADDR_TYPE_V4 = 0,         ## * IPv6
    IPADDR_TYPE_V6 = 6,         ## * IPv4+IPv6 ("dual-stack")
    IPADDR_TYPE_ANY = 46


##  #if LWIP_IPV4 && LWIP_IPV6
## *
##  @ingroup ipaddr
##  A union struct for both IP version's addresses.
##  ATTENTION: watch out for its size when adding IPv6 address scope!
##

type
  INNER_C_UNION_ip_addr_71* {.importc: "no_name", header: "lwip/ip_addr.h", bycopy, union.} = object
    ip6* {.importc: "ip6".}: ip6_addr_t
    ip4* {.importc: "ip4".}: ip4_addr_t

  ip_addr_t* {.importc: "ip_addr_t", header: "lwip/ip_addr.h", bycopy.} = object
    u_addr* {.importc: "u_addr".}: INNER_C_UNION_ip_addr_71 ## * @ref lwip_ip_addr_type
    `type`* {.importc: "type".}: uint8


var ip_addr_any_type* {.importc: "ip_addr_any_type", header: "lwip/ip_addr.h".}: ip_addr_t

type
  esp_interface_t* {.size: sizeof(cint).} = enum
    ESP_IF_WIFI_STA = 0,        ## *< ESP32 station interface
    ESP_IF_WIFI_AP,           ## *< ESP32 soft-AP interface
    ESP_IF_ETH,               ## *< ESP32 ethernet interface
    ESP_IF_MAX
  wifi_mode_t* {.size: sizeof(cint).} = enum
    WIFI_MODE_NULL = 0,         ## *< null mode
    WIFI_MODE_STA,            ## *< WiFi station mode
    WIFI_MODE_AP,             ## *< WiFi soft-AP mode
    WIFI_MODE_APSTA,          ## *< WiFi station + soft-AP mode
    WIFI_MODE_MAX
  wifi_interface_t* = esp_interface_t

const
  WIFI_IF_STA* = ESP_IF_WIFI_STA
  WIFI_IF_AP* = ESP_IF_WIFI_AP

proc toIpAddress*(address: uint32): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv4)
  for i in 0..3:
    result.address_v4[i] = uint8(address shr (i*8))

proc toIpAddress*(address: array[4, uint32]): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv6)
  for i in 0..3:
    for j in 0..3:
      result.address_v6[i] = uint8(address[i] shr (i*8))

when defined(ESP_IDF_V4_0):
  proc toIpAddress*(ip: ip4_addr_t): IpAddress =
    toIpAddress(ip.address)

  proc toIpAddress*(ip: ip6_addr_t): IpAddress =
    toIpAddress(ip.address)

when not defined(ESP_IDF_V4_0):
  proc toIpAddress*(ip: esp_ip4_addr_t): IpAddress =
    toIpAddress(ip.address)

  proc toIpAddress*(ip: esp_ip6_addr_t): IpAddress =
    toIpAddress(ip.address)

## * Generate host name based on sdkconfig, optionally adding a portion of MAC address to it.
proc generate_hostname*(hostname: string): string =
  var mac: array[6, uint8]
  check: esp_read_mac(cast[ptr uint8](addr(mac)), ESP_MAC_WIFI_STA)

  var sensor_id = $hostname
  for i in 3..5:
    sensor_id.add(mac[i].toHex(2))

  return sensor_id


## * Generate sensor id (based on mac address)
proc generate_sensor_id*(): string =
  var mac: array[6, uint8]
  check: esp_read_mac(cast[ptr uint8](addr(mac)), ESP_MAC_WIFI_STA)

  var sensor_id = newSeqOfCap[string](6)
  for i in 0..5:
    sensor_id.add(mac[i].toHex(2))

  return sensor_id.join(":")

