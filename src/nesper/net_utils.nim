import strutils 

import general
import esp/esp_system

import net
export net 

when not defined(ESP_IDF_V4_0):
  import esp/net/esp_netif
  export esp_netif 


type
  esp_interface_t* {.size: sizeof(cint).} = enum
    ESP_IF_WIFI_STA = 0,        ## *< ESP32 station interface
    ESP_IF_WIFI_AP,           ## *< ESP32 soft-AP interface
    ESP_IF_ETH,               ## *< ESP32 ethernet interface
    ESP_IF_MAX

const
  WIFI_IF_STA* = ESP_IF_WIFI_STA
  WIFI_IF_AP* = ESP_IF_WIFI_AP

proc toIpAddress*(address: uint32): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv4)
  for i in 0..3:
    result.address_v4[i] = uint8(address shr (i*8))

proc toIpAddress*(address: array[4, uint32]): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv6)
  copyMem(result.address_v6[0].unsafeAddr, address[0].unsafeAddr, 16)

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

when not defined(ESP_IDF_V4_0):
  ## Convert a Nim IPv6 IpAddress to ESP-IDF esp_ip6_addr_t
  proc toEspIp6Addr*(ip: IpAddress): esp_ip6_addr_t =
    ## Ensures the input is IPv6 and maps bytes directly
    doAssert ip.family == IpAddressFamily.IPv6
    var res: esp_ip6_addr_t
    res.zone = 0'u8
    copyMem(res.address[0].unsafeAddr, ip.address_v6[0].unsafeAddr, 16)
    return res

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
