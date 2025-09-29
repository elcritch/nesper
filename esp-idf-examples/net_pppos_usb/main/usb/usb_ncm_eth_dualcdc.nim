import nesper
import nesper/[general, events]
import nesper/esp/esp_log
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_types
import nesper/esp/net/esp_netif_defaults
import nesper/components/esp_tinyusb/tinyusb
import nesper/components/esp_tinyusb/tusb_cdc_acm


const TAG* = "ncm_eth_dualcdc"

var
  sNetif: ptr esp_netif_t

# NCM RX -> L3 stack
proc ncmRecvToNetif(buffer: pointer; len: uint16; ctx: pointer): esp_err_t {.cdecl.} =
  if sNetif != nil and len.uint32 > 0'u32:
    discard esp_netif_receive(sNetif, buffer, len.csize_t, nil)
  return ESP_OK

# L3 TX -> NCM
proc ncmTransmit(h: pointer; buffer: pointer; len: csize_t): esp_err_t {.cdecl.} =
  result = tinyusb_net_send_sync(buffer, uint16(len), nil, portMAX_DELAY.uint32)

# IP event logging
proc onIpEvent(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  if event_base == IP_EVENT and event_id == IP_EVENT_ETH_GOT_IP.int32:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    if ev.esp_netif == sNetif:
      logi(TAG, "Got IPv4: %s", $ev.ip_info.ip)
  elif event_base == IP_EVENT and event_id == IP_EVENT_GOT_IP6.int32:
    let ev6 = cast[ptr ip_event_got_ip6_t](event_data)
    if ev6.esp_netif == sNetif:
      logi(TAG, "Got IPv6: %s", $ev6.ip6_info.ip)

proc runUsbNcmEthWithConsole*() =
  # Netif + event loop
  check: esp_netif_init()
  check: esp_event_loop_create_default()

  # Read MAC before enabling USB so we can set it immediately
  var mac: array[6, uint8]
  check: esp_read_mac(addr mac[0], ESP_MAC_WIFI_STA)
  logi(TAG, "Using MAC: %02x:%02x:%02x:%02x:%02x:%02x", mac[0].int, mac[1].int, mac[2].int, mac[3].int, mac[4].int, mac[5].int)

  # TinyUSB device stack
  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  # Initialize TinyUSB NET (NCM) as early as possible so host can read MAC string
  var ncfg: tinyusb_net_config_t
  for i in 0..5: ncfg.mac_addr[i] = mac[i]
  ncfg.on_recv_callback = ncmRecvToNetif
  ncfg.free_tx_buffer = nil
  ncfg.on_init_callback = nil
  ncfg.user_context = nil
  check: tinyusb_net_init(TINYUSB_USBDEV_0, addr ncfg)

  # CDC ACM for console on CDC1 (leave CDC0 free if desired)
  var acmLog: tinyusb_config_cdcacm_t
  acmLog.usb_dev = TINYUSB_USBDEV_0
  acmLog.cdc_port = TINYUSB_CDC_ACM_1
  check: tusb_cdc_acm_init(addr acmLog)
  check: esp_tusb_init_console(TINYUSB_CDC_ACM_1)

  # Create Ethernet-like netif backed by NCM
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

  # Bring up netif; DHCP client will run per default ETH config
  esp_netif_action_start(sNetif, nil, 0, nil)
  esp_netif_action_connected(sNetif, nil, 0, nil)

  logi(TAG, "USB NCM Ethernet + CDC console started")

proc stopUsbNcmEthWithConsole*() =
  if sNetif != nil:
    esp_netif_action_disconnected(sNetif, nil, 0, nil)
    esp_netif_action_stop(sNetif, nil, 0, nil)
    esp_netif_destroy(sNetif)
    sNetif = nil
  discard esp_tusb_deinit_console(TINYUSB_CDC_ACM_1)
