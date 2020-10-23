##  Copyright 2015-2019 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

# proc esp_netif_htonl*(x: uint32): uint32 {.importc: "$1", header: "esp_netif_types.h".} 

# template esp_netif_ip4_makeu32*(a, b, c, d: untyped): untyped =

##  Access address in 16-bit block

const
  ESP_IPADDR_TYPE_V4* = 0
  ESP_IPADDR_TYPE_V6* = 6
  ESP_IPADDR_TYPE_ANY* = 46

type
  esp_ip6_addr* {.importc: "esp_ip6_addr", header: "esp_netif_ip_addr.h", bycopy.} = object
    address* {.importc: "addr".}: array[4, uint32]
    zone* {.importc: "zone".}: uint8

  esp_ip4_addr* {.importc: "esp_ip4_addr", header: "esp_netif_ip_addr.h", bycopy.} = object
    address* {.importc: "addr".}: uint32

  INNER_C_UNION_esp_netif_ip_addr_97* {.header: "esp_netif_ip_addr.h", bycopy, union.} = object
    ip6* {.importc: "ip6".}: esp_ip6_addr_t
    ip4* {.importc: "ip4".}: esp_ip4_addr_t

  esp_ip4_addr_t* = esp_ip4_addr
  esp_ip6_addr_t* = esp_ip6_addr
  esp_ip_addr_t* {.importc: "esp_ip_addr_t", header: "esp_netif_ip_addr.h", bycopy.} = object
    u_addr* {.importc: "u_addr".}: INNER_C_UNION_esp_netif_ip_addr_97
    `type`* {.importc: "type".}: uint8

