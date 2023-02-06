##  Copyright 2019 Espressif Systems (Shanghai) PTE LTD
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


import ../../consts

##
##  Note: tcpip_adapter legacy API has to be included by default to provide full compatibility
##   for applications that used tcpip_adapter API without explicit inclusion of tcpip_adapter.h
##

when defined(ESP_IDF_V4_0):
  include tcpip_adapter

else:

  import esp_wifi_types
  import esp_netif_ip_addr
  import esp_netif_types
  import esp_eth_netif_glue

  import esp_netif_impl
  import esp_netif_defaults

  export esp_netif_impl
  export esp_netif_defaults

  export esp_wifi_types
  export esp_netif_ip_addr
  export esp_netif_types
  export esp_eth_netif_glue

