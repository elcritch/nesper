import consts
import general

import net

export net 

proc toIpAddress(ip: ip4_addr): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv4)
  let address = ip.address
  for i in 0..3:
    result.address_v4[i] = uint8(address shl i*8)

proc toIpAddress(ip: ip6_addr): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv6)
  let address = ip.address
  for i in 0..15:
    result.address_v4[i] = uint8(address shl i*8)