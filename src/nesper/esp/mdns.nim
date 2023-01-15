##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
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

import ../consts
import ../net_utils
import ../esp/esp_event_legacy

import ../esp/net/esp_netif

# const hdr = "mdns.h"
const hdr = "mdns.h"

type
  mdns_type* = enum
    MDNS_TYPE_A = 0x00000001
    MDNS_TYPE_PTR = 0x0000000C
    MDNS_TYPE_TXT = 0x00000010
    MDNS_TYPE_AAAA = 0x0000001C
    MDNS_TYPE_SRV = 0x00000021
    MDNS_TYPE_OPT = 0x00000029
    MDNS_TYPE_NSEC = 0x0000002F
    MDNS_TYPE_ANY = 0x000000FF


## *
##  @brief   mDNS enum to specify the ip_protocol type
##

type
  mdns_ip_protocol_t* {.size: sizeof(cint).} = enum
    MDNS_IP_PROTOCOL_V4, MDNS_IP_PROTOCOL_V6, MDNS_IP_PROTOCOL_MAX


## *
##  @brief   mDNS basic text item structure
##           Used in mdns_service_add()
##

type
  mdns_txt_item_t* {.importc: "mdns_txt_item_t", header: hdr, bycopy.} = object
    key* {.importc: "key".}: cstring ## !< item key name
    value* {.importc: "value".}: cstring ## !< item value string


## *
##  @brief   mDNS query linked list IP item
##

type
  mdns_ip_addr_t* {.importc: "mdns_ip_addr_t", header: hdr, bycopy.} = object
    when defined(ESP_IDF_V4_0):
      `addr`* {.importc: "addr".}: ip_addr_t ## !< IP address
    else:
      `addr`* {.importc: "addr".}: esp_ip_addr_t ## !< IP address
    next* {.importc: "next".}: ptr mdns_ip_addr_t ## !< next IP, or NULL for the last IP in the list

  mdns_if_t* = enum
    MDNS_IF_STA = 0,
    MDNS_IF_AP = 1,
    MDNS_IF_ETH = 2,
    MDNS_IF_MAX


## *
##  @brief   mDNS query result structure
##

type
  mdns_result_t* {.importc: "mdns_result_t", header: hdr, bycopy.} = object
    next* {.importc: "next".}: ptr mdns_result_t ## !< next result, or NULL for the last result in the list
    when defined(ESP_IDF_V4_0):
        tcpip_if* {.importc: "tcpip_if".}: tcpip_adapter_if_t ## !< interface on which the result came (AP/STA/ETH)
    else:
        tcpip_if* {.importc: "tcpip_if".}: mdns_if_t ## !< interface on which the result came (AP/STA/ETH)
    ip_protocol* {.importc: "ip_protocol".}: mdns_ip_protocol_t ## !< ip_protocol type of the interface (v4/v6)
                                                            ##  PTR
    instance_name* {.importc: "instance_name".}: cstring ## !< instance name
                                                     ##  SRV
    hostname* {.importc: "hostname".}: cstring ## !< hostname
    port* {.importc: "port".}: uint16 ## !< service port
                                    ##  TXT
    txt* {.importc: "txt".}: ptr mdns_txt_item_t ## !< txt record
    txt_count* {.importc: "txt_count".}: csize_t ## !< number of txt items
                                             ##  A and AAAA
    `addr`* {.importc: "addr".}: ptr mdns_ip_addr_t ## !< linked list of IP addreses found


## *
##  @brief  Initialize mDNS on given interface
##
##  @return
##      - ESP_OK on success
##      - ESP_ERR_INVALID_STATE when failed to register event handler
##      - ESP_ERR_NO_MEM on memory error
##      - ESP_FAIL when failed to start mdns task
##

proc mdns_init*(): esp_err_t {.importc: "mdns_init", header: hdr.}

## *
##  @brief  Stop and free mDNS server
##
##

proc mdns_free*() {.importc: "mdns_free", header: hdr.}
## *
##  @brief  Set the hostname for mDNS server
##          required if you want to advertise services
##
##  @param  hostname     Hostname to set
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_hostname_set*(hostname: cstring): esp_err_t {.
    importc: "mdns_hostname_set", header: hdr.}
## *
##  @brief  Set the default instance name for mDNS server
##
##  @param  instance_name     Instance name to set
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_instance_name_set*(instance_name: cstring): esp_err_t {.
    importc: "mdns_instance_name_set", header: hdr.}
## *
##  @brief  Add service to mDNS server
##
##  @param  instance_name    instance name to set. If NULL,
##                           global instance name or hostname will be used
##  @param  service_type     service type (_http, _ftp, etc)
##  @param  proto            service protocol (_tcp, _udp)
##  @param  port             service port
##  @param  txt              string array of TXT data (eg. {{"var","val"},{"other","2"}})
##  @param  num_items        number of items in TXT data
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NO_MEM memory error
##      - ESP_FAIL failed to add serivce
##

proc mdns_service_add*(instance_name: cstring; service_type: cstring; proto: cstring;
                    port: uint16; txt: ptr mdns_txt_item_t; num_items: csize_t): esp_err_t {.
    importc: "mdns_service_add", header: hdr.}

## *
##  @brief  Remove service from mDNS server
##
##  @param  service_type service type (_http, _ftp, etc)
##  @param  proto        service protocol (_tcp, _udp)
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_remove*(service_type: cstring; proto: cstring): esp_err_t {.
    importc: "mdns_service_remove", header: hdr.}

## *
##  @brief  Set instance name for service
##
##  @param  service_type     service type (_http, _ftp, etc)
##  @param  proto            service protocol (_tcp, _udp)
##  @param  instance_name    instance name to set
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_instance_name_set*(service_type: cstring; proto: cstring;
                                    instance_name: cstring): esp_err_t {.
    importc: "mdns_service_instance_name_set", header: hdr.}
## *
##  @brief  Set service port
##
##  @param  service_type service type (_http, _ftp, etc)
##  @param  proto        service protocol (_tcp, _udp)
##  @param  port         service port
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_port_set*(service_type: cstring; proto: cstring; port: uint16): esp_err_t {.
    importc: "mdns_service_port_set", header: hdr.}
## *
##  @brief  Replace all TXT items for service
##
##  @param  service_type service type (_http, _ftp, etc)
##  @param  proto        service protocol (_tcp, _udp)
##  @param  txt          array of TXT data (eg. {{"var","val"},{"other","2"}})
##  @param  num_items    number of items in TXT data
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_txt_set*(service_type: cstring; proto: cstring;
                        txt: ptr mdns_txt_item_t; num_items: uint8): esp_err_t {.
    importc: "mdns_service_txt_set", header: hdr.}

## *
##  @brief  Set/Add TXT item for service TXT record
##
##  @param  service_type service type (_http, _ftp, etc)
##  @param  proto        service protocol (_tcp, _udp)
##  @param  key          the key that you want to add/update
##  @param  value        the new value of the key
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_txt_item_set*(service_type: cstring; proto: cstring; key: cstring;
                            value: cstring): esp_err_t {.
    importc: "mdns_service_txt_item_set", header: hdr.}
## *
##  @brief  Remove TXT item for service TXT record
##
##  @param  service_type service type (_http, _ftp, etc)
##  @param  proto        service protocol (_tcp, _udp)
##  @param  key          the key that you want to remove
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##      - ESP_ERR_NOT_FOUND Service not found
##      - ESP_ERR_NO_MEM memory error
##

proc mdns_service_txt_item_remove*(service_type: cstring; proto: cstring;
                                key: cstring): esp_err_t {.
    importc: "mdns_service_txt_item_remove", header: hdr.}
## *
##  @brief  Remove and free all services from mDNS server
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mdns_service_remove_all*(): esp_err_t {.importc: "mdns_service_remove_all",
    header: hdr.}


# else:
#     # proc service_get_txt_fn*(service: ptr mdns_service, txt_userdata: pointer) {.cdecl, importc: "$1", header: hdr.}

#     type
#         # mdns_service* {.importc: "$1", header: hdr, bycopy, incompleteStruct.} = object
#         mdns_service* {.exportc, incompleteStruct, bycopy.} = object

#         # typedef void (*service_get_txt_fn_t)(struct mdns_service *service, void *txt_userdata);
#         service_get_txt_fn_t* = proc(service: ptr mdns_service, txt_userdata: pointer) {.cdecl.}

#         mdns_sd_proto* {.size: sizeof(cint).} = enum
#             DNSSD_PROTO_UDP = 0,
#             DNSSD_PROTO_TCP = 1
        
    
#     # err_t mdns_resp_add_service_txtitem(struct mdns_service *service, const char *txt, u8_t txt_len);
#     proc mdns_resp_add_service_txtitem*(service: ptr mdns_service, txt: cstring, txt_len: uint8): esp_err_t {.importc: "$1", header: hdr.}
#     # s8_t  mdns_resp_add_service(struct netif *netif, const char *name, const char *service, enum mdns_sd_proto proto, u16_t port, u32_t dns_ttl, service_get_txt_fn_t txt_fn, void *txt_userdata);
#     proc mdns_resp_add_service*(netif: ptr esp_netif_t, name: cstring, service: cstring, proto: mdns_sd_proto, port: uint16, dns_ttl: uint32, txt_fn: service_get_txt_fn_t, txt_userdata: pointer) {.importc: "$1", header: hdr.}


proc mdns_query*(name: cstring; service_type: cstring; proto: cstring;
                `type`: uint16; timeout: uint32; max_results: csize_t;
                results: ptr ptr mdns_result_t): esp_err_t {.importc: "mdns_query",
    header: hdr.}
    ## *
    ##  @brief  Query mDNS for host or service
    ##          All following query methods are derived from this one
    ##
    ##  @param  name         service instance or host name (NULL for PTR queries)
    ##  @param  service_type service type (_http, _arduino, _ftp etc.) (NULL for host queries)
    ##  @param  proto        service protocol (_tcp, _udp, etc.) (NULL for host queries)
    ##  @param  type         type of query (MDNS_TYPE_*)
    ##  @param  timeout      time in milliseconds to wait for answers.
    ##  @param  max_results  maximum results to be collected
    ##  @param  results      pointer to the results of the query
    ##                       results must be freed using mdns_query_results_free below
    ##
    ##  @return
    ##      - ESP_OK success
    ##      - ESP_ERR_INVALID_STATE  mDNS is not running
    ##      - ESP_ERR_NO_MEM         memory error
    ##      - ESP_ERR_INVALID_ARG    timeout was not given
    ##


## *
##  @brief  Free query results
##
##  @param  results      linked list of results to be freed
##

proc mdns_query_results_free*(results: ptr mdns_result_t) {.
    importc: "mdns_query_results_free", header: hdr.}
## *
##  @brief  Query mDNS for service
##
##  @param  service_type service type (_http, _arduino, _ftp etc.)
##  @param  proto        service protocol (_tcp, _udp, etc.)
##  @param  timeout      time in milliseconds to wait for answer.
##  @param  max_results  maximum results to be collected
##  @param  results      pointer to the results of the query
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_STATE  mDNS is not running
##      - ESP_ERR_NO_MEM         memory error
##      - ESP_ERR_INVALID_ARG    parameter error
##

proc mdns_query_ptr*(service_type: cstring; proto: cstring; timeout: uint32;
                    max_results: csize_t; results: ptr ptr mdns_result_t): esp_err_t {.
    importc: "mdns_query_ptr", header: hdr.}
## *
##  @brief  Query mDNS for SRV record
##
##  @param  instance_name    service instance name
##  @param  service_type     service type (_http, _arduino, _ftp etc.)
##  @param  proto            service protocol (_tcp, _udp, etc.)
##  @param  timeout          time in milliseconds to wait for answer.
##  @param  result           pointer to the result of the query
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_STATE  mDNS is not running
##      - ESP_ERR_NO_MEM         memory error
##      - ESP_ERR_INVALID_ARG    parameter error
##

proc mdns_query_srv*(instance_name: cstring; service_type: cstring; proto: cstring;
                    timeout: uint32; result: ptr ptr mdns_result_t): esp_err_t {.
    importc: "mdns_query_srv", header: hdr.}
## *
##  @brief  Query mDNS for TXT record
##
##  @param  instance_name    service instance name
##  @param  service_type     service type (_http, _arduino, _ftp etc.)
##  @param  proto            service protocol (_tcp, _udp, etc.)
##  @param  timeout          time in milliseconds to wait for answer.
##  @param  result           pointer to the result of the query
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_STATE  mDNS is not running
##      - ESP_ERR_NO_MEM         memory error
##      - ESP_ERR_INVALID_ARG    parameter error
##

proc mdns_query_txt*(instance_name: cstring; service_type: cstring; proto: cstring;
                    timeout: uint32; result: ptr ptr mdns_result_t): esp_err_t {.
    importc: "mdns_query_txt", header: hdr.}
## *
##  @brief  Query mDNS for A record
##
##  @param  host_name    host name to look for
##  @param  timeout      time in milliseconds to wait for answer.
##  @param  addr         pointer to the resulting IP4 address
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_STATE  mDNS is not running
##      - ESP_ERR_NO_MEM         memory error
##      - ESP_ERR_INVALID_ARG    parameter error
##

proc mdns_query_a*(host_name: cstring; timeout: uint32; `addr`: ptr ip4_addr_t): esp_err_t {.
    importc: "mdns_query_a", header: hdr.}
## *
##  @brief  Query mDNS for A record
##
##  @param  host_name    host name to look for
##  @param  timeout      time in milliseconds to wait for answer. If 0, max_results needs to be defined
##  @param  addr         pointer to the resulting IP6 address
##
##  @return
##      - ESP_OK success
##      - ESP_ERR_INVALID_STATE  mDNS is not running
##      - ESP_ERR_NO_MEM         memory error
##      - ESP_ERR_INVALID_ARG    parameter error
##

proc mdns_query_aaaa*(host_name: cstring; timeout: uint32; `addr`: ptr ip6_addr_t): esp_err_t {.
    importc: "mdns_query_aaaa", header: hdr.}
## *
##  @brief   System event handler
##           This method controls the service state on all active interfaces and applications are required
##           to call it from the system event handler for normal operation of mDNS service.
##
##  @param  ctx          The system event context
##  @param  event        The system event
##

proc mdns_handle_system_event*(ctx: pointer; event: ptr system_event_t): esp_err_t {.
    importc: "mdns_handle_system_event", header: hdr.}