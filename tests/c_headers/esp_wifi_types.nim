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

import
  esp_private/esp_wifi_types_private

type
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

type
  wifi_country_policy_t* {.size: sizeof(cint).} = enum
    WIFI_COUNTRY_POLICY_AUTO, ## *< Country policy is auto, use the country info of AP to which the station is connected
    WIFI_COUNTRY_POLICY_MANUAL ## *< Country policy is manual, always use the configured country info


## * @brief Structure describing WiFi country-based regional restrictions.

type
  wifi_country_t* {.importc: "wifi_country_t", header: "esp_wifi_types.h", bycopy.} = object
    cc* {.importc: "cc".}: array[3, char] ## *< country code string
    schan* {.importc: "schan".}: uint8_t ## *< start channel
    nchan* {.importc: "nchan".}: uint8_t ## *< total channel number
    max_tx_power* {.importc: "max_tx_power".}: int8_t ## *< This field is used for getting WiFi maximum transmitting power, call esp_wifi_set_max_tx_power to set the maximum transmitting power.
    policy* {.importc: "policy".}: wifi_country_policy_t ## *< country policy

  wifi_auth_mode_t* {.size: sizeof(cint).} = enum
    WIFI_AUTH_OPEN = 0,         ## *< authenticate mode : open
    WIFI_AUTH_WEP,            ## *< authenticate mode : WEP
    WIFI_AUTH_WPA_PSK,        ## *< authenticate mode : WPA_PSK
    WIFI_AUTH_WPA2_PSK,       ## *< authenticate mode : WPA2_PSK
    WIFI_AUTH_WPA_WPA2_PSK,   ## *< authenticate mode : WPA_WPA2_PSK
    WIFI_AUTH_WPA2_ENTERPRISE, ## *< authenticate mode : WPA2_ENTERPRISE
    WIFI_AUTH_WPA3_PSK,       ## *< authenticate mode : WPA3_PSK
    WIFI_AUTH_WPA2_WPA3_PSK,  ## *< authenticate mode : WPA2_WPA3_PSK
    WIFI_AUTH_MAX
  wifi_err_reason_t* {.size: sizeof(cint).} = enum
    WIFI_REASON_UNSPECIFIED = 1, WIFI_REASON_AUTH_EXPIRE = 2,
    WIFI_REASON_AUTH_LEAVE = 3, WIFI_REASON_ASSOC_EXPIRE = 4,
    WIFI_REASON_ASSOC_TOOMANY = 5, WIFI_REASON_NOT_AUTHED = 6,
    WIFI_REASON_NOT_ASSOCED = 7, WIFI_REASON_ASSOC_LEAVE = 8,
    WIFI_REASON_ASSOC_NOT_AUTHED = 9, WIFI_REASON_DISASSOC_PWRCAP_BAD = 10,
    WIFI_REASON_DISASSOC_SUPCHAN_BAD = 11, WIFI_REASON_IE_INVALID = 13,
    WIFI_REASON_MIC_FAILURE = 14, WIFI_REASON_4WAY_HANDSHAKE_TIMEOUT = 15,
    WIFI_REASON_GROUP_KEY_UPDATE_TIMEOUT = 16, WIFI_REASON_IE_IN_4WAY_DIFFERS = 17,
    WIFI_REASON_GROUP_CIPHER_INVALID = 18,
    WIFI_REASON_PAIRWISE_CIPHER_INVALID = 19, WIFI_REASON_AKMP_INVALID = 20,
    WIFI_REASON_UNSUPP_RSN_IE_VERSION = 21, WIFI_REASON_INVALID_RSN_IE_CAP = 22,
    WIFI_REASON_802_1X_AUTH_FAILED = 23, WIFI_REASON_CIPHER_SUITE_REJECTED = 24,
    WIFI_REASON_INVALID_PMKID = 53, WIFI_REASON_BEACON_TIMEOUT = 200,
    WIFI_REASON_NO_AP_FOUND = 201, WIFI_REASON_AUTH_FAIL = 202,
    WIFI_REASON_ASSOC_FAIL = 203, WIFI_REASON_HANDSHAKE_TIMEOUT = 204,
    WIFI_REASON_CONNECTION_FAIL = 205
  wifi_second_chan_t* {.size: sizeof(cint).} = enum
    WIFI_SECOND_CHAN_NONE = 0,  ## *< the channel width is HT20
    WIFI_SECOND_CHAN_ABOVE,   ## *< the channel width is HT40 and the secondary channel is above the primary channel
    WIFI_SECOND_CHAN_BELOW    ## *< the channel width is HT40 and the secondary channel is below the primary channel
  wifi_scan_type_t* {.size: sizeof(cint).} = enum
    WIFI_SCAN_TYPE_ACTIVE = 0,  ## *< active scan
    WIFI_SCAN_TYPE_PASSIVE    ## *< passive scan





## * @brief Range of active scan times per channel

type
  wifi_active_scan_time_t* {.importc: "wifi_active_scan_time_t",
                            header: "esp_wifi_types.h", bycopy.} = object
    min* {.importc: "min".}: uint32_t ## *< minimum active scan time per channel, units: millisecond
    max* {.importc: "max".}: uint32_t ## *< maximum active scan time per channel, units: millisecond, values above 1500ms may
                                  ##                                           cause station to disconnect from AP and are not recommended.


## * @brief Aggregate of active & passive scan time per channel

type
  wifi_scan_time_t* {.importc: "wifi_scan_time_t", header: "esp_wifi_types.h", bycopy.} = object {.
      union.}
    active* {.importc: "active".}: wifi_active_scan_time_t ## *< active scan time per channel, units: millisecond.
    passive* {.importc: "passive".}: uint32_t ## *< passive scan time per channel, units: millisecond, values above 1500ms may
                                          ##                                           cause station to disconnect from AP and are not recommended.


## * @brief Parameters for an SSID scan.

type
  wifi_scan_config_t* {.importc: "wifi_scan_config_t", header: "esp_wifi_types.h",
                       bycopy.} = object
    ssid* {.importc: "ssid".}: ptr uint8_t ## *< SSID of AP
    bssid* {.importc: "bssid".}: ptr uint8_t ## *< MAC address of AP
    channel* {.importc: "channel".}: uint8_t ## *< channel, scan the specific channel
    show_hidden* {.importc: "show_hidden".}: bool ## *< enable to scan AP whose SSID is hidden
    scan_type* {.importc: "scan_type".}: wifi_scan_type_t ## *< scan type, active or passive
    scan_time* {.importc: "scan_time".}: wifi_scan_time_t ## *< scan time per channel

  wifi_cipher_type_t* {.size: sizeof(cint).} = enum
    WIFI_CIPHER_TYPE_NONE = 0,  ## *< the cipher type is none
    WIFI_CIPHER_TYPE_WEP40,   ## *< the cipher type is WEP40
    WIFI_CIPHER_TYPE_WEP104,  ## *< the cipher type is WEP104
    WIFI_CIPHER_TYPE_TKIP,    ## *< the cipher type is TKIP
    WIFI_CIPHER_TYPE_CCMP,    ## *< the cipher type is CCMP
    WIFI_CIPHER_TYPE_TKIP_CCMP, ## *< the cipher type is TKIP and CCMP
    WIFI_CIPHER_TYPE_AES_CMAC128, ## *< the cipher type is AES-CMAC-128
    WIFI_CIPHER_TYPE_UNKNOWN  ## *< the cipher type is unknown


## *
##  @brief WiFi antenna
##
##

type
  wifi_ant_t* {.size: sizeof(cint).} = enum
    WIFI_ANT_ANT0,            ## *< WiFi antenna 0
    WIFI_ANT_ANT1,            ## *< WiFi antenna 1
    WIFI_ANT_MAX              ## *< Invalid WiFi antenna


## * @brief Description of a WiFi AP

type
  wifi_ap_record_t* {.importc: "wifi_ap_record_t", header: "esp_wifi_types.h", bycopy.} = object
    bssid* {.importc: "bssid".}: array[6, uint8_t] ## *< MAC address of AP
    ssid* {.importc: "ssid".}: array[33, uint8_t] ## *< SSID of AP
    primary* {.importc: "primary".}: uint8_t ## *< channel of AP
    second* {.importc: "second".}: wifi_second_chan_t ## *< secondary channel of AP
    rssi* {.importc: "rssi".}: int8_t ## *< signal strength of AP
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ## *< authmode of AP
    pairwise_cipher* {.importc: "pairwise_cipher".}: wifi_cipher_type_t ## *< pairwise cipher of AP
    group_cipher* {.importc: "group_cipher".}: wifi_cipher_type_t ## *< group cipher of AP
    ant* {.importc: "ant".}: wifi_ant_t ## *< antenna used to receive beacon from AP
    phy_11b* {.importc: "phy_11b".} {.bitsize: 1.}: uint32_t ## *< bit: 0 flag to identify if 11b mode is enabled or not
    phy_11g* {.importc: "phy_11g".} {.bitsize: 1.}: uint32_t ## *< bit: 1 flag to identify if 11g mode is enabled or not
    phy_11n* {.importc: "phy_11n".} {.bitsize: 1.}: uint32_t ## *< bit: 2 flag to identify if 11n mode is enabled or not
    phy_lr* {.importc: "phy_lr".} {.bitsize: 1.}: uint32_t ## *< bit: 3 flag to identify if low rate is enabled or not
    wps* {.importc: "wps".} {.bitsize: 1.}: uint32_t ## *< bit: 4 flag to identify if WPS is supported or not
    reserved* {.importc: "reserved".} {.bitsize: 27.}: uint32_t ## *< bit: 5..31 reserved
    country* {.importc: "country".}: wifi_country_t ## *< country information of AP

  wifi_scan_method_t* {.size: sizeof(cint).} = enum
    WIFI_FAST_SCAN = 0,         ## *< Do fast scan, scan will end after find SSID match AP
    WIFI_ALL_CHANNEL_SCAN     ## *< All channel scan, scan will end after scan all the channel
  wifi_sort_method_t* {.size: sizeof(cint).} = enum
    WIFI_CONNECT_AP_BY_SIGNAL = 0, ## *< Sort match AP in scan list by RSSI
    WIFI_CONNECT_AP_BY_SECURITY ## *< Sort match AP in scan list by security mode



## * @brief Structure describing parameters for a WiFi fast scan

type
  wifi_scan_threshold_t* {.importc: "wifi_scan_threshold_t",
                          header: "esp_wifi_types.h", bycopy.} = object
    rssi* {.importc: "rssi".}: int8_t ## *< The minimum rssi to accept in the fast scan mode
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ## *< The weakest authmode to accept in the fast scan mode

  wifi_ps_type_t* {.size: sizeof(cint).} = enum
    WIFI_PS_NONE,             ## *< No power save
    WIFI_PS_MIN_MODEM,        ## *< Minimum modem power saving. In this mode, station wakes up to receive beacon every DTIM period
    WIFI_PS_MAX_MODEM         ## *< Maximum modem power saving. In this mode, interval to receive beacons is determined by the listen_interval parameter in wifi_sta_config_t


const
  WIFI_PROTOCOL_11B* = 1
  WIFI_PROTOCOL_11G* = 2
  WIFI_PROTOCOL_11N* = 4
  WIFI_PROTOCOL_LR* = 8

type
  wifi_bandwidth_t* {.size: sizeof(cint).} = enum
    WIFI_BW_HT20 = 1,           ##  Bandwidth is HT20
    WIFI_BW_HT40              ##  Bandwidth is HT40


## * Configuration structure for Protected Management Frame

type
  wifi_pmf_config_t* {.importc: "wifi_pmf_config_t", header: "esp_wifi_types.h",
                      bycopy.} = object
    capable* {.importc: "capable".}: bool ## *< Advertizes support for Protected Management Frame. Device will prefer to connect in PMF mode if other device also advertizes PMF capability.
    required* {.importc: "required".}: bool ## *< Advertizes that Protected Management Frame is required. Device will not associate to non-PMF capable devices.


## * @brief Soft-AP configuration settings for the ESP32

type
  wifi_ap_config_t* {.importc: "wifi_ap_config_t", header: "esp_wifi_types.h", bycopy.} = object
    ssid* {.importc: "ssid".}: array[32, uint8_t] ## *< SSID of ESP32 soft-AP. If ssid_len field is 0, this must be a Null terminated string. Otherwise, length is set according to ssid_len.
    password* {.importc: "password".}: array[64, uint8_t] ## *< Password of ESP32 soft-AP. Null terminated string.
    ssid_len* {.importc: "ssid_len".}: uint8_t ## *< Optional length of SSID field.
    channel* {.importc: "channel".}: uint8_t ## *< Channel of ESP32 soft-AP
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ## *< Auth mode of ESP32 soft-AP. Do not support AUTH_WEP in soft-AP mode
    ssid_hidden* {.importc: "ssid_hidden".}: uint8_t ## *< Broadcast SSID or not, default 0, broadcast the SSID
    max_connection* {.importc: "max_connection".}: uint8_t ## *< Max number of stations allowed to connect in, default 4, max 10
    beacon_interval* {.importc: "beacon_interval".}: uint16_t ## *< Beacon interval, 100 ~ 60000 ms, default 100 ms


## * @brief STA configuration settings for the ESP32

type
  wifi_sta_config_t* {.importc: "wifi_sta_config_t", header: "esp_wifi_types.h",
                      bycopy.} = object
    ssid* {.importc: "ssid".}: array[32, uint8_t] ## *< SSID of target AP. Null terminated string.
    password* {.importc: "password".}: array[64, uint8_t] ## *< Password of target AP. Null terminated string.
    scan_method* {.importc: "scan_method".}: wifi_scan_method_t ## *< do all channel scan or fast scan
    bssid_set* {.importc: "bssid_set".}: bool ## *< whether set MAC address of target AP or not. Generally, station_config.bssid_set needs to be 0; and it needs to be 1 only when users need to check the MAC address of the AP.
    bssid* {.importc: "bssid".}: array[6, uint8_t] ## *< MAC address of target AP
    channel* {.importc: "channel".}: uint8_t ## *< channel of target AP. Set to 1~13 to scan starting from the specified channel before connecting to AP. If the channel of AP is unknown, set it to 0.
    listen_interval* {.importc: "listen_interval".}: uint16_t ## *< Listen interval for ESP32 station to receive beacon when WIFI_PS_MAX_MODEM is set. Units: AP beacon intervals. Defaults to 3 if set to 0.
    sort_method* {.importc: "sort_method".}: wifi_sort_method_t ## *< sort the connect AP in the list by rssi or security mode
    threshold* {.importc: "threshold".}: wifi_scan_threshold_t ## *< When sort_method is set, only APs which have an auth mode that is more secure than the selected auth mode and a signal stronger than the minimum RSSI will be used.
    pmf_cfg* {.importc: "pmf_cfg".}: wifi_pmf_config_t ## *< Configuration for Protected Management Frame. Will be advertized in RSN Capabilities in RSN IE.


## * @brief Configuration data for ESP32 AP or STA.
##
##  The usage of this union (for ap or sta configuration) is determined by the accompanying
##  interface argument passed to esp_wifi_set_config() or esp_wifi_get_config()
##
##

type
  wifi_config_t* {.importc: "wifi_config_t", header: "esp_wifi_types.h", bycopy.} = object {.
      union.}
    ap* {.importc: "ap".}: wifi_ap_config_t ## *< configuration of AP
    sta* {.importc: "sta".}: wifi_sta_config_t ## *< configuration of STA


## * @brief Description of STA associated with AP

type
  wifi_sta_info_t* {.importc: "wifi_sta_info_t", header: "esp_wifi_types.h", bycopy.} = object
    mac* {.importc: "mac".}: array[6, uint8_t] ## *< mac address
    rssi* {.importc: "rssi".}: int8_t ## *< current average rssi of sta connected
    phy_11b* {.importc: "phy_11b".} {.bitsize: 1.}: uint32_t ## *< bit: 0 flag to identify if 11b mode is enabled or not
    phy_11g* {.importc: "phy_11g".} {.bitsize: 1.}: uint32_t ## *< bit: 1 flag to identify if 11g mode is enabled or not
    phy_11n* {.importc: "phy_11n".} {.bitsize: 1.}: uint32_t ## *< bit: 2 flag to identify if 11n mode is enabled or not
    phy_lr* {.importc: "phy_lr".} {.bitsize: 1.}: uint32_t ## *< bit: 3 flag to identify if low rate is enabled or not
    reserved* {.importc: "reserved".} {.bitsize: 28.}: uint32_t ## *< bit: 4..31 reserved


const
  ESP_WIFI_MAX_CONN_NUM* = (10) ## *< max number of stations which can connect to ESP32 soft-AP

## * @brief List of stations associated with the ESP32 Soft-AP

type
  wifi_sta_list_t* {.importc: "wifi_sta_list_t", header: "esp_wifi_types.h", bycopy.} = object
    sta* {.importc: "sta".}: array[ESP_WIFI_MAX_CONN_NUM, wifi_sta_info_t] ## *< station list
    num* {.importc: "num".}: cint ## *< number of stations in the list (other entries are invalid)

  wifi_storage_t* {.size: sizeof(cint).} = enum
    WIFI_STORAGE_FLASH,       ## *< all configuration will store in both memory and flash
    WIFI_STORAGE_RAM          ## *< all configuration will only store in the memory


## *
##  @brief     Vendor Information Element type
##
##  Determines the frame type that the IE will be associated with.
##

type
  wifi_vendor_ie_type_t* {.size: sizeof(cint).} = enum
    WIFI_VND_IE_TYPE_BEACON, WIFI_VND_IE_TYPE_PROBE_REQ,
    WIFI_VND_IE_TYPE_PROBE_RESP, WIFI_VND_IE_TYPE_ASSOC_REQ,
    WIFI_VND_IE_TYPE_ASSOC_RESP


## *
##  @brief     Vendor Information Element index
##
##  Each IE type can have up to two associated vendor ID elements.
##

type
  wifi_vendor_ie_id_t* {.size: sizeof(cint).} = enum
    WIFI_VND_IE_ID_0, WIFI_VND_IE_ID_1


const
  WIFI_VENDOR_IE_ELEMENT_ID* = 0x000000DD

## *
##  @brief Vendor Information Element header
##
##  The first bytes of the Information Element will match this header. Payload follows.
##

type
  vendor_ie_data_t* {.importc: "vendor_ie_data_t", header: "esp_wifi_types.h", bycopy.} = object
    element_id* {.importc: "element_id".}: uint8_t ## *< Should be set to WIFI_VENDOR_IE_ELEMENT_ID (0xDD)
    length* {.importc: "length".}: uint8_t ## *< Length of all bytes in the element data following this field. Minimum 4.
    vendor_oui* {.importc: "vendor_oui".}: array[3, uint8_t] ## *< Vendor identifier (OUI).
    vendor_oui_type* {.importc: "vendor_oui_type".}: uint8_t ## *< Vendor-specific OUI type.
    payload* {.importc: "payload".}: UncheckedArray[uint8_t] ## *< Payload. Length is equal to value in 'length' field, minus 4.


## * @brief Received packet radio metadata header, this is the common header at the beginning of all promiscuous mode RX callback buffers

type
  wifi_pkt_rx_ctrl_t* {.importc: "wifi_pkt_rx_ctrl_t", header: "esp_wifi_types.h",
                       bycopy.} = object
    rssi* {.importc: "rssi".} {.bitsize: 8.}: cint ## *< Received Signal Strength Indicator(RSSI) of packet. unit: dBm
    rate* {.importc: "rate".} {.bitsize: 5.}: cuint ## *< PHY rate encoding of the packet. Only valid for non HT(11bg) packet
    r1* {.importc: "r1".} {.bitsize: 1.}: cuint ## *< reserve
    sig_mode* {.importc: "sig_mode".} {.bitsize: 2.}: cuint ## *< 0: non HT(11bg) packet; 1: HT(11n) packet; 3: VHT(11ac) packet
    r2* {.importc: "r2".} {.bitsize: 16.}: cuint ## *< reserve
    mcs* {.importc: "mcs".} {.bitsize: 7.}: cuint ## *< Modulation Coding Scheme. If is HT(11n) packet, shows the modulation, range from 0 to 76(MSC0 ~ MCS76)
    cwb* {.importc: "cwb".} {.bitsize: 1.}: cuint ## *< Channel Bandwidth of the packet. 0: 20MHz; 1: 40MHz
    r3* {.importc: "r3".} {.bitsize: 16.}: cuint ## *< reserve
    smoothing* {.importc: "smoothing".} {.bitsize: 1.}: cuint ## *< reserve
    not_sounding* {.importc: "not_sounding".} {.bitsize: 1.}: cuint ## *< reserve
    r4* {.importc: "r4".} {.bitsize: 1.}: cuint ## *< reserve
    aggregation* {.importc: "aggregation".} {.bitsize: 1.}: cuint ## *< Aggregation. 0: MPDU packet; 1: AMPDU packet
    stbc* {.importc: "stbc".} {.bitsize: 2.}: cuint ## *< Space Time Block Code(STBC). 0: non STBC packet; 1: STBC packet
    fec_coding* {.importc: "fec_coding".} {.bitsize: 1.}: cuint ## *< Flag is set for 11n packets which are LDPC
    sgi* {.importc: "sgi".} {.bitsize: 1.}: cuint ## *< Short Guide Interval(SGI). 0: Long GI; 1: Short GI
    noise_floor* {.importc: "noise_floor".} {.bitsize: 8.}: cint ## *< noise floor of Radio Frequency Module(RF). unit: 0.25dBm
    ampdu_cnt* {.importc: "ampdu_cnt".} {.bitsize: 8.}: cuint ## *< ampdu cnt
    channel* {.importc: "channel".} {.bitsize: 4.}: cuint ## *< primary channel on which this packet is received
    secondary_channel* {.importc: "secondary_channel".} {.bitsize: 4.}: cuint ## *< secondary channel on which this packet is received. 0: none; 1: above; 2: below
    r5* {.importc: "r5".} {.bitsize: 8.}: cuint ## *< reserve
    timestamp* {.importc: "timestamp".} {.bitsize: 32.}: cuint ## *< timestamp. The local time when this packet is received. It is precise only if modem sleep or light sleep is not enabled. unit: microsecond
    r6* {.importc: "r6".} {.bitsize: 32.}: cuint ## *< reserve
    r7* {.importc: "r7".} {.bitsize: 31.}: cuint ## *< reserve
    ant* {.importc: "ant".} {.bitsize: 1.}: cuint ## *< antenna number from which this packet is received. 0: WiFi antenna 0; 1: WiFi antenna 1
    sig_len* {.importc: "sig_len".} {.bitsize: 12.}: cuint ## *< length of packet including Frame Check Sequence(FCS)
    r8* {.importc: "r8".} {.bitsize: 12.}: cuint ## *< reserve
    rx_state* {.importc: "rx_state".} {.bitsize: 8.}: cuint ## *< state of the packet. 0: no error; others: error numbers which are not public


## * @brief Payload passed to 'buf' parameter of promiscuous mode RX callback.
##

type
  wifi_promiscuous_pkt_t* {.importc: "wifi_promiscuous_pkt_t",
                           header: "esp_wifi_types.h", bycopy.} = object
    rx_ctrl* {.importc: "rx_ctrl".}: wifi_pkt_rx_ctrl_t ## *< metadata header
    payload* {.importc: "payload".}: UncheckedArray[uint8_t] ## *< Data or management payload. Length of payload is described by rx_ctrl.sig_len. Type of content determined by packet type argument of callback.


## *
##  @brief Promiscuous frame type
##
##  Passed to promiscuous mode RX callback to indicate the type of parameter in the buffer.
##
##

type
  wifi_promiscuous_pkt_type_t* {.size: sizeof(cint).} = enum
    WIFI_PKT_MGMT,            ## *< Management frame, indicates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_CTRL,            ## *< Control frame, indicates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_DATA,            ## *< Data frame, indiciates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_MISC             ## *< Other type, such as MIMO etc. 'buf' argument is wifi_promiscuous_pkt_t but the payload is zero length.


const
  WIFI_PROMIS_FILTER_MASK_ALL* = (0xFFFFFFFF) ## *< filter all packets
  WIFI_PROMIS_FILTER_MASK_MGMT* = (1) ## *< filter the packets with type of WIFI_PKT_MGMT
  WIFI_PROMIS_FILTER_MASK_CTRL* = (1 shl 1) ## *< filter the packets with type of WIFI_PKT_CTRL
  WIFI_PROMIS_FILTER_MASK_DATA* = (1 shl 2) ## *< filter the packets with type of WIFI_PKT_DATA
  WIFI_PROMIS_FILTER_MASK_MISC* = (1 shl 3) ## *< filter the packets with type of WIFI_PKT_MISC
  WIFI_PROMIS_FILTER_MASK_DATA_MPDU* = (1 shl 4) ## *< filter the MPDU which is a kind of WIFI_PKT_DATA
  WIFI_PROMIS_FILTER_MASK_DATA_AMPDU* = (1 shl 5) ## *< filter the AMPDU which is a kind of WIFI_PKT_DATA
  WIFI_PROMIS_CTRL_FILTER_MASK_ALL* = (0xFF800000) ## *< filter all control packets
  WIFI_PROMIS_CTRL_FILTER_MASK_WRAPPER* = (1 shl 23) ## *< filter the control packets with subtype of Control Wrapper
  WIFI_PROMIS_CTRL_FILTER_MASK_BAR* = (1 shl 24) ## *< filter the control packets with subtype of Block Ack Request
  WIFI_PROMIS_CTRL_FILTER_MASK_BA* = (1 shl 25) ## *< filter the control packets with subtype of Block Ack
  WIFI_PROMIS_CTRL_FILTER_MASK_PSPOLL* = (1 shl 26) ## *< filter the control packets with subtype of PS-Poll
  WIFI_PROMIS_CTRL_FILTER_MASK_RTS* = (1 shl 27) ## *< filter the control packets with subtype of RTS
  WIFI_PROMIS_CTRL_FILTER_MASK_CTS* = (1 shl 28) ## *< filter the control packets with subtype of CTS
  WIFI_PROMIS_CTRL_FILTER_MASK_ACK* = (1 shl 29) ## *< filter the control packets with subtype of ACK
  WIFI_PROMIS_CTRL_FILTER_MASK_CFEND* = (1 shl 30) ## *< filter the control packets with subtype of CF-END
  WIFI_PROMIS_CTRL_FILTER_MASK_CFENDACK* = (1 shl 31) ## *< filter the control packets with subtype of CF-END+CF-ACK

## * @brief Mask for filtering different packet types in promiscuous mode.

type
  wifi_promiscuous_filter_t* {.importc: "wifi_promiscuous_filter_t",
                              header: "esp_wifi_types.h", bycopy.} = object
    filter_mask* {.importc: "filter_mask".}: uint32_t ## *< OR of one or more filter values WIFI_PROMIS_FILTER_*


const
  WIFI_EVENT_MASK_ALL* = (0xFFFFFFFF) ## *< mask all WiFi events
  WIFI_EVENT_MASK_NONE* = (0)   ## *< mask none of the WiFi events
  WIFI_EVENT_MASK_AP_PROBEREQRECVED* = (BIT(0)) ## *< mask SYSTEM_EVENT_AP_PROBEREQRECVED event

## *
##  @brief Channel state information(CSI) configuration type
##
##

type
  wifi_csi_config_t* {.importc: "wifi_csi_config_t", header: "esp_wifi_types.h",
                      bycopy.} = object
    lltf_en* {.importc: "lltf_en".}: bool ## *< enable to receive legacy long training field(lltf) data. Default enabled
    htltf_en* {.importc: "htltf_en".}: bool ## *< enable to receive HT long training field(htltf) data. Default enabled
    stbc_htltf2_en* {.importc: "stbc_htltf2_en".}: bool ## *< enable to receive space time block code HT long training field(stbc-htltf2) data. Default enabled
    ltf_merge_en* {.importc: "ltf_merge_en".}: bool ## *< enable to generate htlft data by averaging lltf and ht_ltf data when receiving HT packet. Otherwise, use ht_ltf data directly. Default enabled
    channel_filter_en* {.importc: "channel_filter_en".}: bool ## *< enable to turn on channel filter to smooth adjacent sub-carrier. Disable it to keep independence of adjacent sub-carrier. Default enabled
    manu_scale* {.importc: "manu_scale".}: bool ## *< manually scale the CSI data by left shifting or automatically scale the CSI data. If set true, please set the shift bits. false: automatically. true: manually. Default false
    shift* {.importc: "shift".}: uint8_t ## *< manually left shift bits of the scale of the CSI data. The range of the left shift bits is 0~15


## *
##  @brief CSI data type
##
##

type
  wifi_csi_info_t* {.importc: "wifi_csi_info_t", header: "esp_wifi_types.h", bycopy.} = object
    rx_ctrl* {.importc: "rx_ctrl".}: wifi_pkt_rx_ctrl_t ## *< received packet radio metadata header of the CSI data
    mac* {.importc: "mac".}: array[6, uint8_t] ## *< source MAC address of the CSI data
    first_word_invalid* {.importc: "first_word_invalid".}: bool ## *< first four bytes of the CSI data is invalid or not
    buf* {.importc: "buf".}: ptr int8_t ## *< buffer of CSI data
    len* {.importc: "len".}: uint16_t ## *< length of CSI data


## *
##  @brief WiFi GPIO configuration for antenna selection
##
##

type
  wifi_ant_gpio_t* {.importc: "wifi_ant_gpio_t", header: "esp_wifi_types.h", bycopy.} = object
    gpio_select* {.importc: "gpio_select".} {.bitsize: 1.}: uint8_t ## *< Whether this GPIO is connected to external antenna switch
    gpio_num* {.importc: "gpio_num".} {.bitsize: 7.}: uint8_t ## *< The GPIO number that connects to external antenna switch


## *
##  @brief WiFi GPIOs configuration for antenna selection
##
##

type
  wifi_ant_gpio_config_t* {.importc: "wifi_ant_gpio_config_t",
                           header: "esp_wifi_types.h", bycopy.} = object
    gpio_cfg* {.importc: "gpio_cfg".}: array[4, wifi_ant_gpio_t] ## *< The configurations of GPIOs that connect to external antenna switch


## *
##  @brief WiFi antenna mode
##
##

type
  wifi_ant_mode_t* {.size: sizeof(cint).} = enum
    WIFI_ANT_MODE_ANT0,       ## *< Enable WiFi antenna 0 only
    WIFI_ANT_MODE_ANT1,       ## *< Enable WiFi antenna 1 only
    WIFI_ANT_MODE_AUTO,       ## *< Enable WiFi antenna 0 and 1, automatically select an antenna
    WIFI_ANT_MODE_MAX         ## *< Invalid WiFi enabled antenna


## *
##  @brief WiFi antenna configuration
##
##

type
  wifi_ant_config_t* {.importc: "wifi_ant_config_t", header: "esp_wifi_types.h",
                      bycopy.} = object
    rx_ant_mode* {.importc: "rx_ant_mode".}: wifi_ant_mode_t ## *< WiFi antenna mode for receiving
    rx_ant_default* {.importc: "rx_ant_default".}: wifi_ant_t ## *< Default antenna mode for receiving, it's ignored if rx_ant_mode is not WIFI_ANT_MODE_AUTO
    tx_ant_mode* {.importc: "tx_ant_mode".}: wifi_ant_mode_t ## *< WiFi antenna mode for transmission, it can be set to WIFI_ANT_MODE_AUTO only if rx_ant_mode is set to WIFI_ANT_MODE_AUTO
    enabled_ant0* {.importc: "enabled_ant0".} {.bitsize: 4.}: uint8_t ## *< Index (in antenna GPIO configuration) of enabled WIFI_ANT_MODE_ANT0
    enabled_ant1* {.importc: "enabled_ant1".} {.bitsize: 4.}: uint8_t ## *< Index (in antenna GPIO configuration) of enabled WIFI_ANT_MODE_ANT1


## *
##  @brief WiFi PHY rate encodings
##
##

type
  wifi_phy_rate_t* {.size: sizeof(cint).} = enum
    WIFI_PHY_RATE_1M_L = 0x00000000, ## *< 1 Mbps with long preamble
    WIFI_PHY_RATE_2M_L = 0x00000001, ## *< 2 Mbps with long preamble
    WIFI_PHY_RATE_5M_L = 0x00000002, ## *< 5.5 Mbps with long preamble
    WIFI_PHY_RATE_11M_L = 0x00000003, ## *< 11 Mbps with long preamble
    WIFI_PHY_RATE_2M_S = 0x00000005, ## *< 2 Mbps with short preamble
    WIFI_PHY_RATE_5M_S = 0x00000006, ## *< 5.5 Mbps with short preamble
    WIFI_PHY_RATE_11M_S = 0x00000007, ## *< 11 Mbps with short preamble
    WIFI_PHY_RATE_48M = 0x00000008, ## *< 48 Mbps
    WIFI_PHY_RATE_24M = 0x00000009, ## *< 24 Mbps
    WIFI_PHY_RATE_12M = 0x0000000A, ## *< 12 Mbps
    WIFI_PHY_RATE_6M = 0x0000000B, ## *< 6 Mbps
    WIFI_PHY_RATE_54M = 0x0000000C, ## *< 54 Mbps
    WIFI_PHY_RATE_36M = 0x0000000D, ## *< 36 Mbps
    WIFI_PHY_RATE_18M = 0x0000000E, ## *< 18 Mbps
    WIFI_PHY_RATE_9M = 0x0000000F, ## *< 9 Mbps
    WIFI_PHY_RATE_MCS0_LGI = 0x00000010, ## *< MCS0 with long GI, 6.5 Mbps for 20MHz, 13.5 Mbps for 40MHz
    WIFI_PHY_RATE_MCS1_LGI = 0x00000011, ## *< MCS1 with long GI, 13 Mbps for 20MHz, 27 Mbps for 40MHz
    WIFI_PHY_RATE_MCS2_LGI = 0x00000012, ## *< MCS2 with long GI, 19.5 Mbps for 20MHz, 40.5 Mbps for 40MHz
    WIFI_PHY_RATE_MCS3_LGI = 0x00000013, ## *< MCS3 with long GI, 26 Mbps for 20MHz, 54 Mbps for 40MHz
    WIFI_PHY_RATE_MCS4_LGI = 0x00000014, ## *< MCS4 with long GI, 39 Mbps for 20MHz, 81 Mbps for 40MHz
    WIFI_PHY_RATE_MCS5_LGI = 0x00000015, ## *< MCS5 with long GI, 52 Mbps for 20MHz, 108 Mbps for 40MHz
    WIFI_PHY_RATE_MCS6_LGI = 0x00000016, ## *< MCS6 with long GI, 58.5 Mbps for 20MHz, 121.5 Mbps for 40MHz
    WIFI_PHY_RATE_MCS7_LGI = 0x00000017, ## *< MCS7 with long GI, 65 Mbps for 20MHz, 135 Mbps for 40MHz
    WIFI_PHY_RATE_MCS0_SGI = 0x00000018, ## *< MCS0 with short GI, 7.2 Mbps for 20MHz, 15 Mbps for 40MHz
    WIFI_PHY_RATE_MCS1_SGI = 0x00000019, ## *< MCS1 with short GI, 14.4 Mbps for 20MHz, 30 Mbps for 40MHz
    WIFI_PHY_RATE_MCS2_SGI = 0x0000001A, ## *< MCS2 with short GI, 21.7 Mbps for 20MHz, 45 Mbps for 40MHz
    WIFI_PHY_RATE_MCS3_SGI = 0x0000001B, ## *< MCS3 with short GI, 28.9 Mbps for 20MHz, 60 Mbps for 40MHz
    WIFI_PHY_RATE_MCS4_SGI = 0x0000001C, ## *< MCS4 with short GI, 43.3 Mbps for 20MHz, 90 Mbps for 40MHz
    WIFI_PHY_RATE_MCS5_SGI = 0x0000001D, ## *< MCS5 with short GI, 57.8 Mbps for 20MHz, 120 Mbps for 40MHz
    WIFI_PHY_RATE_MCS6_SGI = 0x0000001E, ## *< MCS6 with short GI, 65 Mbps for 20MHz, 135 Mbps for 40MHz
    WIFI_PHY_RATE_MCS7_SGI = 0x0000001F, ## *< MCS7 with short GI, 72.2 Mbps for 20MHz, 150 Mbps for 40MHz
    WIFI_PHY_RATE_LORA_250K = 0x00000029, ## *< 250 Kbps
    WIFI_PHY_RATE_LORA_500K = 0x0000002A, ## *< 500 Kbps
    WIFI_PHY_RATE_MAX


## * WiFi event declarations

type
  wifi_event_t* {.size: sizeof(cint).} = enum
    WIFI_EVENT_WIFI_READY = 0,  ## *< ESP32 WiFi ready
    WIFI_EVENT_SCAN_DONE,     ## *< ESP32 finish scanning AP
    WIFI_EVENT_STA_START,     ## *< ESP32 station start
    WIFI_EVENT_STA_STOP,      ## *< ESP32 station stop
    WIFI_EVENT_STA_CONNECTED, ## *< ESP32 station connected to AP
    WIFI_EVENT_STA_DISCONNECTED, ## *< ESP32 station disconnected from AP
    WIFI_EVENT_STA_AUTHMODE_CHANGE, ## *< the auth mode of AP connected by ESP32 station changed
    WIFI_EVENT_STA_WPS_ER_SUCCESS, ## *< ESP32 station wps succeeds in enrollee mode
    WIFI_EVENT_STA_WPS_ER_FAILED, ## *< ESP32 station wps fails in enrollee mode
    WIFI_EVENT_STA_WPS_ER_TIMEOUT, ## *< ESP32 station wps timeout in enrollee mode
    WIFI_EVENT_STA_WPS_ER_PIN, ## *< ESP32 station wps pin code in enrollee mode
    WIFI_EVENT_STA_WPS_ER_PBC_OVERLAP, ## *< ESP32 station wps overlap in enrollee mode
    WIFI_EVENT_AP_START,      ## *< ESP32 soft-AP start
    WIFI_EVENT_AP_STOP,       ## *< ESP32 soft-AP stop
    WIFI_EVENT_AP_STACONNECTED, ## *< a station connected to ESP32 soft-AP
    WIFI_EVENT_AP_STADISCONNECTED, ## *< a station disconnected from ESP32 soft-AP
    WIFI_EVENT_AP_PROBEREQRECVED ## *< Receive probe request packet in soft-AP interface


## * @cond *
## * @brief WiFi event base declaration

ESP_EVENT_DECLARE_BASE(WIFI_EVENT)
## * @endcond *
## * Argument structure for WIFI_EVENT_SCAN_DONE event

type
  wifi_event_sta_scan_done_t* {.importc: "wifi_event_sta_scan_done_t",
                               header: "esp_wifi_types.h", bycopy.} = object
    status* {.importc: "status".}: uint32_t ## *< status of scanning APs: 0 — success, 1 - failure
    number* {.importc: "number".}: uint8_t ## *< number of scan results
    scan_id* {.importc: "scan_id".}: uint8_t ## *< scan sequence number, used for block scan


## * Argument structure for WIFI_EVENT_STA_CONNECTED event

type
  wifi_event_sta_connected_t* {.importc: "wifi_event_sta_connected_t",
                               header: "esp_wifi_types.h", bycopy.} = object
    ssid* {.importc: "ssid".}: array[32, uint8_t] ## *< SSID of connected AP
    ssid_len* {.importc: "ssid_len".}: uint8_t ## *< SSID length of connected AP
    bssid* {.importc: "bssid".}: array[6, uint8_t] ## *< BSSID of connected AP
    channel* {.importc: "channel".}: uint8_t ## *< channel of connected AP
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ## *< authentication mode used by AP


## * Argument structure for WIFI_EVENT_STA_DISCONNECTED event

type
  wifi_event_sta_disconnected_t* {.importc: "wifi_event_sta_disconnected_t",
                                  header: "esp_wifi_types.h", bycopy.} = object
    ssid* {.importc: "ssid".}: array[32, uint8_t] ## *< SSID of disconnected AP
    ssid_len* {.importc: "ssid_len".}: uint8_t ## *< SSID length of disconnected AP
    bssid* {.importc: "bssid".}: array[6, uint8_t] ## *< BSSID of disconnected AP
    reason* {.importc: "reason".}: uint8_t ## *< reason of disconnection


## * Argument structure for WIFI_EVENT_STA_AUTHMODE_CHANGE event

type
  wifi_event_sta_authmode_change_t* {.importc: "wifi_event_sta_authmode_change_t",
                                     header: "esp_wifi_types.h", bycopy.} = object
    old_mode* {.importc: "old_mode".}: wifi_auth_mode_t ## *< the old auth mode of AP
    new_mode* {.importc: "new_mode".}: wifi_auth_mode_t ## *< the new auth mode of AP


## * Argument structure for WIFI_EVENT_STA_WPS_ER_PIN event

type
  wifi_event_sta_wps_er_pin_t* {.importc: "wifi_event_sta_wps_er_pin_t",
                                header: "esp_wifi_types.h", bycopy.} = object
    pin_code* {.importc: "pin_code".}: array[8, uint8_t] ## *< PIN code of station in enrollee mode


## * Argument structure for WIFI_EVENT_STA_WPS_ER_FAILED event

type
  wifi_event_sta_wps_fail_reason_t* {.size: sizeof(cint).} = enum
    WPS_FAIL_REASON_NORMAL = 0, ## *< ESP32 WPS normal fail reason
    WPS_FAIL_REASON_RECV_M2D, ## *< ESP32 WPS receive M2D frame
    WPS_FAIL_REASON_MAX


## * Argument structure for WIFI_EVENT_AP_STACONNECTED event

type
  wifi_event_ap_staconnected_t* {.importc: "wifi_event_ap_staconnected_t",
                                 header: "esp_wifi_types.h", bycopy.} = object
    mac* {.importc: "mac".}: array[6, uint8_t] ## *< MAC address of the station connected to ESP32 soft-AP
    aid* {.importc: "aid".}: uint8_t ## *< the aid that ESP32 soft-AP gives to the station connected to


## * Argument structure for WIFI_EVENT_AP_STADISCONNECTED event

type
  wifi_event_ap_stadisconnected_t* {.importc: "wifi_event_ap_stadisconnected_t",
                                    header: "esp_wifi_types.h", bycopy.} = object
    mac* {.importc: "mac".}: array[6, uint8_t] ## *< MAC address of the station disconnects to ESP32 soft-AP
    aid* {.importc: "aid".}: uint8_t ## *< the aid that ESP32 soft-AP gave to the station disconnects to


## * Argument structure for WIFI_EVENT_AP_PROBEREQRECVED event

type
  wifi_event_ap_probe_req_rx_t* {.importc: "wifi_event_ap_probe_req_rx_t",
                                 header: "esp_wifi_types.h", bycopy.} = object
    rssi* {.importc: "rssi".}: cint ## *< Received probe request signal strength
    mac* {.importc: "mac".}: array[6, uint8_t] ## *< MAC address of the station which send probe request

