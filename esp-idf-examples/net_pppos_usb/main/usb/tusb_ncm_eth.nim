import nesper
import nesper/[general, events]
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_types
import nesper/esp/net/esp_netif_defaults
import nesper/components/esp_tinyusb/tinyusb

# TinyUSB NET imports
type
  tinyusb_net_config_t* {.importc: "tinyusb_net_config_t", header: "tinyusb_net.h", bycopy.} = object
    mac_addr* {.importc: "mac_addr".}: array[6, uint8]
    on_recv_callback* {.importc: "on_recv_callback".}: proc (buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.}
    free_tx_buffer* {.importc: "free_tx_buffer".}: proc (eb: pointer; ctx: pointer) {.cdecl.}
    on_init_callback* {.importc: "on_init_callback".}: proc (ctx: pointer) {.cdecl.}
    user_context* {.importc: "user_context".}: pointer

proc tinyusb_net_init*(dev: tinyusb_usbdev_t; cfg: ptr tinyusb_net_config_t): esp_err_t {.cdecl, importc: "tinyusb_net_init", header: "tinyusb_net.h".}
proc tinyusb_net_send_sync*(buffer: pointer; len: uint16; eb: pointer; timeout_ticks: uint32): esp_err_t {.cdecl, importc: "tinyusb_net_send_sync", header: "tinyusb_net.h".}

const TAG* = "USB_NCM_ETH"

var
  sNetif: ptr esp_netif_t

# RX from USB NCM into esp-netif (L3 stack)
proc ncmRecvToNetif(buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.} =
  if sNetif != nil and len.uint32 > 0'u32:
    discard esp_netif_receive(sNetif, buffer, len.csize_t, nil)
  return ESP_OK

# esp-netif transmit to USB NCM
proc ncmTransmit(h: pointer; buffer: pointer; len: csize_t): esp_err_t {.cdecl.} =
  let res = tinyusb_net_send_sync(buffer, uint16(len), nil, portMAX_DELAY.uint32)
  return res

# IP event logging
proc onIpEvent(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  if event_base == IP_EVENT and event_id == IP_EVENT_GOT_IP6.int32:
    let ev6 = cast[ptr ip_event_got_ip6_t](event_data)
    if ev6.esp_netif == sNetif:
      logi(TAG, "Got IPv6: %s", $ev6.ip6_info.ip)
  elif event_base == IP_EVENT and event_id == IP_EVENT_ETH_GOT_IP.int32:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    if ev.esp_netif == sNetif:
      logi(TAG, "Got IPv4: %s", $ev.ip_info.ip)

proc runUsbNcmAsEth*() =
  # Netif + event loop
  check: esp_netif_init()
  check: esp_event_loop_create_default()

  # TinyUSB init
  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  # MAC address
  var mac: array[6, uint8]
  check: esp_read_mac(addr mac[0], ESP_MAC_WIFI_STA)
  logi(TAG, "Using MAC: %02x:%02x:%02x:%02x:%02x:%02x", mac[0].int, mac[1].int, mac[2].int, mac[3].int, mac[4].int, mac[5].int)

  # TinyUSB NET config
  var ncfg: tinyusb_net_config_t
  for i in 0..5: ncfg.mac_addr[i] = mac[i]
  ncfg.on_recv_callback = ncmRecvToNetif
  ncfg.free_tx_buffer = nil
  ncfg.on_init_callback = nil
  ncfg.user_context = nil
  check: tinyusb_net_init(TINYUSB_USBDEV_0, addr ncfg)

  # Create an Ethernet-like esp-netif bound to NCM
  var baseCfg = ESP_NETIF_INHERENT_DEFAULT_ETH()
  baseCfg.if_desc = "usb_ncm_eth"
  var driverCfg: esp_netif_driver_ifconfig_t
  driverCfg.handle = cast[pointer](1)
  driverCfg.transmit = ncmTransmit
  var netifCfg: esp_netif_config_t
  netifCfg.base = addr baseCfg
  netifCfg.driver = addr driverCfg
  netifCfg.stack = ESP_NETIF_NETSTACK_DEFAULT_ETH

  sNetif = esp_netif_new(addr netifCfg)
  doAssert sNetif != nil
  discard esp_netif_set_mac(sNetif, addr mac[0])

  # Listen for IP events
  check: esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID, onIpEvent, nil)

  # Bring up interface; DHCP client should run per default ETH config
  esp_netif_action_start(sNetif, nil, 0, nil)
  esp_netif_action_connected(sNetif, nil, 0, nil)

  logi(TAG, "USB NCM Ethernet-like interface started")

