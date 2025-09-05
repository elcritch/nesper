

import ../esp_event

const hdr = "esp_wifi_types_generic.h"

let
  WIFI_AP_DEFAULT_MAX_IDLE_PERIOD* {.importc: "WIFI_AP_DEFAULT_MAX_IDLE_PERIOD", header: hdr.}: cint ##
                                         ##  SPDX-FileCopyrightText: 2015-2025 Espressif Systems (Shanghai) CO LTD
                                         ##
                                         ##  SPDX-License-Identifier: Apache-2.0
                                         ##

type

  wifi_mode_t* {.size: sizeof(cint).} = enum ##
                                              ##  @brief Wi-Fi mode type
                                              ##
    WIFI_MODE_NULL = 0,     ## < Null mode
    WIFI_MODE_STA,          ## < Wi-Fi station mode
    WIFI_MODE_AP,           ## < Wi-Fi soft-AP mode
    WIFI_MODE_APSTA,        ## < Wi-Fi station + soft-AP mode
    WIFI_MODE_NAN,          ## < Wi-Fi NAN mode
    WIFI_MODE_MAX


type

  wifi_interface_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi interface type
                              ##
    WIFI_IF_STA, ## < Station interface
    WIFI_IF_AP, ## < Soft-AP interface
    WIFI_IF_NAN ## < NAN interface

  wifi_action_tx_t* {.size: sizeof(cint).} = enum
    WIFI_OFFCHAN_TX_CANCEL, ## < Cancel off-channel transmission
    WIFI_OFFCHAN_TX_REQ      ## < Request off-channel transmission

  wifi_roc_t* {.size: sizeof(cint).} = enum
    WIFI_ROC_CANCEL,        ## < Cancel remain on channel
    WIFI_ROC_REQ             ## < Request remain on channel


type

  wifi_country_policy_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi country policy
                              ##
    WIFI_COUNTRY_POLICY_AUTO, ## < Country policy is auto, use the country info of AP to which the station is connected
    WIFI_COUNTRY_POLICY_MANUAL ## < Country policy is manual, always use the configured country info


type

  wifi_country_t* {.importc: "wifi_country_t",
                    header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Structure describing Wi-Fi country-based regional restrictions.
                              ##
    cc* {.importc: "cc".}: array[3, char] ## < Country code string
    schan* {.importc: "schan".}: uint8 ## < Start channel of the allowed 2.4GHz Wi-Fi channels
    nchan* {.importc: "nchan".}: uint8 ## < Total channel number of the allowed 2.4GHz Wi-Fi channels
    max_tx_power* {.importc: "max_tx_power".}: int8 ##
                              ## < This field is used for getting Wi-Fi maximum transmitting power, call esp_wifi_set_max_tx_power to set the maximum transmitting power.
    policy* {.importc: "policy".}: wifi_country_policy_t ##
                              ## < Country policy
    when defined(CONFIG_SOC_WIFI_SUPPORT_5G):
      wifi_5g_channel_mask* {.importc: "wifi_5g_channel_mask".}: uint32
      ## < A bitmask representing the allowed 5GHz Wi-Fi channels.
      ##                                                       Each bit in the mask corresponds to a specific channel as wifi_5g_channel_bit_t shown.
      ##                                                       Bitmask set to 0 indicates 5GHz channels are allowed according to local regulatory rules.
      ##                                                       Please note that configured bitmask takes effect only when policy is manual.


  wifi_auth_mode_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi authmode type
                              ##  Strength of authmodes
                              ##  Personal Networks   : OPEN < WEP < WPA_PSK < OWE < WPA2_PSK = WPA_WPA2_PSK < WAPI_PSK < WPA3_PSK = WPA2_WPA3_PSK = DPP
                              ##  Enterprise Networks : WIFI_AUTH_WPA_ENTERPRISE < WIFI_AUTH_WPA2_ENTERPRISE < WIFI_AUTH_WPA3_ENTERPRISE = WIFI_AUTH_WPA2_WPA3_ENTERPRISE < WIFI_AUTH_WPA3_ENT_192
                              ##
    WIFI_AUTH_OPEN = 0,     ## < Authenticate mode : open
    WIFI_AUTH_WEP,          ## < Authenticate mode : WEP
    WIFI_AUTH_WPA_PSK,      ## < Authenticate mode : WPA_PSK
    WIFI_AUTH_WPA2_PSK,     ## < Authenticate mode : WPA2_PSK
    WIFI_AUTH_WPA_WPA2_PSK, ## < Authenticate mode : WPA_WPA2_PSK
    WIFI_AUTH_ENTERPRISE,   ## < Authenticate mode : Wi-Fi EAP security, treated the same as WIFI_AUTH_WPA2_ENTERPRISE
    WIFI_AUTH_WPA3_PSK,     ## < Authenticate mode : WPA3_PSK
    WIFI_AUTH_WPA2_WPA3_PSK, ## < Authenticate mode : WPA2_WPA3_PSK
    WIFI_AUTH_WAPI_PSK,     ## < Authenticate mode : WAPI_PSK
    WIFI_AUTH_OWE,          ## < Authenticate mode : OWE
    WIFI_AUTH_WPA3_ENT_192, ## < Authenticate mode : WPA3_ENT_SUITE_B_192_BIT
    WIFI_AUTH_WPA3_EXT_PSK, ## < This authentication mode will yield same result as WIFI_AUTH_WPA3_PSK and not recommended to be used. It will be deprecated in future, please use WIFI_AUTH_WPA3_PSK instead.
    WIFI_AUTH_WPA3_EXT_PSK_MIXED_MODE, ## < This authentication mode will yield same result as WIFI_AUTH_WPA3_PSK and not recommended to be used. It will be deprecated in future, please use WIFI_AUTH_WPA3_PSK instead.
    WIFI_AUTH_DPP,          ## < Authenticate mode : DPP
    WIFI_AUTH_WPA3_ENTERPRISE, ## < Authenticate mode : WPA3-Enterprise Only Mode
    WIFI_AUTH_WPA2_WPA3_ENTERPRISE, ## < Authenticate mode : WPA3-Enterprise Transition Mode
    WIFI_AUTH_WPA_ENTERPRISE, ## < Authenticate mode : WPA-Enterprise security
    WIFI_AUTH_MAX

const
  WIFI_AUTH_WPA2_ENTERPRISE* = WIFI_AUTH_ENTERPRISE

type

  wifi_err_reason_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi disconnection reason codes
                              ##
                              ##  These reason codes are used to indicate the cause of disconnection.
                              ##
    WIFI_REASON_UNSPECIFIED = 1, ## < Unspecified reason
    WIFI_REASON_AUTH_EXPIRE = 2, ## < Authentication expired
    WIFI_REASON_AUTH_LEAVE = 3, ## < Deauthentication due to leaving
    WIFI_REASON_ASSOC_EXPIRE = 4, ## < Deprecated, will be removed in next IDF major release
    WIFI_REASON_ASSOC_TOOMANY = 5, ## < Too many associated stations
    WIFI_REASON_NOT_AUTHED = 6, ## < Deprecated, will be removed in next IDF major release
    WIFI_REASON_NOT_ASSOCED = 7, ## < Deprecated, will be removed in next IDF major release
    WIFI_REASON_ASSOC_LEAVE = 8, ## < Deassociated due to leaving
    WIFI_REASON_ASSOC_NOT_AUTHED = 9, ## < Association but not authenticated
    WIFI_REASON_DISASSOC_PWRCAP_BAD = 10, ## < Disassociated due to poor power capability
    WIFI_REASON_DISASSOC_SUPCHAN_BAD = 11, ## < Disassociated due to unsupported channel
    WIFI_REASON_BSS_TRANSITION_DISASSOC = 12, ## < Disassociated due to BSS transition
    WIFI_REASON_IE_INVALID = 13, ## < Invalid Information Element (IE)
    WIFI_REASON_MIC_FAILURE = 14, ## < MIC failure
    WIFI_REASON_4WAY_HANDSHAKE_TIMEOUT = 15, ## < 4-way handshake timeout
    WIFI_REASON_GROUP_KEY_UPDATE_TIMEOUT = 16, ## < Group key update timeout
    WIFI_REASON_IE_IN_4WAY_DIFFERS = 17, ## < IE differs in 4-way handshake
    WIFI_REASON_GROUP_CIPHER_INVALID = 18, ## < Invalid group cipher
    WIFI_REASON_PAIRWISE_CIPHER_INVALID = 19, ## < Invalid pairwise cipher
    WIFI_REASON_AKMP_INVALID = 20, ## < Invalid AKMP
    WIFI_REASON_UNSUPP_RSN_IE_VERSION = 21, ## < Unsupported RSN IE version
    WIFI_REASON_INVALID_RSN_IE_CAP = 22, ## < Invalid RSN IE capabilities
    WIFI_REASON_802_1X_AUTH_FAILED = 23, ## < 802.1X authentication failed
    WIFI_REASON_CIPHER_SUITE_REJECTED = 24, ## < Cipher suite rejected
    WIFI_REASON_TDLS_PEER_UNREACHABLE = 25, ## < TDLS peer unreachable
    WIFI_REASON_TDLS_UNSPECIFIED = 26, ## < TDLS unspecified
    WIFI_REASON_SSP_REQUESTED_DISASSOC = 27, ## < SSP requested disassociation
    WIFI_REASON_NO_SSP_ROAMING_AGREEMENT = 28, ## < No SSP roaming agreement
    WIFI_REASON_BAD_CIPHER_OR_AKM = 29, ## < Bad cipher or AKM
    WIFI_REASON_NOT_AUTHORIZED_THIS_LOCATION = 30, ##
                              ## < Not authorized in this location
    WIFI_REASON_SERVICE_CHANGE_PERCLUDES_TS = 31, ##
                              ## < Service change precludes TS
    WIFI_REASON_UNSPECIFIED_QOS = 32, ## < Unspecified QoS reason
    WIFI_REASON_NOT_ENOUGH_BANDWIDTH = 33, ## < Not enough bandwidth
    WIFI_REASON_MISSING_ACKS = 34, ## < Missing ACKs
    WIFI_REASON_EXCEEDED_TXOP = 35, ## < Exceeded TXOP
    WIFI_REASON_STA_LEAVING = 36, ## < Station leaving
    WIFI_REASON_END_BA = 37, ## < End of Block Ack (BA)
    WIFI_REASON_UNKNOWN_BA = 38, ## < Unknown Block Ack (BA)
    WIFI_REASON_TIMEOUT = 39, ## < Timeout
    WIFI_REASON_PEER_INITIATED = 46, ## < Peer initiated disassociation
    WIFI_REASON_AP_INITIATED = 47, ## < AP initiated disassociation
    WIFI_REASON_INVALID_FT_ACTION_FRAME_COUNT = 48, ##
                              ## < Invalid FT action frame count
    WIFI_REASON_INVALID_PMKID = 49, ## < Invalid PMKID
    WIFI_REASON_INVALID_MDE = 50, ## < Invalid MDE
    WIFI_REASON_INVALID_FTE = 51, ## < Invalid FTE
    WIFI_REASON_TRANSMISSION_LINK_ESTABLISH_FAILED = 67, ##
                              ## < Transmission link establishment failed
    WIFI_REASON_ALTERATIVE_CHANNEL_OCCUPIED = 68, ##
                              ## < Alternative channel occupied
    WIFI_REASON_BEACON_TIMEOUT = 200, ## < Beacon timeout
    WIFI_REASON_NO_AP_FOUND = 201, ## < No AP found
    WIFI_REASON_AUTH_FAIL = 202, ## < Authentication failed
    WIFI_REASON_ASSOC_FAIL = 203, ## < Association failed
    WIFI_REASON_HANDSHAKE_TIMEOUT = 204, ## < Handshake timeout
    WIFI_REASON_CONNECTION_FAIL = 205, ## < Connection failed
    WIFI_REASON_AP_TSF_RESET = 206, ## < AP TSF reset
    WIFI_REASON_ROAMING = 207, ## < Roaming
    WIFI_REASON_ASSOC_COMEBACK_TIME_TOO_LONG = 208, ##
                              ## < Association comeback time too long
    WIFI_REASON_SA_QUERY_TIMEOUT = 209, ## < SA query timeout
    WIFI_REASON_NO_AP_FOUND_W_COMPATIBLE_SECURITY = 210, ##
                              ## < No AP found with compatible security
    WIFI_REASON_NO_AP_FOUND_IN_AUTHMODE_THRESHOLD = 211, ##
                              ## < No AP found in auth mode threshold
    WIFI_REASON_NO_AP_FOUND_IN_RSSI_THRESHOLD = 212 ##
                              ## < No AP found in RSSI threshold

const
  WIFI_REASON_DISASSOC_DUE_TO_INACTIVITY = WIFI_REASON_ASSOC_EXPIRE
  WIFI_REASON_CLASS2_FRAME_FROM_NONAUTH_STA = WIFI_REASON_NOT_AUTHED
  WIFI_REASON_CLASS3_FRAME_FROM_NONASSOC_STA = WIFI_REASON_NOT_ASSOCED

type

  wifi_second_chan_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi second channel type
                              ##
    WIFI_SECOND_CHAN_NONE = 0, ## < The channel width is HT20
    WIFI_SECOND_CHAN_ABOVE, ## < The channel width is HT40 and the secondary channel is above the primary channel
    WIFI_SECOND_CHAN_BELOW   ## < The channel width is HT40 and the secondary channel is below the primary channel

let
  WIFI_ACTIVE_SCAN_MIN_DEFAULT_TIME* {.importc, header: hdr.}: cint
  WIFI_ACTIVE_SCAN_MAX_DEFAULT_TIME* {.importc, header: hdr.}: cint
  WIFI_PASSIVE_SCAN_DEFAULT_TIME* {.importc, header: hdr.}: cint
  WIFI_SCAN_HOME_CHANNEL_DWELL_DEFAULT_TIME* {.importc, header: hdr.}: cint

type

  wifi_scan_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi scan type
                              ##
    WIFI_SCAN_TYPE_ACTIVE = 0, ## < Active scan
    WIFI_SCAN_TYPE_PASSIVE   ## < Passive scan


type

  wifi_active_scan_time_t* {.importc: "wifi_active_scan_time_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Range of active scan times per channel
                              ##
    min* {.importc: "min".}: uint32 ## < Minimum active scan time per channel, units: millisecond
    max* {.importc: "max".}: uint32
    ## < Maximum active scan time per channel, units: millisecond, values above 1500 ms may
    ##                                           cause station to disconnect from AP and are not recommended.


  wifi_scan_time_t* {.importc: "wifi_scan_time_t",
                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Aggregate of active & passive scan time per channel
                              ##
    active* {.importc: "active".}: wifi_active_scan_time_t ##
                              ## < Active scan time per channel, units: millisecond.
    passive* {.importc: "passive".}: uint32
    ## < Passive scan time per channel, units: millisecond, values above 1500 ms may
    ##                                           cause station to disconnect from AP and are not recommended.


  wifi_scan_channel_bitmap_t* {.importc: "wifi_scan_channel_bitmap_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Channel bitmap for setting specific channels to be scanned
                              ##
    ghz_2_channels* {.importc: "ghz_2_channels".}: uint16 ##
                              ## < Represents 2.4 GHz channels, that bits can be set as wifi_2g_channel_bit_t shown.
    ghz_5_channels* {.importc: "ghz_5_channels".}: uint32
    ## < Represents 5 GHz channels, that bits can be set as wifi_5g_channel_bit_t shown.


  wifi_scan_config_t* {.importc: "wifi_scan_config_t",
                        header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Parameters for an SSID scan
                              ##
    ssid* {.importc: "ssid".}: ptr uint8 ## < SSID of AP
    bssid* {.importc: "bssid".}: ptr uint8 ## < MAC address of AP
    channel* {.importc: "channel".}: uint8 ## < Channel, scan the specific channel
    show_hidden* {.importc: "show_hidden".}: bool ## < Enable it to scan AP whose SSID is hidden
    scan_type* {.importc: "scan_type".}: wifi_scan_type_t ##
                              ## < Scan type, active or passive
    scan_time* {.importc: "scan_time".}: wifi_scan_time_t ##
                              ## < Scan time per channel
    home_chan_dwell_time* {.importc: "home_chan_dwell_time".}: uint8 ##
                              ## < Time spent at home channel between scanning consecutive channels.
    channel_bitmap* {.importc: "channel_bitmap".}: wifi_scan_channel_bitmap_t ##
                              ## < Channel bitmap for setting specific channels to be scanned.
                              ##                                                             Please note that the 'channel' parameter above needs to be set to 0 to allow scanning by bitmap.
                              ##                                                             Also, note that only allowed channels configured by wifi_country_t can be scanned.
    coex_background_scan* {.importc: "coex_background_scan".}: bool
    ## < Enable it to scan return home channel under coexist


  wifi_scan_default_params_t* {.importc: "wifi_scan_default_params_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Parameters default scan configurations
                              ##
    scan_time* {.importc: "scan_time".}: wifi_scan_time_t ##
                              ## < Scan time per channel
    home_chan_dwell_time* {.importc: "home_chan_dwell_time".}: uint8
    ## < Time spent at home channel between scanning consecutive channels.


  wifi_cipher_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi cipher type
                              ##
    WIFI_CIPHER_TYPE_NONE = 0, ## < The cipher type is none
    WIFI_CIPHER_TYPE_WEP40, ## < The cipher type is WEP40
    WIFI_CIPHER_TYPE_WEP104, ## < The cipher type is WEP104
    WIFI_CIPHER_TYPE_TKIP,  ## < The cipher type is TKIP
    WIFI_CIPHER_TYPE_CCMP,  ## < The cipher type is CCMP
    WIFI_CIPHER_TYPE_TKIP_CCMP, ## < The cipher type is TKIP and CCMP
    WIFI_CIPHER_TYPE_AES_CMAC128, ## < The cipher type is AES-CMAC-128
    WIFI_CIPHER_TYPE_SMS4,  ## < The cipher type is SMS4
    WIFI_CIPHER_TYPE_GCMP,  ## < The cipher type is GCMP
    WIFI_CIPHER_TYPE_GCMP256, ## < The cipher type is GCMP-256
    WIFI_CIPHER_TYPE_AES_GMAC128, ## < The cipher type is AES-GMAC-128
    WIFI_CIPHER_TYPE_AES_GMAC256, ## < The cipher type is AES-GMAC-256
    WIFI_CIPHER_TYPE_UNKNOWN ## < The cipher type is unknown


type

  wifi_bandwidth_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi bandwidth type
                              ##
    WIFI_BW_HT20 = 1,       ## < Bandwidth is HT20
    WIFI_BW_HT40 = 2,       ## < Bandwidth is HT40
    WIFI_BW80 = 3,          ## < Bandwidth is 80 MHz
    WIFI_BW160 = 4,         ## < Bandwidth is 160 MHz
    WIFI_BW80_BW80 = 5       ## < Bandwidth is 80 + 80 MHz

const
  WIFI_BW20* = WIFI_BW_HT20
  WIFI_BW40* = WIFI_BW_HT40

type

  wifi_ant_t* {.size: sizeof(cint).} = enum ##
                                             ##  @brief Wi-Fi antenna
                                             ##
    WIFI_ANT_ANT0,          ## < Wi-Fi antenna 0
    WIFI_ANT_ANT1,          ## < Wi-Fi antenna 1
    WIFI_ANT_MAX             ## < Invalid Wi-Fi antenna


type

  wifi_he_ap_info_t* {.importc: "wifi_he_ap_info_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Description of a Wi-Fi AP HE Info
                              ##
    bss_color* {.importc: "bss_color", bitsize: 6.}: uint8 ##
                              ## < The BSS Color value associated with the AP's corresponding BSS
    partial_bss_color* {.importc: "partial_bss_color", bitsize: 1.}: uint8 ##
                              ## < Indicates whether an AID assignment rule is based on the BSS color
    bss_color_disabled* {.importc: "bss_color_disabled", bitsize: 1.}: uint8 ##
                              ## < Indicates whether the BSS color usage is disabled
    bssid_index* {.importc: "bssid_index".}: uint8
    ## < In a M-BSSID set, identifies the non-transmitted BSSID


  wifi_ap_record_t* {.importc: "wifi_ap_record_t",
                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Description of a Wi-Fi AP
                              ##
    bssid* {.importc: "bssid".}: array[6, uint8] ## < MAC address of AP
    ssid* {.importc: "ssid".}: array[33, uint8] ## < SSID of AP
    primary* {.importc: "primary".}: uint8 ## < Channel of AP
    second* {.importc: "second".}: wifi_second_chan_t ##
                              ## < Secondary channel of AP
    rssi* {.importc: "rssi".}: int8 ## < Signal strength of AP. Note that in some rare cases where signal strength is very strong, RSSI values can be slightly positive
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ##
                              ## < Auth mode of AP
    pairwise_cipher* {.importc: "pairwise_cipher".}: wifi_cipher_type_t ##
                              ## < Pairwise cipher of AP
    group_cipher* {.importc: "group_cipher".}: wifi_cipher_type_t ##
                              ## < Group cipher of AP
    ant* {.importc: "ant".}: wifi_ant_t ## < Antenna used to receive beacon from AP
    phy_11b* {.importc: "phy_11b", bitsize: 1.}: uint32 ##
                              ## < Bit: 0 flag to identify if 11b mode is enabled or not
    phy_11g* {.importc: "phy_11g", bitsize: 1.}: uint32 ##
                              ## < Bit: 1 flag to identify if 11g mode is enabled or not
    phy_11n* {.importc: "phy_11n", bitsize: 1.}: uint32 ##
                              ## < Bit: 2 flag to identify if 11n mode is enabled or not
    phy_lr* {.importc: "phy_lr", bitsize: 1.}: uint32 ##
                              ## < Bit: 3 flag to identify if low rate is enabled or not
    phy_11a* {.importc: "phy_11a", bitsize: 1.}: uint32 ##
                              ## < Bit: 4 flag to identify if 11ax mode is enabled or not
    phy_11ac* {.importc: "phy_11ac", bitsize: 1.}: uint32 ##
                              ## < Bit: 5 flag to identify if 11ax mode is enabled or not
    phy_11ax* {.importc: "phy_11ax", bitsize: 1.}: uint32 ##
                              ## < Bit: 6 flag to identify if 11ax mode is enabled or not
    wps* {.importc: "wps", bitsize: 1.}: uint32 ## < Bit: 7 flag to identify if WPS is supported or not
    ftm_responder* {.importc: "ftm_responder", bitsize: 1.}: uint32 ##
                              ## < Bit: 8 flag to identify if FTM is supported in responder mode
    ftm_initiator* {.importc: "ftm_initiator", bitsize: 1.}: uint32 ##
                              ## < Bit: 9 flag to identify if FTM is supported in initiator mode
    reserved* {.importc: "reserved", bitsize: 22.}: uint32 ##
                              ## < Bit: 10..31 reserved
    country* {.importc: "country".}: wifi_country_t ##
                              ## < Country information of AP
    he_ap* {.importc: "he_ap".}: wifi_he_ap_info_t ##
                              ## < HE AP info
    bandwidth* {.importc: "bandwidth".}: wifi_bandwidth_t ##
                              ## < Bandwidth of AP
    vht_ch_freq1* {.importc: "vht_ch_freq1".}: uint8 ##
                              ## < This fields are used only AP bandwidth is 80 and 160 MHz, to transmit the center channel
                              ##                                                frequency of the BSS. For AP bandwidth is 80 + 80 MHz, it is the center channel frequency
                              ##                                                of the lower frequency segment.
    vht_ch_freq2* {.importc: "vht_ch_freq2".}: uint8
    ## < this fields are used only AP bandwidth is 80 + 80 MHz, and is used to transmit the center
    ##                                                channel frequency of the second segment.


  wifi_scan_method_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi scan method
                              ##
    WIFI_FAST_SCAN = 0,     ## < Do fast scan, scan will end after find SSID match AP
    WIFI_ALL_CHANNEL_SCAN    ## < All channel scan, scan will end after scan all the channel


type

  wifi_sort_method_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Wi-Fi sort AP method
                              ##
    WIFI_CONNECT_AP_BY_SIGNAL = 0, ## < Sort match AP in scan list by RSSI
    WIFI_CONNECT_AP_BY_SECURITY ## < Sort match AP in scan list by security mode


type

  wifi_scan_threshold_t* {.importc: "wifi_scan_threshold_t",
                           header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Structure describing parameters for a Wi-Fi fast scan
                              ##
    rssi* {.importc: "rssi".}: int8 ## < The minimum rssi to accept in the fast scan mode. Defaults to -127 if set to >= 0
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ##
                              ## < The weakest auth mode to accept in the fast scan mode
                              ##                                                Note: In case this value is not set and password is set as per WPA2 standards(password len >= 8), it will be defaulted to WPA2 and device won't connect to deprecated WEP/WPA networks. Please set auth mode threshold as WIFI_AUTH_WEP/WIFI_AUTH_WPA_PSK to connect to WEP/WPA networks
    rssi_5g_adjustment* {.importc: "rssi_5g_adjustment".}: uint8
    ## < The RSSI value of the 5G AP is within the rssi_5g_adjustment range compared to the 2G AP, the 5G AP will be given priority for connection.


  wifi_ps_type_t* {.size: sizeof(cint).} = enum ##
                                                 ##  @brief Wi-Fi power save type
                                                 ##
    WIFI_PS_NONE,           ## < No power save
    WIFI_PS_MIN_MODEM,      ## < Minimum modem power saving. In this mode, station wakes up to receive beacon every DTIM period
    WIFI_PS_MAX_MODEM        ## < Maximum modem power saving. In this mode, interval to receive beacons is determined by the listen_interval parameter in wifi_sta_config_t


type

  wifi_band_t* {.size: sizeof(cint).} = enum ##
                                              ##  @brief Argument structure for Wi-Fi band
                                              ##
    WIFI_BAND_2G = 1,       ## < Band is 2.4 GHz
    WIFI_BAND_5G = 2         ## < Band is 5 GHz


type

  wifi_band_mode_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Argument structure for Wi-Fi band mode
                              ##
    WIFI_BAND_MODE_2G_ONLY = 1, ## < Wi-Fi band mode is 2.4 GHz only
    WIFI_BAND_MODE_5G_ONLY = 2, ## < Wi-Fi band mode is 5 GHz only
    WIFI_BAND_MODE_AUTO = 3  ## < Wi-Fi band mode is 2.4 GHz + 5 GHz


proc BIT(nr: cint): cint = (1.cint shl nr)

type

  wifi_2g_channel_bit_t* {.size: sizeof(cint).} = enum ##
                              ##  Argument structure for 2.4G channels
    WIFI_CHANNEL_1 = BIT(1), ## < Wi-Fi channel 1
    WIFI_CHANNEL_2 = BIT(2), ## < Wi-Fi channel 2
    WIFI_CHANNEL_3 = BIT(3), ## < Wi-Fi channel 3
    WIFI_CHANNEL_4 = BIT(4), ## < Wi-Fi channel 4
    WIFI_CHANNEL_5 = BIT(5), ## < Wi-Fi channel 5
    WIFI_CHANNEL_6 = BIT(6), ## < Wi-Fi channel 6
    WIFI_CHANNEL_7 = BIT(7), ## < Wi-Fi channel 7
    WIFI_CHANNEL_8 = BIT(8), ## < Wi-Fi channel 8
    WIFI_CHANNEL_9 = BIT(9), ## < Wi-Fi channel 9
    WIFI_CHANNEL_10 = BIT(10), ## < Wi-Fi channel 10
    WIFI_CHANNEL_11 = BIT(11), ## < Wi-Fi channel 11
    WIFI_CHANNEL_12 = BIT(12), ## < Wi-Fi channel 12
    WIFI_CHANNEL_13 = BIT(13), ## < Wi-Fi channel 13
    WIFI_CHANNEL_14 = BIT(14) ## < Wi-Fi channel 14


type

  wifi_5g_channel_bit_t* {.size: sizeof(cint).} = enum ##
                              ##  Argument structure for 5G channels
    WIFI_CHANNEL_36 = BIT(1), ## < Wi-Fi channel 36
    WIFI_CHANNEL_40 = BIT(2), ## < Wi-Fi channel 40
    WIFI_CHANNEL_44 = BIT(3), ## < Wi-Fi channel 44
    WIFI_CHANNEL_48 = BIT(4), ## < Wi-Fi channel 48
    WIFI_CHANNEL_52 = BIT(5), ## < Wi-Fi channel 52
    WIFI_CHANNEL_56 = BIT(6), ## < Wi-Fi channel 56
    WIFI_CHANNEL_60 = BIT(7), ## < Wi-Fi channel 60
    WIFI_CHANNEL_64 = BIT(8), ## < Wi-Fi channel 64
    WIFI_CHANNEL_100 = BIT(9), ## < Wi-Fi channel 100
    WIFI_CHANNEL_104 = BIT(10), ## < Wi-Fi channel 104
    WIFI_CHANNEL_108 = BIT(11), ## < Wi-Fi channel 108
    WIFI_CHANNEL_112 = BIT(12), ## < Wi-Fi channel 112
    WIFI_CHANNEL_116 = BIT(13), ## < Wi-Fi channel 116
    WIFI_CHANNEL_120 = BIT(14), ## < Wi-Fi channel 120
    WIFI_CHANNEL_124 = BIT(15), ## < Wi-Fi channel 124
    WIFI_CHANNEL_128 = BIT(16), ## < Wi-Fi channel 128
    WIFI_CHANNEL_132 = BIT(17), ## < Wi-Fi channel 132
    WIFI_CHANNEL_136 = BIT(18), ## < Wi-Fi channel 136
    WIFI_CHANNEL_140 = BIT(19), ## < Wi-Fi channel 140
    WIFI_CHANNEL_144 = BIT(20), ## < Wi-Fi channel 144
    WIFI_CHANNEL_149 = BIT(21), ## < Wi-Fi channel 149
    WIFI_CHANNEL_153 = BIT(22), ## < Wi-Fi channel 153
    WIFI_CHANNEL_157 = BIT(23), ## < Wi-Fi channel 157
    WIFI_CHANNEL_161 = BIT(24), ## < Wi-Fi channel 161
    WIFI_CHANNEL_165 = BIT(25), ## < Wi-Fi channel 165
    WIFI_CHANNEL_169 = BIT(26), ## < Wi-Fi channel 169
    WIFI_CHANNEL_173 = BIT(27), ## < Wi-Fi channel 173
    WIFI_CHANNEL_177 = BIT(28) ## < Wi-Fi channel 177

let
  WIFI_PROTOCOL_11B* {.importc, header: hdr.}: uint16 = 0x1
  WIFI_PROTOCOL_11G* {.importc, header: hdr.}: uint16 = 0x2
  WIFI_PROTOCOL_11N* {.importc, header: hdr.}: uint16 = 0x4
  WIFI_PROTOCOL_LR* {.importc, header: hdr.}: uint16 = 0x8
  WIFI_PROTOCOL_11A* {.importc, header: hdr.}: uint16 = 0x10
  WIFI_PROTOCOL_11AC* {.importc, header: hdr.}: uint16 = 0x20
  WIFI_PROTOCOL_11AX* {.importc, header: hdr.}: uint16 = 0x40

type

  wifi_protocols_t* {.importc: "wifi_protocols_t",
                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Description of a Wi-Fi protocols
                              ##
    ghz_2g* {.importc: "ghz_2g".}: uint16 ## < Represents 2.4 GHz protocol, support 802.11b or 802.11g or 802.11n or 802.11ax or LR mode
    ghz_5g* {.importc: "ghz_5g".}: uint16
    ## < Represents 5 GHz protocol, support 802.11a or 802.11n or 802.11ac or 802.11ax


  wifi_bandwidths_t* {.importc: "wifi_bandwidths_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Description of a Wi-Fi band bandwidths
                              ##
    ghz_2g* {.importc: "ghz_2g".}: wifi_bandwidth_t ##
                              ## < Represents 2.4 GHz bandwidth
    ghz_5g* {.importc: "ghz_5g".}: wifi_bandwidth_t
    ## < Represents 5 GHz bandwidth


  wifi_pmf_config_t* {.importc: "wifi_pmf_config_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Configuration structure for Protected Management Frame
                              ##
    capable* {.importc: "capable".}: bool ## < Deprecated variable. Device will always connect in PMF mode if other device also advertises PMF capability.
    required* {.importc: "required".}: bool
    ## < Advertises that Protected Management Frame is required. Device will not associate to non-PMF capable devices.


  wifi_sae_pwe_method_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Configuration for SAE PWE derivation
                              ##
    WPA3_SAE_PWE_UNSPECIFIED, WPA3_SAE_PWE_HUNT_AND_PECK,
    WPA3_SAE_PWE_HASH_TO_ELEMENT, WPA3_SAE_PWE_BOTH


type

  wifi_sae_pk_mode_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Configuration for SAE-PK
                              ##
    WPA3_SAE_PK_MODE_AUTOMATIC = 0, WPA3_SAE_PK_MODE_ONLY = 1,
    WPA3_SAE_PK_MODE_DISABLED = 2


type

  wifi_bss_max_idle_config_t* {.importc: "wifi_bss_max_idle_config_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Configuration structure for BSS max idle
                              ##
    period* {.importc: "period".}: uint16 ## < Sets BSS Max idle period (1 Unit = 1000TUs OR 1.024 Seconds). If there are no frames for this period from a STA, SoftAP will disassociate due to inactivity. Setting it to 0 disables the feature
    protected_keep_alive* {.importc: "protected_keep_alive".}: bool
    ## < Requires clients to use protected keep alive frames for BSS Max Idle period


  wifi_ap_config_t* {.importc: "wifi_ap_config_t",
                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Soft-AP configuration settings for the device
                              ##
    ssid* {.importc: "ssid".}: array[32, uint8] ## < SSID of soft-AP. If ssid_len field is 0, this must be a Null terminated string. Otherwise, length is set according to ssid_len.
    password* {.importc: "password".}: array[64, uint8] ##
                              ## < Password of soft-AP.
    ssid_len* {.importc: "ssid_len".}: uint8 ## < Optional length of SSID field.
    channel* {.importc: "channel".}: uint8 ## < Channel of soft-AP
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ##
                              ## < Auth mode of soft-AP. Do not support AUTH_WEP, AUTH_WAPI_PSK and AUTH_OWE in soft-AP mode. When the auth mode is set to WPA2_PSK, WPA2_WPA3_PSK or WPA3_PSK, the pairwise cipher will be overwritten with WIFI_CIPHER_TYPE_CCMP by default, unless explicitly set.
    ssid_hidden* {.importc: "ssid_hidden".}: uint8 ##
                              ## < Broadcast SSID or not, default 0, broadcast the SSID
    max_connection* {.importc: "max_connection".}: uint8 ##
                              ## < Max number of stations allowed to connect in
    beacon_interval* {.importc: "beacon_interval".}: uint16 ##
                              ## < Beacon interval which should be multiples of 100. Unit: TU(time unit, 1 TU = 1024 us). Range: 100 ~ 60000. Default value: 100
    csa_count* {.importc: "csa_count".}: uint8 ## < Channel Switch Announcement Count. Notify the station that the channel will switch after the csa_count beacon intervals. Default value: 3
    dtim_period* {.importc: "dtim_period".}: uint8 ##
                              ## < Dtim period of soft-AP. Range: 1 ~ 10. Default value: 1
    pairwise_cipher* {.importc: "pairwise_cipher".}: wifi_cipher_type_t ##
                              ## < Pairwise cipher of SoftAP, group cipher will be derived using this. Cipher values are valid starting from WIFI_CIPHER_TYPE_TKIP, enum values before that will be considered as invalid and default cipher suites(TKIP+CCMP) will be used. Valid cipher suites in softAP mode are WIFI_CIPHER_TYPE_TKIP, WIFI_CIPHER_TYPE_CCMP, WIFI_CIPHER_TYPE_TKIP_CCMP, WIFI_CIPHER_TYPE_GCMP and WIFI_CIPHER_TYPE_GCMP256.
    ftm_responder* {.importc: "ftm_responder".}: bool ##
                              ## < Enable FTM Responder mode
    pmf_cfg* {.importc: "pmf_cfg".}: wifi_pmf_config_t ##
                              ## < Configuration for Protected Management Frame
    sae_pwe_h2e* {.importc: "sae_pwe_h2e".}: wifi_sae_pwe_method_t ##
                              ## < Configuration for SAE PWE derivation method
    transition_disable* {.importc: "transition_disable".}: uint8 ##
                              ## < Whether to enable transition disable feature
    sae_ext* {.importc: "sae_ext".}: uint8 ## < Enable SAE EXT feature. SOC_GCMP_SUPPORT is required for this feature.
    bss_max_idle_cfg* {.importc: "bss_max_idle_cfg".}: wifi_bss_max_idle_config_t ##
                              ## < Configuration for bss max idle, effective if CONFIG_WIFI_BSS_MAX_IDLE_SUPPORT is enabled
    gtk_rekey_interval* {.importc: "gtk_rekey_interval".}: uint16
    ## < GTK rekeying interval in seconds. If set to 0, GTK rekeying is disabled. Range: 60 ~ 65535 including 0.


const
  SAE_H2E_IDENTIFIER_LEN* = 32

type

  wifi_sta_config_t* {.importc: "wifi_sta_config_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief STA configuration settings for the device
                              ##
    ssid* {.importc: "ssid".}: array[32, uint8] ## < SSID of target AP.
    password* {.importc: "password".}: array[64, uint8] ##
                              ## < Password of target AP.
    scan_method* {.importc: "scan_method".}: wifi_scan_method_t ##
                              ## < Do all channel scan or fast scan
    bssid_set* {.importc: "bssid_set".}: bool ## < Whether set MAC address of target AP or not. Generally, station_config.bssid_set needs to be 0; and it needs to be 1 only when users need to check the MAC address of the AP.
    bssid* {.importc: "bssid".}: array[6, uint8] ## < MAC address of target AP
    channel* {.importc: "channel".}: uint8 ## < Channel hint for target AP. For 2.4G AP, set to 1~13 to scan starting from the specified channel before connecting to AP. For 5G AP, set to 36~177 (36, 40, 44 ... 177) to scan starting from the specified channel before connecting to AP. Set to 0 for no preference
    listen_interval* {.importc: "listen_interval".}: uint16 ##
                              ## < Listen interval for ESP32 station to receive beacon when WIFI_PS_MAX_MODEM is set. Units: AP beacon intervals. Defaults to 3 if set to 0.
    sort_method* {.importc: "sort_method".}: wifi_sort_method_t ##
                              ## < Sort the connect AP in the list by rssi or security mode
    threshold* {.importc: "threshold".}: wifi_scan_threshold_t ##
                              ## < When scan_threshold is set, only APs which have an auth mode that is more secure than the selected auth mode and a signal stronger than the minimum RSSI will be used.
    pmf_cfg* {.importc: "pmf_cfg".}: wifi_pmf_config_t ##
                              ## < Configuration for Protected Management Frame. Will be advertised in RSN Capabilities in RSN IE.
    rm_enabled* {.importc: "rm_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether Radio Measurements are enabled for the connection
    btm_enabled* {.importc: "btm_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether BSS Transition Management is enabled for the connection. Note that when btm is enabled, the application itself should not set specific bssid (i.e using bssid_set and bssid in this config)or channel to connect to. This defeats the purpose of a BTM supported network, and hence if btm is supported and a specific bssid or channel is set in this config, it will be cleared from the config at the first disconnection or connection so that the device can roam to other BSS. It is recommended not to set BSSID when BTM is enabled.
    mbo_enabled* {.importc: "mbo_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether MBO is enabled for the connection. Note that when mbo is enabled, the application itself should not set specific bssid (i.e using bssid_set and bssid in this config)or channel to connect to. This defeats the purpose of a MBO supported network, and hence if btm is supported and a specific bssid or channel is set in this config, it will be cleared from the config at the first disconnection or connection so that the device can roam to other BSS. It is recommended not to set BSSID when MBO is enabled. Enabling mbo here, automatically enables btm and rm above.
    ft_enabled* {.importc: "ft_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether FT is enabled for the connection
    owe_enabled* {.importc: "owe_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether OWE is enabled for the connection
    transition_disable* {.importc: "transition_disable", bitsize: 1.}: uint32 ##
                              ## < Whether to enable transition disable feature
    reserved1* {.importc: "reserved1", bitsize: 26.}: uint32 ##
                              ## < Reserved for future feature set
    sae_pwe_h2e* {.importc: "sae_pwe_h2e".}: wifi_sae_pwe_method_t ##
                              ## < Configuration for SAE PWE derivation method
    sae_pk_mode* {.importc: "sae_pk_mode".}: wifi_sae_pk_mode_t ##
                              ## < Configuration for SAE-PK (Public Key) Authentication method
    failure_retry_cnt* {.importc: "failure_retry_cnt".}: uint8 ##
                              ## < Number of connection retries station will do before moving to next AP. scan_method should be set as WIFI_ALL_CHANNEL_SCAN to use this config.
                              ##                                                    Note: Enabling this may cause connection time to increase in case best AP doesn't behave properly.
    he_dcm_set* {.importc: "he_dcm_set", bitsize: 1.}: uint32 ##
                              ## < Whether DCM max.constellation for transmission and reception is set.
    he_dcm_max_constellation_tx* {.importc: "he_dcm_max_constellation_tx",
                                   bitsize: 2.}: uint32 ##
                              ## < Indicate the max.constellation for DCM in TB PPDU the STA supported. 0: not supported. 1: BPSK, 2: QPSK, 3: 16-QAM. The default value is 3.
    he_dcm_max_constellation_rx* {.importc: "he_dcm_max_constellation_rx",
                                   bitsize: 2.}: uint32 ##
                              ## < Indicate the max.constellation for DCM in both Data field and HE-SIG-B field the STA supported. 0: not supported. 1: BPSK, 2: QPSK, 3: 16-QAM. The default value is 3.
    he_mcs9_enabled* {.importc: "he_mcs9_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether to support HE-MCS8 and HE-MCS9. The default value is 0.
    he_su_beamformee_disabled* {.importc: "he_su_beamformee_disabled",
                                 bitsize: 1.}: uint32 ##
                              ## < Whether to disable support for operation as an SU beamformee.
    he_trig_su_bmforming_feedback_disabled*
        {.importc: "he_trig_su_bmforming_feedback_disabled", bitsize: 1.}: uint32 ##
                              ## < Whether to disable support the transmission of SU feedback in an HE TB sounding sequence.
    he_trig_mu_bmforming_partial_feedback_disabled* {.
        importc: "he_trig_mu_bmforming_partial_feedback_disabled", bitsize: 1.}: uint32 ##
                              ## < Whether to disable support the transmission of partial-bandwidth MU feedback in an HE TB sounding sequence.
    he_trig_cqi_feedback_disabled* {.importc: "he_trig_cqi_feedback_disabled",
                                     bitsize: 1.}: uint32 ##
                              ## < Whether to disable support the transmission of CQI feedback in an HE TB sounding sequence.
    vht_su_beamformee_disabled* {.importc: "vht_su_beamformee_disabled",
                                  bitsize: 1.}: uint32 ##
                              ## < Whether to disable support for operation as an VHT SU beamformee.
    vht_mu_beamformee_disabled* {.importc: "vht_mu_beamformee_disabled",
                                  bitsize: 1.}: uint32 ##
                              ## < Whether to disable support for operation as an VHT MU beamformee.
    vht_mcs8_enabled* {.importc: "vht_mcs8_enabled", bitsize: 1.}: uint32 ##
                              ## < Whether to support VHT-MCS8. The default value is 0.
    reserved2* {.importc: "reserved2", bitsize: 19.}: uint32 ##
                              ## < Reserved for future feature set
    sae_h2e_identifier* {.importc: "sae_h2e_identifier".}: array[
        SAE_H2E_IDENTIFIER_LEN, uint8]
    ## < Password identifier for H2E. this needs to be null terminated string


  wifi_nan_config_t* {.importc: "wifi_nan_config_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Discovery start configuration
                              ##
    op_channel* {.importc: "op_channel".}: uint8 ## < NAN Discovery operating channel
    master_pref* {.importc: "master_pref".}: uint8 ##
                              ## < Device's preference value to serve as NAN Master
    scan_time* {.importc: "scan_time".}: uint8 ## < Scan time in seconds while searching for a NAN cluster
    warm_up_sec* {.importc: "warm_up_sec".}: uint16
    ## < Warm up time before assuming NAN Anchor Master role


  wifi_config_t* {.importc: "wifi_config_t", header: hdr,
                   bycopy, union.} = object ##
                                             ##  @brief Configuration data for device's AP or STA or NAN.
                                             ##
                                             ##  The usage of this union (for ap, sta or nan configuration) is determined by the accompanying
                                             ##  interface argument passed to esp_wifi_set_config() or esp_wifi_get_config()
                                             ##
                                             ##
    ap* {.importc: "ap".}: wifi_ap_config_t ## < Configuration of AP
    sta* {.importc: "sta".}: wifi_sta_config_t ## < Configuration of STA
    nan* {.importc: "nan".}: wifi_nan_config_t
    ## < Configuration of NAN


  wifi_sta_info_t* {.importc: "wifi_sta_info_t",
                     header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Description of STA associated with AP
                              ##
    mac* {.importc: "mac".}: array[6, uint8] ## < MAC address
    rssi* {.importc: "rssi".}: int8 ## < Current average rssi of sta connected
    phy_11b* {.importc: "phy_11b", bitsize: 1.}: uint32 ##
                              ## < Bit: 0 flag to identify if 11b mode is enabled or not
    phy_11g* {.importc: "phy_11g", bitsize: 1.}: uint32 ##
                              ## < Bit: 1 flag to identify if 11g mode is enabled or not
    phy_11n* {.importc: "phy_11n", bitsize: 1.}: uint32 ##
                              ## < Bit: 2 flag to identify if 11n mode is enabled or not
    phy_lr* {.importc: "phy_lr", bitsize: 1.}: uint32 ##
                              ## < Bit: 3 flag to identify if low rate is enabled or not
    phy_11a* {.importc: "phy_11a", bitsize: 1.}: uint32 ##
                              ## < Bit: 4 flag to identify if 11ax mode is enabled or not
    phy_11ac* {.importc: "phy_11ac", bitsize: 1.}: uint32 ##
                              ## < Bit: 5 flag to identify if 11ax mode is enabled or not
    phy_11ax* {.importc: "phy_11ax", bitsize: 1.}: uint32 ##
                              ## < Bit: 6 flag to identify if 11ax mode is enabled or not
    is_mesh_child* {.importc: "is_mesh_child", bitsize: 1.}: uint32 ##
                              ## < Bit: 7 flag to identify mesh child
    reserved* {.importc: "reserved", bitsize: 24.}: uint32
    ## < Bit: 8..31 reserved


  wifi_storage_t* {.size: sizeof(cint).} = enum ##
                                                 ##  @brief Wi-Fi storage type
                                                 ##
    WIFI_STORAGE_FLASH,     ## < All configuration will store in both memory and flash
    WIFI_STORAGE_RAM         ## < All configuration will only store in the memory


type

  wifi_vendor_ie_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief     Vendor Information Element type
                              ##
                              ##  Determines the frame type that the IE will be associated with.
                              ##
    WIFI_VND_IE_TYPE_BEACON, ## < Beacon frame
    WIFI_VND_IE_TYPE_PROBE_REQ, ## < Probe request frame
    WIFI_VND_IE_TYPE_PROBE_RESP, ## < Probe response frame
    WIFI_VND_IE_TYPE_ASSOC_REQ, ## < Association request frame
    WIFI_VND_IE_TYPE_ASSOC_RESP ## < Association response frame


type

  wifi_vendor_ie_id_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief     Vendor Information Element index
                              ##
                              ##  Each IE type can have up to two associated vendor ID elements.
                              ##
    WIFI_VND_IE_ID_0,       ## < Vendor ID element 0
    WIFI_VND_IE_ID_1         ## < Vendor ID element 1

let
  WIFI_VENDOR_IE_ELEMENT_ID* {.importc, header: hdr.}: uint8

type

  wifi_phy_mode_t* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief     Operation PHY mode
                                                  ##
    WIFI_PHY_MODE_LR,       ## < PHY mode for Low Rate
    WIFI_PHY_MODE_11B,      ## < PHY mode for 11b
    WIFI_PHY_MODE_11G,      ## < PHY mode for 11g
    WIFI_PHY_MODE_11A,      ## < PHY mode for 11a
    WIFI_PHY_MODE_HT20,     ## < PHY mode for Bandwidth HT20
    WIFI_PHY_MODE_HT40,     ## < PHY mode for Bandwidth HT40
    WIFI_PHY_MODE_HE20,     ## < PHY mode for Bandwidth HE20
    WIFI_PHY_MODE_VHT20      ## < PHY mode for Bandwidth VHT20


type

  vendor_ie_data_t* {.importc: "vendor_ie_data_t",
                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Vendor Information Element header
                              ##
                              ##  The first bytes of the Information Element will match this header. Payload follows.
                              ##
    element_id* {.importc: "element_id".}: uint8 ## < Should be set to WIFI_VENDOR_IE_ELEMENT_ID (0xDD)
    length* {.importc: "length".}: uint8 ## < Length of all bytes in the element data following this field. Minimum 4.
    vendor_oui* {.importc: "vendor_oui".}: array[3, uint8] ##
                              ## < Vendor identifier (OUI).
    vendor_oui_type* {.importc: "vendor_oui_type".}: uint8 ##
                              ## < Vendor-specific OUI type.
    payload* {.importc: "payload".}: UncheckedArray[uint8]
    ## < Payload. Length is equal to value in 'length' field, minus 4.


  wifi_promiscuous_pkt_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Promiscuous frame type
                              ##
                              ##  Passed to promiscuous mode RX callback to indicate the type of parameter in the buffer.
                              ##
                              ##
    WIFI_PKT_MGMT,          ## < Management frame, indicates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_CTRL,          ## < Control frame, indicates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_DATA,          ## < Data frame, indicates 'buf' argument is wifi_promiscuous_pkt_t
    WIFI_PKT_MISC            ## < Other type, such as MIMO etc. 'buf' argument is wifi_promiscuous_pkt_t but the payload is zero length.

const
  WIFI_PROMIS_FILTER_MASK_ALL* = (0xFFFFFFFF) ## < Filter all packets
  WIFI_PROMIS_FILTER_MASK_MGMT* = (1) ## < Filter the packets with type of WIFI_PKT_MGMT
  WIFI_PROMIS_FILTER_MASK_CTRL* = (1 shl 1) ## < Filter the packets with type of WIFI_PKT_CTRL
  WIFI_PROMIS_FILTER_MASK_DATA* = (1 shl 2) ## < Filter the packets with type of WIFI_PKT_DATA
  WIFI_PROMIS_FILTER_MASK_MISC* = (1 shl 3) ## < Filter the packets with type of WIFI_PKT_MISC
  WIFI_PROMIS_FILTER_MASK_DATA_MPDU* = (1 shl 4) ## < Filter the MPDU which is a kind of WIFI_PKT_DATA
  WIFI_PROMIS_FILTER_MASK_DATA_AMPDU* = (1 shl 5) ## < Filter the AMPDU which is a kind of WIFI_PKT_DATA
  WIFI_PROMIS_FILTER_MASK_FCSFAIL* = (1 shl 6) ## < Filter the FCS failed packets, do not open it in general
  WIFI_PROMIS_CTRL_FILTER_MASK_ALL* = (0xFF800000) ##
                              ## < Filter all control packets
  WIFI_PROMIS_CTRL_FILTER_MASK_WRAPPER* = (1 shl 23) ##
                              ## < Filter the control packets with subtype of Control Wrapper
  WIFI_PROMIS_CTRL_FILTER_MASK_BAR* = (1 shl 24) ## < Filter the control packets with subtype of Block Ack Request
  WIFI_PROMIS_CTRL_FILTER_MASK_BA* = (1 shl 25) ## < Filter the control packets with subtype of Block Ack
  WIFI_PROMIS_CTRL_FILTER_MASK_PSPOLL* = (1 shl 26) ##
                              ## < Filter the control packets with subtype of PS-Poll
  WIFI_PROMIS_CTRL_FILTER_MASK_RTS* = (1 shl 27) ## < Filter the control packets with subtype of RTS
  WIFI_PROMIS_CTRL_FILTER_MASK_CTS* = (1 shl 28) ## < Filter the control packets with subtype of CTS
  WIFI_PROMIS_CTRL_FILTER_MASK_ACK* = (1 shl 29) ## < Filter the control packets with subtype of ACK
  WIFI_PROMIS_CTRL_FILTER_MASK_CFEND* = (1 shl 30) ##
                              ## < Filter the control packets with subtype of CF-END
  WIFI_PROMIS_CTRL_FILTER_MASK_CFENDACK* = (1 shl 31) ##
                              ## < Filter the control packets with subtype of CF-END+CF-ACK

type

  wifi_promiscuous_filter_t* {.importc: "wifi_promiscuous_filter_t",
                               header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Mask for filtering different packet types in promiscuous mode
                              ##
    filter_mask* {.importc: "filter_mask".}: uint32
    ## < OR of one or more filter values WIFI_PROMIS_FILTER_*


const
  WIFI_EVENT_MASK_ALL* = (0xFFFFFFFF) ## < Mask all Wi-Fi events
  WIFI_EVENT_MASK_NONE* = (0) ## < Mask none of the Wi-Fi events
  WIFI_EVENT_MASK_AP_PROBEREQRECVED* = (BIT(0)) ## < Mask SYSTEM_EVENT_AP_PROBEREQRECVED event

##
##  @brief CSI data type
##
##

type

  wifi_ant_gpio_t* {.importc: "wifi_ant_gpio_t",
                     header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Wi-Fi GPIO configuration for antenna selection
                              ##
                              ##
    gpio_select* {.importc: "gpio_select", bitsize: 1.}: uint8 ##
                              ## < Whether this GPIO is connected to external antenna switch
    gpio_num* {.importc: "gpio_num", bitsize: 7.}: uint8
    ## < The GPIO number that connects to external antenna switch


  wifi_ant_gpio_config_t* {.importc: "wifi_ant_gpio_config_t",
                            header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Wi-Fi GPIOs configuration for antenna selection
                              ##
                              ##
    gpio_cfg* {.importc: "gpio_cfg".}: array[4, wifi_ant_gpio_t]
    ## < The configurations of GPIOs that connect to external antenna switch


  wifi_ant_mode_t* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief Wi-Fi antenna mode
                                                  ##
                                                  ##
    WIFI_ANT_MODE_ANT0,     ## < Enable Wi-Fi antenna 0 only
    WIFI_ANT_MODE_ANT1,     ## < Enable Wi-Fi antenna 1 only
    WIFI_ANT_MODE_AUTO,     ## < Enable Wi-Fi antenna 0 and 1, automatically select an antenna
    WIFI_ANT_MODE_MAX        ## < Invalid Wi-Fi enabled antenna


type

  wifi_ant_config_t* {.importc: "wifi_ant_config_t",
                       header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Wi-Fi antenna configuration
                              ##
                              ##
    rx_ant_mode* {.importc: "rx_ant_mode".}: wifi_ant_mode_t ##
                              ## < Wi-Fi antenna mode for receiving
    rx_ant_default* {.importc: "rx_ant_default".}: wifi_ant_t ##
                              ## < Default antenna mode for receiving, it's ignored if rx_ant_mode is not WIFI_ANT_MODE_AUTO
    tx_ant_mode* {.importc: "tx_ant_mode".}: wifi_ant_mode_t ##
                              ## < Wi-Fi antenna mode for transmission, it can be set to WIFI_ANT_MODE_AUTO only if rx_ant_mode is set to WIFI_ANT_MODE_AUTO
    enabled_ant0* {.importc: "enabled_ant0", bitsize: 4.}: uint8 ##
                              ## < Index (in antenna GPIO configuration) of enabled WIFI_ANT_MODE_ANT0
    enabled_ant1* {.importc: "enabled_ant1", bitsize: 4.}: uint8
    ## < Index (in antenna GPIO configuration) of enabled WIFI_ANT_MODE_ANT1


  wifi_action_rx_cb_t* = proc (hdr: ptr uint8; payload: ptr uint8; len: csize_t;
                               channel: uint8): cint {.cdecl.} ##
                              ##
                              ##  @brief     The Rx callback function of Action Tx operations
                              ##
                              ##  @param     hdr Pointer to the IEEE 802.11 Header structure
                              ##  @param     payload Pointer to the Payload following 802.11 Header
                              ##  @param     len Length of the Payload
                              ##  @param     channel Channel number the frame is received on
                              ##
                              ##

  wifi_action_tx_req_t* {.importc: "wifi_action_tx_req_t",
                          header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Action Frame Tx Request
                              ##
    ifx* {.importc: "ifx".}: wifi_interface_t ## < Wi-Fi interface to send request to
    dest_mac* {.importc: "dest_mac".}: array[6, uint8] ##
                              ## < Destination MAC address
    `type`* {.importc: "type".}: wifi_action_tx_t ## < ACTION TX operation type
    channel* {.importc: "channel".}: uint8 ## < Channel on which to perform ACTION TX Operation
    wait_time_ms* {.importc: "wait_time_ms".}: uint32 ##
                              ## < Duration to wait for on target channel
    no_ack* {.importc: "no_ack".}: bool ## < Indicates no ack required
    rx_cb* {.importc: "rx_cb".}: wifi_action_rx_cb_t ##
                              ## < Rx Callback to receive action frames
    op_id* {.importc: "op_id".}: uint8 ## < Unique Identifier for operation provided by wifi driver
    data_len* {.importc: "data_len".}: uint32 ## < Length of the appended Data
    data* {.importc: "data".}: UncheckedArray[uint8]
    ## < Appended Data payload


  wifi_roc_done_status_t* {.size: sizeof(cint).} = enum ##
                              ##  Status codes for WIFI_EVENT_ROC_DONE evt
    WIFI_ROC_DONE = 0,      ## < ROC operation was completed successfully
    WIFI_ROC_FAIL            ## < ROC operation was cancelled


type

  wifi_action_roc_done_cb_t* = proc (context: uint32; op_id: uint8;
                                     status: wifi_roc_done_status_t) {.cdecl.} ##
                              ##
                              ##  @brief     The callback function executed when ROC operation has ended
                              ##
                              ##  @param     context rxcb registered for the corresponding ROC operation
                              ##  @param     op_id  ID of the corresponding ROC operation
                              ##  @param     status status code of the ROC operation denoted
                              ##
                              ##

  wifi_roc_req_t* {.importc: "wifi_roc_req_t",
                    header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Remain on Channel request
                              ##
                              ##
                              ##
    ifx* {.importc: "ifx".}: wifi_interface_t ## < WiFi interface to send request to
    `type`* {.importc: "type".}: wifi_roc_t ## < ROC operation type
    channel* {.importc: "channel".}: uint8 ## < Channel on which to perform ROC Operation
    sec_channel* {.importc: "sec_channel".}: wifi_second_chan_t ##
                              ## < Secondary channel
    wait_time_ms* {.importc: "wait_time_ms".}: uint32 ##
                              ## < Duration to wait for on target channel
    rx_cb* {.importc: "rx_cb".}: wifi_action_rx_cb_t ##
                              ## < Rx Callback to receive any response
    op_id* {.importc: "op_id".}: uint8 ## < ID of this specific ROC operation provided by wifi driver
    done_cb* {.importc: "done_cb".}: wifi_action_roc_done_cb_t
    ## < Callback to function that will be called upon ROC done. If assigned, WIFI_EVENT_ROC_DONE event will not be posted


  wifi_ftm_initiator_cfg_t* {.importc: "wifi_ftm_initiator_cfg_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief FTM Initiator configuration
                              ##
                              ##
    resp_mac* {.importc: "resp_mac".}: array[6, uint8] ##
                              ## < MAC address of the FTM Responder
    channel* {.importc: "channel".}: uint8 ## < Primary channel of the FTM Responder
    frm_count* {.importc: "frm_count".}: uint8 ## < No. of FTM frames requested in terms of 4 or 8 bursts (allowed values - 0(No pref), 16, 24, 32, 64)
    burst_period* {.importc: "burst_period".}: uint16 ##
                              ## < Requested period between FTM bursts in 100's of milliseconds (allowed values 0(No pref) - 100)
    use_get_report_api* {.importc: "use_get_report_api".}: bool
    ## < True - Using esp_wifi_ftm_get_report to get FTM report, False - Using ftm_report_data from
    ##                                      WIFI_EVENT_FTM_REPORT to get FTM report


const
  ESP_WIFI_NAN_MAX_SVC_SUPPORTED* = 2
  ESP_WIFI_NAN_DATAPATH_MAX_PEERS* = 2
  ESP_WIFI_NDP_ROLE_INITIATOR* = 1
  ESP_WIFI_NDP_ROLE_RESPONDER* = 2
  ESP_WIFI_MAX_SVC_NAME_LEN* = 256
  ESP_WIFI_MAX_FILTER_LEN* = 256
  ESP_WIFI_MAX_SVC_INFO_LEN* = 64
  ESP_WIFI_MAX_FUP_SSI_LEN* = 2048
  ESP_WIFI_MAX_SVC_SSI_LEN* = 512
  ESP_WIFI_MAX_NEIGHBOR_REP_LEN* = 64
  WIFI_OUI_LEN* = 3

type

  wifi_nan_svc_proto_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Protocol types in NAN service specific info attribute
                              ##
                              ##
    WIFI_SVC_PROTO_RESERVED = 0, ## < Value 0 Reserved
    WIFI_SVC_PROTO_BONJOUR = 1, ## < Bonjour Protocol
    WIFI_SVC_PROTO_GENERIC = 2, ## < Generic Service Protocol
    WIFI_SVC_PROTO_CSA_MATTER = 3, ## < CSA Matter specific protocol
    WIFI_SVC_PROTO_MAX       ## < Values 4-255 Reserved


type

  wifi_nan_wfa_ssi_t* {.importc: "wifi_nan_wfa_ssi_t",
                        header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief WFA defined Protocol types in NAN service specific info attribute
                              ##
                              ##
    wfa_oui* {.importc: "wfa_oui".}: array[WIFI_OUI_LEN, uint8] ##
                              ## < WFA OUI - 0x50, 0x6F, 0x9A
    proto* {.importc: "proto".}: wifi_nan_svc_proto_t ##
                              ## < WFA defined protocol types
    payload* {.importc: "payload".}: UncheckedArray[uint8]
    ## < Service Info payload


  wifi_nan_service_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief NAN Services types
                              ##
                              ##
    NAN_PUBLISH_SOLICITED,  ## < Send unicast Publish frame to Subscribers that match the requirement
    NAN_PUBLISH_UNSOLICITED, ## < Send broadcast Publish frames in every Discovery Window(DW)
    NAN_SUBSCRIBE_ACTIVE,   ## < Send broadcast Subscribe frames in every DW
    NAN_SUBSCRIBE_PASSIVE    ## < Passively listens to Publish frames


type

  wifi_nan_publish_cfg_t* {.importc: "wifi_nan_publish_cfg_t",
                            header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Publish service configuration parameters
                              ##
                              ##
    service_name* {.importc: "service_name".}: array[ESP_WIFI_MAX_SVC_NAME_LEN,
        char]                ## < Service name identifier
    `type`* {.importc: "type".}: wifi_nan_service_type_t ##
                              ## < Service type
    matching_filter* {.importc: "matching_filter".}: array[
        ESP_WIFI_MAX_FILTER_LEN, char] ## < Comma separated filters for filtering services
    svc_info* {.importc: "svc_info".}: array[ESP_WIFI_MAX_SVC_INFO_LEN, char] ##
                              ## < To be deprecated in next major release, use ssi instead
    single_replied_event* {.importc: "single_replied_event", bitsize: 1.}: uint8 ##
                              ## < Give single Replied event or every time
    datapath_reqd* {.importc: "datapath_reqd", bitsize: 1.}: uint8 ##
                              ## < NAN Datapath required for the service
    fsd_reqd* {.importc: "fsd_reqd", bitsize: 1.}: uint8 ##
                              ## < Further Service Discovery(FSD) required
    fsd_gas* {.importc: "fsd_gas", bitsize: 1.}: uint8 ##
                              ## < 0 - Follow-up used for FSD, 1 - GAS used for FSD
    reserved* {.importc: "reserved", bitsize: 4.}: uint8 ##
                              ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info, maximum allowed length - ESP_WIFI_MAX_SVC_SSI_LEN
    ssi* {.importc: "ssi".}: ptr uint8
    ## < Service Specific Info of type wifi_nan_wfa_ssi_t for WFA defined protocols, otherwise proprietary and defined by Applications


  wifi_nan_subscribe_cfg_t* {.importc: "wifi_nan_subscribe_cfg_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Subscribe service configuration parameters
                              ##
                              ##
    service_name* {.importc: "service_name".}: array[ESP_WIFI_MAX_SVC_NAME_LEN,
        char]                ## < Service name identifier
    `type`* {.importc: "type".}: wifi_nan_service_type_t ##
                              ## < Service type
    matching_filter* {.importc: "matching_filter".}: array[
        ESP_WIFI_MAX_FILTER_LEN, char] ## < Comma separated filters for filtering services
    svc_info* {.importc: "svc_info".}: array[ESP_WIFI_MAX_SVC_INFO_LEN, char] ##
                              ## < To be deprecated in next major release, use ssi instead
    single_match_event* {.importc: "single_match_event", bitsize: 1.}: uint8 ##
                              ## < Give single Match event(per SSI update)  or every time
    datapath_reqd* {.importc: "datapath_reqd", bitsize: 1.}: uint8 ##
                              ## < NAN Datapath required for the service
    fsd_reqd* {.importc: "fsd_reqd", bitsize: 1.}: uint8 ##
                              ## < Further Service Discovery(FSD) required
    fsd_gas* {.importc: "fsd_gas", bitsize: 1.}: uint8 ##
                              ## < 0 - Follow-up used for FSD, 1 - GAS used for FSD
    reserved* {.importc: "reserved", bitsize: 4.}: uint8 ##
                              ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info, maximum allowed length - ESP_WIFI_MAX_SVC_SSI_LEN
    ssi* {.importc: "ssi".}: ptr uint8
    ## < Service Specific Info of type wifi_nan_wfa_ssi_t for WFA defined protocols, otherwise proprietary and defined by Applications


  wifi_nan_followup_params_t* {.importc: "wifi_nan_followup_params_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Follow-up parameters
                              ##
                              ##
    inst_id* {.importc: "inst_id".}: uint8 ## < Own service instance id
    peer_inst_id* {.importc: "peer_inst_id".}: uint8 ##
                              ## < Peer's service instance id
    peer_mac* {.importc: "peer_mac".}: array[6, uint8] ##
                              ## < Peer's MAC address
    svc_info* {.importc: "svc_info".}: array[ESP_WIFI_MAX_SVC_INFO_LEN, char] ##
                              ## < To be deprecated in next major release, use ssi instead
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info, maximum allowed length - ESP_WIFI_MAX_FUP_SSI_LEN
    ssi* {.importc: "ssi".}: ptr uint8
    ## < Service Specific Info of type wifi_nan_wfa_ssi_t for WFA defined protocols, otherwise proprietary and defined by Applications


  wifi_nan_datapath_req_t* {.importc: "wifi_nan_datapath_req_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Datapath Request parameters
                              ##
                              ##
    pub_id* {.importc: "pub_id".}: uint8 ## < Publisher's service instance id
    peer_mac* {.importc: "peer_mac".}: array[6, uint8] ##
                              ## < Peer's MAC address
    confirm_required* {.importc: "confirm_required".}: bool
    ## < NDP Confirm frame required


  wifi_nan_datapath_resp_t* {.importc: "wifi_nan_datapath_resp_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Datapath Response parameters
                              ##
                              ##
    accept* {.importc: "accept".}: bool ## < True - Accept incoming NDP, False - Reject it
    ndp_id* {.importc: "ndp_id".}: uint8 ## < NAN Datapath Identifier
    peer_mac* {.importc: "peer_mac".}: array[6, uint8]
    ## < Peer's MAC address


  wifi_nan_datapath_end_req_t* {.importc: "wifi_nan_datapath_end_req_t",
                                 header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief NAN Datapath End parameters
                              ##
                              ##
    ndp_id* {.importc: "ndp_id".}: uint8 ## < NAN Datapath Identifier
    peer_mac* {.importc: "peer_mac".}: array[6, uint8]
    ## < Peer's MAC address


  wifi_phy_rate_t* {.importc: "wifi_phy_rate_t", header: hdr.} = cint ##\
    ##  @brief Wi-Fi PHY rate encodings
    ##
    ##  @note Rate Table: MCS Rate and Guard Interval Information
    ##  |       MCS RATE              |          HT20           |          HT40           |          HE20           |         VHT20           |
    ##
    ## |-----------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
    ##  | WIFI_PHY_RATE_MCS0_LGI      |     6.5 Mbps (800 ns)   |    13.5 Mbps (800 ns)   |     8.1 Mbps (1600 ns)  |     6.5 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS1_LGI      |      13 Mbps (800 ns)   |      27 Mbps (800 ns)   |    16.3 Mbps (1600 ns)  |      13 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS2_LGI      |    19.5 Mbps (800 ns)   |    40.5 Mbps (800 ns)   |    24.4 Mbps (1600 ns)  |    19.5 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS3_LGI      |      26 Mbps (800 ns)   |      54 Mbps (800 ns)   |    32.5 Mbps (1600 ns)  |      26 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS4_LGI      |      39 Mbps (800 ns)   |      81 Mbps (800 ns)   |    48.8 Mbps (1600 ns)  |      39 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS5_LGI      |      52 Mbps (800 ns)   |     108 Mbps (800 ns)   |      65 Mbps (1600 ns)  |      52 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS6_LGI      |    58.5 Mbps (800 ns)   |   121.5 Mbps (800 ns)   |    73.1 Mbps (1600 ns)  |    58.5 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS7_LGI      |      65 Mbps (800 ns)   |     135 Mbps (800 ns)   |    81.3 Mbps (1600 ns)  |      65 Mbps (800 ns)   |
    ##  | WIFI_PHY_RATE_MCS8_LGI      |                         |                         |    97.5 Mbps (1600 ns)  |                         |
    ##  | WIFI_PHY_RATE_MCS9_LGI      |                         |                         |   108.3 Mbps (1600 ns)  |                         |
    ##
    ##  @note
    ##  |       MCS RATE              |          HT20           |          HT40           |          HE20           |         VHT20           |
    ##
    ## |-----------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
    ##  | WIFI_PHY_RATE_MCS0_SGI      |     7.2 Mbps (400 ns)   |      15 Mbps (400 ns)   |      8.6 Mbps (800 ns)  |     7.2 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS1_SGI      |    14.4 Mbps (400 ns)   |      30 Mbps (400 ns)   |     17.2 Mbps (800 ns)  |    14.4 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS2_SGI      |    21.7 Mbps (400 ns)   |      45 Mbps (400 ns)   |     25.8 Mbps (800 ns)  |    21.7 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS3_SGI      |    28.9 Mbps (400 ns)   |      60 Mbps (400 ns)   |     34.4 Mbps (800 ns)  |    28.9 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS4_SGI      |    43.3 Mbps (400 ns)   |      90 Mbps (400 ns)   |     51.6 Mbps (800 ns)  |    43.3 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS5_SGI      |    57.8 Mbps (400 ns)   |     120 Mbps (400 ns)   |     68.8 Mbps (800 ns)  |    57.8 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS6_SGI      |      65 Mbps (400 ns)   |     135 Mbps (400 ns)   |     77.4 Mbps (800 ns)  |      65 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS7_SGI      |    72.2 Mbps (400 ns)   |     150 Mbps (400 ns)   |       86 Mbps (800 ns)  |    72.2 Mbps (400 ns)   |
    ##  | WIFI_PHY_RATE_MCS8_SGI      |                         |                         |    103.2 Mbps (800 ns)  |                         |
    ##  | WIFI_PHY_RATE_MCS9_SGI      |                         |                         |    114.7 Mbps (800 ns)  |                         |
    ##
    ##

let
    WIFI_PHY_RATE_1M_L {.importc: "WIFI_PHY_RATE_1M_L", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_2M_L {.importc: "WIFI_PHY_RATE_2M_L", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_5M_L {.importc: "WIFI_PHY_RATE_5M_L", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_11M_L {.importc: "WIFI_PHY_RATE_11M_L", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_2M_S {.importc: "WIFI_PHY_RATE_2M_S", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_5M_S {.importc: "WIFI_PHY_RATE_5M_S", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_11M_S {.importc: "WIFI_PHY_RATE_11M_S", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_48M {.importc: "WIFI_PHY_RATE_48M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_24M {.importc: "WIFI_PHY_RATE_24M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_12M {.importc: "WIFI_PHY_RATE_12M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_6M {.importc: "WIFI_PHY_RATE_6M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_54M {.importc: "WIFI_PHY_RATE_54M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_36M {.importc: "WIFI_PHY_RATE_36M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_18M {.importc: "WIFI_PHY_RATE_18M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_9M {.importc: "WIFI_PHY_RATE_9M", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS0_LGI {.importc: "WIFI_PHY_RATE_MCS0_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS1_LGI {.importc: "WIFI_PHY_RATE_MCS1_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS2_LGI {.importc: "WIFI_PHY_RATE_MCS2_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS3_LGI {.importc: "WIFI_PHY_RATE_MCS3_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS4_LGI {.importc: "WIFI_PHY_RATE_MCS4_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS5_LGI {.importc: "WIFI_PHY_RATE_MCS5_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS6_LGI {.importc: "WIFI_PHY_RATE_MCS6_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS7_LGI {.importc: "WIFI_PHY_RATE_MCS7_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS8_LGI {.importc: "WIFI_PHY_RATE_MCS8_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS9_LGI {.importc: "WIFI_PHY_RATE_MCS9_LGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS0_SGI {.importc: "WIFI_PHY_RATE_MCS0_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS1_SGI {.importc: "WIFI_PHY_RATE_MCS1_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS2_SGI {.importc: "WIFI_PHY_RATE_MCS2_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS3_SGI {.importc: "WIFI_PHY_RATE_MCS3_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS4_SGI {.importc: "WIFI_PHY_RATE_MCS4_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS5_SGI {.importc: "WIFI_PHY_RATE_MCS5_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS6_SGI {.importc: "WIFI_PHY_RATE_MCS6_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS7_SGI {.importc: "WIFI_PHY_RATE_MCS7_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS8_SGI {.importc: "WIFI_PHY_RATE_MCS8_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MCS9_SGI {.importc: "WIFI_PHY_RATE_MCS9_SGI", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_LORA_250K {.importc: "WIFI_PHY_RATE_LORA_250K", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_LORA_500K {.importc: "WIFI_PHY_RATE_LORA_500K", header: hdr.}: wifi_phy_rate_t
    WIFI_PHY_RATE_MAX {.importc: "WIFI_PHY_RATE_MAX", header: hdr.}: wifi_phy_rate_t


type

  wifi_event_t* {.size: sizeof(cint).} = enum ##
                                               ##  @brief Wi-Fi event declarations
                                               ##
    WIFI_EVENT_WIFI_READY = 0, ## < Wi-Fi ready
    WIFI_EVENT_SCAN_DONE,   ## < Finished scanning AP
    WIFI_EVENT_STA_START,   ## < Station start
    WIFI_EVENT_STA_STOP,    ## < Station stop
    WIFI_EVENT_STA_CONNECTED, ## < Station connected to AP
    WIFI_EVENT_STA_DISCONNECTED, ## < Station disconnected from AP
    WIFI_EVENT_STA_AUTHMODE_CHANGE, ## < The auth mode of AP connected by device's station changed
    WIFI_EVENT_STA_WPS_ER_SUCCESS, ## < Station WPS succeeds in enrollee mode
    WIFI_EVENT_STA_WPS_ER_FAILED, ## < Station WPS fails in enrollee mode
    WIFI_EVENT_STA_WPS_ER_TIMEOUT, ## < Station WPS timeout in enrollee mode
    WIFI_EVENT_STA_WPS_ER_PIN, ## < Station WPS pin code in enrollee mode
    WIFI_EVENT_STA_WPS_ER_PBC_OVERLAP, ## < Station WPS overlap in enrollee mode
    WIFI_EVENT_AP_START,    ## < Soft-AP start
    WIFI_EVENT_AP_STOP,     ## < Soft-AP stop
    WIFI_EVENT_AP_STACONNECTED, ## < A station connected to Soft-AP
    WIFI_EVENT_AP_STADISCONNECTED, ## < A station disconnected from Soft-AP
    WIFI_EVENT_AP_PROBEREQRECVED, ## < Receive probe request packet in soft-AP interface
    WIFI_EVENT_FTM_REPORT,  ## < Receive report of FTM procedure
                             ##  Add next events after this only
    WIFI_EVENT_STA_BSS_RSSI_LOW, ## < AP's RSSI crossed configured threshold
    WIFI_EVENT_ACTION_TX_STATUS, ## < Status indication of Action Tx operation
    WIFI_EVENT_ROC_DONE,    ## < Remain-on-Channel operation complete
    WIFI_EVENT_STA_BEACON_TIMEOUT, ## < Station beacon timeout
    WIFI_EVENT_CONNECTIONLESS_MODULE_WAKE_INTERVAL_START, ##
                              ## < Connectionless module wake interval start
                              ##  Add next events after this only
    WIFI_EVENT_AP_WPS_RG_SUCCESS, ## < Soft-AP wps succeeds in registrar mode
    WIFI_EVENT_AP_WPS_RG_FAILED, ## < Soft-AP wps fails in registrar mode
    WIFI_EVENT_AP_WPS_RG_TIMEOUT, ## < Soft-AP wps timeout in registrar mode
    WIFI_EVENT_AP_WPS_RG_PIN, ## < Soft-AP wps pin code in registrar mode
    WIFI_EVENT_AP_WPS_RG_PBC_OVERLAP, ## < Soft-AP wps overlap in registrar mode
    WIFI_EVENT_ITWT_SETUP,  ## < iTWT setup
    WIFI_EVENT_ITWT_TEARDOWN, ## < iTWT teardown
    WIFI_EVENT_ITWT_PROBE,  ## < iTWT probe
    WIFI_EVENT_ITWT_SUSPEND, ## < iTWT suspend
    WIFI_EVENT_TWT_WAKEUP,  ## < TWT wakeup
    WIFI_EVENT_BTWT_SETUP,  ## < bTWT setup
    WIFI_EVENT_BTWT_TEARDOWN, ## < bTWT teardown
    WIFI_EVENT_NAN_STARTED, ## < NAN Discovery has started
    WIFI_EVENT_NAN_STOPPED, ## < NAN Discovery has stopped
    WIFI_EVENT_NAN_SVC_MATCH, ## < NAN Service Discovery match found
    WIFI_EVENT_NAN_REPLIED, ## < Replied to a NAN peer with Service Discovery match
    WIFI_EVENT_NAN_RECEIVE, ## < Received a Follow-up message
    WIFI_EVENT_NDP_INDICATION, ## < Received NDP Request from a NAN Peer
    WIFI_EVENT_NDP_CONFIRM, ## < NDP Confirm Indication
    WIFI_EVENT_NDP_TERMINATED, ## < NAN Datapath terminated indication
    WIFI_EVENT_HOME_CHANNEL_CHANGE, ## < Wi-Fi home channel change，doesn't occur when scanning
    WIFI_EVENT_STA_NEIGHBOR_REP, ## < Received Neighbor Report response
    WIFI_EVENT_AP_WRONG_PASSWORD, ## < a station tried to connect with wrong password
    WIFI_EVENT_STA_BEACON_OFFSET_UNSTABLE, ## < Station sampled beacon offset unstable
    WIFI_EVENT_DPP_URI_READY, ## < DPP URI is ready through Bootstrapping
    WIFI_EVENT_DPP_CFG_RECVD, ## < Config received via DPP Authentication
    WIFI_EVENT_DPP_FAILED,  ## < DPP failed
    WIFI_EVENT_MAX           ## < Invalid Wi-Fi event ID


##  @cond *
##  @brief Wi-Fi event base declaration

# ESP_EVENT_DECLARE_BASE(WIFI_EVENT)
let WIFI_EVENT* {.importc: "WIFI_EVENT", header: "esp_wifi_types.h".}: esp_event_base_t 

type

  wifi_event_sta_scan_done_t* {.importc: "wifi_event_sta_scan_done_t",
                                header: hdr, bycopy.} = object ##
                              ##  @endcond *
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_SCAN_DONE event
                              ##
    status* {.importc: "status".}: uint32 ## < Status of scanning APs: 0 — success, 1 - failure
    number* {.importc: "number".}: uint8 ## < Number of scan results
    scan_id* {.importc: "scan_id".}: uint8
    ## < Scan sequence number, used for block scan


  wifi_event_sta_connected_t* {.importc: "wifi_event_sta_connected_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_CONNECTED event
                              ##
    ssid* {.importc: "ssid".}: array[32, uint8] ## < SSID of connected AP
    ssid_len* {.importc: "ssid_len".}: uint8 ## < SSID length of connected AP
    bssid* {.importc: "bssid".}: array[6, uint8] ## < BSSID of connected AP
    channel* {.importc: "channel".}: uint8 ## < Channel of connected AP
    authmode* {.importc: "authmode".}: wifi_auth_mode_t ##
                              ## < Authentication mode used by the connection
    aid* {.importc: "aid".}: uint16
    ## < Authentication id assigned by the connected AP


  wifi_event_sta_disconnected_t* {.importc: "wifi_event_sta_disconnected_t",
                                   header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_DISCONNECTED event
                              ##
    ssid* {.importc: "ssid".}: array[32, uint8] ## < SSID of disconnected AP
    ssid_len* {.importc: "ssid_len".}: uint8 ## < SSID length of disconnected AP
    bssid* {.importc: "bssid".}: array[6, uint8] ## < BSSID of disconnected AP
    reason* {.importc: "reason".}: uint8 ## < Disconnection reason
    rssi* {.importc: "rssi".}: int8
    ## < Disconnection RSSI


  wifi_event_sta_authmode_change_t* {.importc: "wifi_event_sta_authmode_change_t",
                                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_AUTHMODE_CHANGE event
                              ##
    old_mode* {.importc: "old_mode".}: wifi_auth_mode_t ##
                              ## < Old auth mode of AP
    new_mode* {.importc: "new_mode".}: wifi_auth_mode_t
    ## < New auth mode of AP


  wifi_event_sta_wps_er_pin_t* {.importc: "wifi_event_sta_wps_er_pin_t",
                                 header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_WPS_ER_PIN event
                              ##
    pin_code* {.importc: "pin_code".}: array[8, uint8]
    ## < PIN code of station in enrollee mode


  wifi_event_sta_wps_fail_reason_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_WPS_ER_FAILED event
                              ##
    WPS_FAIL_REASON_NORMAL = 0, ## < WPS normal fail reason
    WPS_FAIL_REASON_RECV_M2D, ## < WPS receive M2D frame
    WPS_FAIL_REASON_RECV_DEAUTH, ## < Recv deauth from AP while wps handshake
    WPS_FAIL_REASON_MAX      ## < Max WPS fail reason

const
  MAX_SSID_LEN* = 32
  MAX_PASSPHRASE_LEN* = 64
  MAX_WPS_AP_CRED* = 3

type

  INNER_C_STRUCT_esp_wifi_types_generic_1* {.
      importc: "wifi_event_sta_wps_er_success_t::no_name",
      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_WPS_ER_SUCCESS event
                              ##
    ssid* {.importc: "ssid".}: array[MAX_SSID_LEN, uint8] ##
                              ## < SSID of AP
    passphrase* {.importc: "passphrase".}: array[MAX_PASSPHRASE_LEN, uint8]
    ## < Passphrase for the AP


  wifi_event_sta_wps_er_success_t* {.importc: "wifi_event_sta_wps_er_success_t",
                                     header: hdr, bycopy.} = object
    ap_cred_cnt* {.importc: "ap_cred_cnt".}: uint8 ##
                              ## < Number of AP credentials received
    ap_cred* {.importc: "ap_cred".}: array[MAX_WPS_AP_CRED,
        INNER_C_STRUCT_esp_wifi_types_generic_1]
    ## < All AP credentials received from WPS handshake


  wifi_event_ap_staconnected_t* {.importc: "wifi_event_ap_staconnected_t",
                                  header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_STACONNECTED event
                              ##
    mac* {.importc: "mac".}: array[6, uint8] ## < MAC address of the station connected to Soft-AP
    aid* {.importc: "aid".}: uint8 ## < AID assigned by the Soft-AP to the connected station
    is_mesh_child* {.importc: "is_mesh_child".}: bool
    ## < Flag indicating whether the connected station is a mesh child


  wifi_event_ap_stadisconnected_t* {.importc: "wifi_event_ap_stadisconnected_t",
                                     header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_STADISCONNECTED event
                              ##
    mac* {.importc: "mac".}: array[6, uint8] ## < MAC address of the station disconnects from the soft-AP
    aid* {.importc: "aid".}: uint8 ## < AID that the Soft-AP assigned to the disconnected station
    is_mesh_child* {.importc: "is_mesh_child".}: bool ##
                              ## < Flag indicating whether the disconnected station is a mesh child
    reason* {.importc: "reason".}: uint16
    ## < Disconnection reason


  wifi_event_ap_probe_req_rx_t* {.importc: "wifi_event_ap_probe_req_rx_t",
                                  header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_PROBEREQRECVED event
                              ##
    rssi* {.importc: "rssi".}: cint ## < Received probe request signal strength
    mac* {.importc: "mac".}: array[6, uint8]
    ## < MAC address of the station which send probe request


  wifi_event_bss_rssi_low_t* {.importc: "wifi_event_bss_rssi_low_t",
                               header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_BSS_RSSI_LOW event
                              ##
    rssi* {.importc: "rssi".}: int32
    ## < RSSI value of bss


  wifi_event_home_channel_change_t* {.importc: "wifi_event_home_channel_change_t",
                                      header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_HOME_CHANNEL_CHANGE event
                              ##
    old_chan* {.importc: "old_chan".}: uint8 ## < Old home channel of the device
    old_snd* {.importc: "old_snd".}: wifi_second_chan_t ##
                              ## < Old second channel of the device
    new_chan* {.importc: "new_chan".}: uint8 ## < New home channel of the device
    new_snd* {.importc: "new_snd".}: wifi_second_chan_t
    ## < New second channel of the device


  wifi_ftm_status_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief FTM operation status types
                              ##
                              ##
    FTM_STATUS_SUCCESS = 0, ## < FTM exchange is successful
    FTM_STATUS_UNSUPPORTED, ## < Peer does not support FTM
    FTM_STATUS_CONF_REJECTED, ## < Peer rejected FTM configuration in FTM Request
    FTM_STATUS_NO_RESPONSE, ## < Peer did not respond to FTM Requests
    FTM_STATUS_FAIL,        ## < Unknown error during FTM exchange
    FTM_STATUS_NO_VALID_MSMT, ## < FTM session did not result in any valid measurements
    FTM_STATUS_USER_TERM     ## < User triggered termination


type

  wifi_ftm_report_entry_t* {.importc: "wifi_ftm_report_entry_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Structure representing a report entry for Fine Timing Measurement (FTM) in Wi-Fi.
                              ##
                              ##  This structure holds the information related to the FTM process between a Wi-Fi FTM Initiator
                              ##  and a Wi-Fi FTM Responder. FTM is used for precise distance measurement by timing the exchange
                              ##  of frames between devices.
                              ##
    dlog_token* {.importc: "dlog_token".}: uint8 ## < Dialog Token of the FTM frame
    rssi* {.importc: "rssi".}: int8 ## < RSSI of the FTM frame received
    rtt* {.importc: "rtt".}: uint32 ## < Round Trip Time in pSec with a peer
    t1* {.importc: "t1".}: uint64 ## < Time of departure of FTM frame from FTM Responder in pSec
    t2* {.importc: "t2".}: uint64 ## < Time of arrival of FTM frame at FTM Initiator in pSec
    t3* {.importc: "t3".}: uint64 ## < Time of departure of ACK from FTM Initiator in pSec
    t4* {.importc: "t4".}: uint64
    ## < Time of arrival of ACK at FTM Responder in pSec


  wifi_event_ftm_report_t* {.importc: "wifi_event_ftm_report_t",
                             header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_FTM_REPORT event
                              ##
    peer_mac* {.importc: "peer_mac".}: array[6, uint8] ##
                              ## < MAC address of the FTM Peer
    status* {.importc: "status".}: wifi_ftm_status_t ##
                              ## < Status of the FTM operation
    rtt_raw* {.importc: "rtt_raw".}: uint32 ## < Raw average Round-Trip-Time with peer in Nano-Seconds
    rtt_est* {.importc: "rtt_est".}: uint32 ## < Estimated Round-Trip-Time with peer in Nano-Seconds
    dist_est* {.importc: "dist_est".}: uint32 ## < Estimated one-way distance in Centi-Meters
    ftm_report_data* {.importc: "ftm_report_data".}: ptr wifi_ftm_report_entry_t ##
                              ## < Pointer to FTM Report, should be freed after use. Note: Highly recommended
                              ##                                                      to use API esp_wifi_ftm_get_report to get the report instead of using this
    ftm_report_num_entries* {.importc: "ftm_report_num_entries".}: uint8
    ## < Number of entries in the FTM Report data


const
  WIFI_STATIS_BUFFER* = (1 shl 0) ## < Buffer status
  WIFI_STATIS_RXTX* = (1 shl 1) ## < RX/TX status
  WIFI_STATIS_HW* = (1 shl 2) ## < Hardware status
  WIFI_STATIS_DIAG* = (1 shl 3) ## < Diagnostic status
  WIFI_STATIS_PS* = (1 shl 4) ## < Power save status
  WIFI_STATIS_ALL* = (-1)    ## < All status

type

  wifi_action_tx_status_type_t* {.size: sizeof(cint).} = enum ##
                              ##  Status codes for WIFI_EVENT_ACTION_TX_STATUS evt
                              ##  There will be back to back events in success case TX_DONE and TX_DURATION_COMPLETED
    WIFI_ACTION_TX_DONE = 0, ## < ACTION_TX operation was completed successfully
    WIFI_ACTION_TX_FAILED,  ## < ACTION_TX operation failed during tx
    WIFI_ACTION_TX_DURATION_COMPLETED, ## < ACTION_TX operation completed it's wait duration
    WIFI_ACTION_TX_OP_CANCELLED ## < ACTION_TX operation was cancelled by application or higher priority operation


type

  wifi_event_action_tx_status_t* {.importc: "wifi_event_action_tx_status_t",
                                   header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_ACTION_TX_STATUS event
    ifx* {.importc: "ifx".}: wifi_interface_t ## < WiFi interface to send request to
    context* {.importc: "context".}: uint32 ## < Context to identify the request
    status* {.importc: "status".}: wifi_action_tx_status_type_t ##
                              ## < Status of the operation
    op_id* {.importc: "op_id".}: uint8 ## < ID of the corresponding operation that was provided during action tx request
    channel* {.importc: "channel".}: uint8
    ## < Channel provided in tx request


  wifi_event_roc_done_t* {.importc: "wifi_event_roc_done_t",
                           header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_ROC_DONE event
                              ##
    context* {.importc: "context".}: uint32 ## < Context to identify the initiator of the request
    status* {.importc: "status".}: wifi_roc_done_status_t ##
                              ## < ROC status
    op_id* {.importc: "op_id".}: uint8 ## < ID of the corresponding ROC operation
    channel* {.importc: "channel".}: uint8
    ## < Channel provided in tx request


  wifi_event_ap_wps_rg_pin_t* {.importc: "wifi_event_ap_wps_rg_pin_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_WPS_RG_PIN event
                              ##
    pin_code* {.importc: "pin_code".}: array[8, uint8]
    ## < PIN code of station in enrollee mode


  wps_fail_reason_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief WPS fail reason
                              ##
    WPS_AP_FAIL_REASON_NORMAL = 0, ## < WPS normal fail reason
    WPS_AP_FAIL_REASON_CONFIG, ## < WPS failed due to incorrect config
    WPS_AP_FAIL_REASON_AUTH, ## < WPS failed during auth
    WPS_AP_FAIL_REASON_MAX   ## < Max WPS fail reason


type

  wifi_event_ap_wps_rg_fail_reason_t* {.importc: "wifi_event_ap_wps_rg_fail_reason_t",
                                        header: hdr,
                                        bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_WPS_RG_FAILED event
                              ##
    reason* {.importc: "reason".}: wps_fail_reason_t ##
                              ## < WPS failure reason wps_fail_reason_t
    peer_macaddr* {.importc: "peer_macaddr".}: array[6, uint8]
    ## < Enrollee mac address


  wifi_event_ap_wps_rg_success_t* {.importc: "wifi_event_ap_wps_rg_success_t",
                                    header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_AP_WPS_RG_SUCCESS event
                              ##
    peer_macaddr* {.importc: "peer_macaddr".}: array[6, uint8]
    ## < Enrollee mac address


  wifi_event_nan_svc_match_t* {.importc: "wifi_event_nan_svc_match_t",
                                header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NAN_SVC_MATCH event
                              ##
    subscribe_id* {.importc: "subscribe_id".}: uint8 ##
                              ## < Subscribe Service Identifier
    publish_id* {.importc: "publish_id".}: uint8 ## < Publish Service Identifier
    pub_if_mac* {.importc: "pub_if_mac".}: array[6, uint8] ##
                              ## < NAN Interface MAC of the Publisher
    update_pub_id* {.importc: "update_pub_id".}: bool ##
                              ## < Indicates whether publisher's service ID needs to be updated
    datapath_reqd* {.importc: "datapath_reqd", bitsize: 1.}: uint8 ##
                              ## < NAN Datapath required for the service
    fsd_reqd* {.importc: "fsd_reqd", bitsize: 1.}: uint8 ##
                              ## < Further Service Discovery(FSD) required
    fsd_gas* {.importc: "fsd_gas", bitsize: 1.}: uint8 ##
                              ## < 0 - Follow-up used for FSD, 1 - GAS used for FSD
    reserved* {.importc: "reserved", bitsize: 5.}: uint8 ##
                              ## < Reserved
    reserved_1* {.importc: "reserved_1".}: uint32 ## < Reserved
    reserved_2* {.importc: "reserved_2".}: uint32 ## < Reserved
    ssi_version* {.importc: "ssi_version".}: uint8 ##
                              ## < Indicates version of SSI in Publish instance, 0 if not available
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info
    ssi* {.importc: "ssi".}: UncheckedArray[uint8]
    ## < Service specific info of Publisher


  wifi_event_nan_replied_t* {.importc: "wifi_event_nan_replied_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NAN_REPLIED event
                              ##
    publish_id* {.importc: "publish_id".}: uint8 ## < Publish Service Identifier
    subscribe_id* {.importc: "subscribe_id".}: uint8 ##
                              ## < Subscribe Service Identifier
    sub_if_mac* {.importc: "sub_if_mac".}: array[6, uint8] ##
                              ## < NAN Interface MAC of the Subscriber
    reserved_1* {.importc: "reserved_1".}: uint32 ## < Reserved
    reserved_2* {.importc: "reserved_2".}: uint32 ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info
    ssi* {.importc: "ssi".}: UncheckedArray[uint8]
    ## < Service specific info of Subscriber


  wifi_event_nan_receive_t* {.importc: "wifi_event_nan_receive_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NAN_RECEIVE event
                              ##
    inst_id* {.importc: "inst_id".}: uint8 ## < Our Service Identifier
    peer_inst_id* {.importc: "peer_inst_id".}: uint8 ##
                              ## < Peer's Service Identifier
    peer_if_mac* {.importc: "peer_if_mac".}: array[6, uint8] ##
                              ## < Peer's NAN Interface MAC
    peer_svc_info* {.importc: "peer_svc_info".}: array[
        ESP_WIFI_MAX_SVC_INFO_LEN, uint8] ## < To be deprecated in next major release, use ssi instead
    reserved_1* {.importc: "reserved_1".}: uint32 ## < Reserved
    reserved_2* {.importc: "reserved_2".}: uint32 ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info
    ssi* {.importc: "ssi".}: UncheckedArray[uint8]
    ## < Service specific info from Follow-up


  wifi_event_ndp_indication_t* {.importc: "wifi_event_ndp_indication_t",
                                 header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NDP_INDICATION event
                              ##
    publish_id* {.importc: "publish_id".}: uint8 ## < Publish Id for NAN Service
    ndp_id* {.importc: "ndp_id".}: uint8 ## < NDP instance id
    peer_nmi* {.importc: "peer_nmi".}: array[6, uint8] ##
                              ## < Peer's NAN Management Interface MAC
    peer_ndi* {.importc: "peer_ndi".}: array[6, uint8] ##
                              ## < Peer's NAN Data Interface MAC
    svc_info* {.importc: "svc_info".}: array[ESP_WIFI_MAX_SVC_INFO_LEN, uint8] ##
                              ## < To be deprecated in next major release, use ssi instead
    reserved_1* {.importc: "reserved_1".}: uint32 ## < Reserved
    reserved_2* {.importc: "reserved_2".}: uint32 ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of service specific info
    ssi* {.importc: "ssi".}: UncheckedArray[uint8]
    ## < Service specific info from NDP/NDPE Attribute


  wifi_event_ndp_confirm_t* {.importc: "wifi_event_ndp_confirm_t",
                              header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NDP_CONFIRM event
                              ##
    status* {.importc: "status".}: uint8 ## < NDP status code
    ndp_id* {.importc: "ndp_id".}: uint8 ## < NDP instance id
    peer_nmi* {.importc: "peer_nmi".}: array[6, uint8] ##
                              ## < Peer's NAN Management Interface MAC
    peer_ndi* {.importc: "peer_ndi".}: array[6, uint8] ##
                              ## < Peer's NAN Data Interface MAC
    own_ndi* {.importc: "own_ndi".}: array[6, uint8] ##
                              ## < Own NAN Data Interface MAC
    svc_info* {.importc: "svc_info".}: array[ESP_WIFI_MAX_SVC_INFO_LEN, uint8] ##
                              ## < To be deprecated in next major release, use ssi instead
    reserved_1* {.importc: "reserved_1".}: uint32 ## < Reserved
    reserved_2* {.importc: "reserved_2".}: uint32 ## < Reserved
    ssi_len* {.importc: "ssi_len".}: uint16 ## < Length of Service Specific Info
    ssi* {.importc: "ssi".}: UncheckedArray[uint8]
    ## < Service specific info from NDP/NDPE Attribute


  wifi_event_ndp_terminated_t* {.importc: "wifi_event_ndp_terminated_t",
                                 header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_NDP_TERMINATED event
                              ##
    reason* {.importc: "reason".}: uint8 ## < Termination reason code
    ndp_id* {.importc: "ndp_id".}: uint8 ## < NDP instance id
    init_ndi* {.importc: "init_ndi".}: array[6, uint8]
    ## < Initiator's NAN Data Interface MAC


  wifi_event_neighbor_report_t* {.importc: "wifi_event_neighbor_report_t",
                                  header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for WIFI_EVENT_STA_NEIGHBOR_REP event
                              ##
    report* {.importc: "report".}: array[ESP_WIFI_MAX_NEIGHBOR_REP_LEN, uint8] ##
                              ## < Neighbor Report received from the AP (will be deprecated in next major release, use n_report instead)
    report_len* {.importc: "report_len".}: uint16 ## < Length of the report
    n_report* {.importc: "n_report".}: UncheckedArray[uint8]
    ## < Neighbor Report received from the AP


  wifi_event_ap_wrong_password_t* {.importc: "wifi_event_ap_wrong_password_t",
                                    header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_AP_WRONG_PASSWORD event
    mac* {.importc: "mac".}: array[6, uint8]
    ## < MAC address of the station trying to connect to Soft-AP


  wifi_tx_rate_config_t* {.importc: "wifi_tx_rate_config_t",
                           header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Argument structure for wifi_tx_rate_config
                              ##
    phymode* {.importc: "phymode".}: wifi_phy_mode_t ##
                              ## < Phymode of specified interface
    rate* {.importc: "rate".}: wifi_phy_rate_t ## < Rate of specified interface
    ersu* {.importc: "ersu".}: bool ## < Using ERSU to send frame, ERSU is a transmission mode related to 802.11 ax.
                                    ##                                                   ERSU is always used in long distance transmission, and its frame has lower rate compared with SU mode
    dcm* {.importc: "dcm".}: bool
    ## < Using dcm rate to send frame


const
  WIFI_MAX_SUPPORT_COUNTRY_NUM* = 176

when defined(CONFIG_SOC_WIFI_SUPPORT_5G):
  const
    WIFI_MAX_REGULATORY_RULE_NUM* = 7
else:
  const
    WIFI_MAX_REGULATORY_RULE_NUM* = 2
type

  wifi_reg_rule_t* {.importc: "wifi_reg_rule_t",
                     header: hdr, bycopy.} = object ##
                              ##  Argument structure for regulatory rule
    start_channel* {.importc: "start_channel".}: uint8 ##
                              ## < start channel of regulatory rule
    end_channel* {.importc: "end_channel".}: uint8 ##
                              ## < end channel of regulatory rule
    max_bandwidth* {.importc: "max_bandwidth", bitsize: 3.}: uint16 ##
                              ## < max bandwidth(MHz) of regulatory rule, 1:20M, 2:40M, 3:80M, 4:160M
    max_eirp* {.importc: "max_eirp", bitsize: 6.}: uint16 ##
                              ## < indicates the maximum Equivalent Isotropically Radiated Power (EIRP), typically measured in dBm
    is_dfs* {.importc: "is_dfs", bitsize: 1.}: uint16 ##
                              ## < flag to identify dfs channel
    reserved* {.importc: "reserved", bitsize: 6.}: uint16
    ## < reserved


  wifi_regulatory_t* {.importc: "wifi_regulatory_t",
                       header: hdr, bycopy.} = object ##
                              ##  Argument structure for regdomain
    n_reg_rules* {.importc: "n_reg_rules".}: uint8 ##
                              ## < number of regulatory rules
    reg_rules* {.importc: "reg_rules".}: array[WIFI_MAX_REGULATORY_RULE_NUM,
        wifi_reg_rule_t]
    ## < array of regulatory rules


  wifi_regdomain_t* {.importc: "wifi_regdomain_t",
                      header: hdr, bycopy.} = object ##
                              ##  Argument structure for regdomain
    cn* {.importc: "cn".}: array[2, char] ## < country code string
    regulatory_type* {.importc: "regulatory_type".}: uint8
    ## < regulatory type of country


  wifi_tx_status_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Status of wifi sending data
                              ##
    WIFI_SEND_SUCCESS = 0,  ## < Sending Wi-Fi data successfully
    WIFI_SEND_FAIL           ## < Sending Wi-Fi data fail


type

  wifi_tx_info_t* {.importc: "wifi_tx_info_t",
                    header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Information of wifi sending data
                              ##
    des_addr* {.importc: "des_addr".}: ptr uint8 ## < The address of the receive device
    src_addr* {.importc: "src_addr".}: ptr uint8 ## < The address of the sending device
    ifidx* {.importc: "ifidx".}: wifi_interface_t ## < Interface of sending 80211 tx data
    data* {.importc: "data".}: ptr uint8 ## < The data for 80211 tx, start from the MAC header
    data_len* {.importc: "data_len".}: uint8 ## < The frame body length for 80211 tx, excluding the MAC header
    rate* {.importc: "rate".}: wifi_phy_rate_t ## < Data rate
    tx_status* {.importc: "tx_status".}: wifi_tx_status_t
    ## < Status of sending 80211 tx data


  esp_80211_tx_info_t* = wifi_tx_info_t

  wifi_event_sta_beacon_offset_unstable_t* {.
      importc: "wifi_event_sta_beacon_offset_unstable_t",
      header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_STA_BEACON_OFFSET_UNSTABLE event
    beacon_success_rate* {.importc: "beacon_success_rate".}: cfloat
    ## < Received beacon success rate


  wifi_event_dpp_uri_ready_t* {.importc: "wifi_event_dpp_uri_ready_t",
                                header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_DPP_URI_READY event
    uri_data_len* {.importc: "uri_data_len".}: uint32 ##
                              ## < URI data length including null termination
    uri* {.importc: "uri".}: UncheckedArray[char]
    ## < URI data


  wifi_event_dpp_config_received_t* {.importc: "wifi_event_dpp_config_received_t",
                                      header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_DPP_CFG_RECVD event
    wifi_cfg* {.importc: "wifi_cfg".}: wifi_config_t
    ## < Received WIFI config in DPP


  wifi_event_dpp_failed_t* {.importc: "wifi_event_dpp_failed_t",
                             header: hdr, bycopy.} = object ##
                              ##  Argument structure for WIFI_EVENT_DPP_FAIL event
    failure_reason* {.importc: "failure_reason".}: cint
    ## < Failure reason

