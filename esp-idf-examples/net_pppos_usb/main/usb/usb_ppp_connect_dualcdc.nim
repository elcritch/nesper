import nesper
import nesper/[general]
import nesper/esp/[esp_log, esp_event, event_groups]
import nesper/events
import nesper/esp/net/[esp_netif, esp_netif_ppp, esp_netif_types]
import nesper/components/esp_tinyusb/[tinyusb, tusb_cdc_acm]

const
  TAG* = "pppos_dualcdc"

# tinyusb console helpers (no wrapper module yet)
proc esp_tusb_init_console*(itf: tinyusb_cdcacm_itf_t): esp_err_t {.cdecl, importc: "esp_tusb_init_console", header: "tusb_console.h".}
proc esp_tusb_deinit_console*(itf: tinyusb_cdcacm_itf_t): esp_err_t {.cdecl, importc: "esp_tusb_deinit_console", header: "tusb_console.h".}


# State
var
  sNetif: ptr esp_netif_t
  sEventGroup: EventGroupHandle_t
  sPppItf: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_0
  sLogItf: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_1
  rxBuf = newSeq[uint8](CONFIG_TINYUSB_CDC_RX_BUFSIZE + 1)

const
  GOT_IPV4 = 1 shl 0
  CONN_FAILED = 1 shl 1
  GOT_IPV6 = 1 shl 2
  CONNECT_BITS = GOT_IPV4 or GOT_IPV6 or CONN_FAILED

# PPP transmit: push bytes to CDC PPP interface
proc pppTransmit(h: pointer; buffer: pointer; len: csize_t): esp_err_t {.cdecl.} =
  discard tinyusb_cdcacm_write_queue(sPppItf, cast[ptr uint8](buffer), len)
  result = tinyusb_cdcacm_write_flush(sPppItf, 0'u32)

var driverCfg: esp_netif_driver_ifconfig_t

# CDC RX: feed data to esp_netif
proc onCdcRx(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  if tinyusb_cdcacm_itf_t(itf) != sPppItf:
    return
  var rxSize: csize_t = 0
  let ret = tinyusb_cdcacm_read(tinyusb_cdcacm_itf_t(itf), addr rxBuf[0], CONFIG_TINYUSB_CDC_RX_BUFSIZE.csize_t, addr rxSize)
  if ret == ESP_OK and rxSize > 0:
    discard esp_netif_receive(sNetif, addr rxBuf[0], rxSize, nil)

proc onLineState(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  logi(TAG, "Line state changed on itf %d", itf)
  # Allow host tools (esptool) to reset via DTR/RTS on the console CDC
  if tinyusb_cdcacm_itf_t(itf) == sLogItf:
    logi(TAG, "DTR/RTS triggered on console: restarting for flashing")
    let ls = event.line_state_changed_data
    # Common esptool pattern: RTS asserted and DTR deasserted -> reset to enter flashing
    if ls.rts and not ls.dtr:
      logi(TAG, "DTR/RTS trigger: restarting for flashing")
      esp_restart()

# IP events handler: filter for our PPP netif and set bits
proc onIpEvent(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  if event_base != IP_EVENT: return
  case ip_event_t(event_id)
  of IP_EVENT_PPP_GOT_IP:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    if ev.esp_netif == sNetif:
      logi(TAG, "PPP IPv4: %s %s", esp_netif_get_desc(ev.esp_netif), $ev.ip_info.ip)
      discard xEventGroupSetBits(sEventGroup, EventBits_t(GOT_IPV4))
  of IP_EVENT_GOT_IP6:
    let ev6 = cast[ptr ip_event_got_ip6_t](event_data)
    if ev6.esp_netif == sNetif:
      logi(TAG, "PPP IPv6 acquired")
      discard xEventGroupSetBits(sEventGroup, EventBits_t(GOT_IPV6))
  of IP_EVENT_PPP_LOST_IP:
    discard xEventGroupSetBits(sEventGroup, EventBits_t(CONN_FAILED))
  else:
    discard

proc examplePppConnectDualCdc*(): esp_err_t =
  logi(TAG, "Starting dual-CDC PPPoS (PPP=CDC0, console=CDC1)")

  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  # CDC0 for PPP
  var acmPpp: tinyusb_config_cdcacm_t
  acmPpp.usb_dev = TINYUSB_USBDEV_0
  acmPpp.cdc_port = TINYUSB_CDC_ACM_0
  acmPpp.callback_rx = onCdcRx
  acmPpp.callback_rx_wanted_char = nil
  acmPpp.callback_line_state_changed = onLineState
  acmPpp.callback_line_coding_changed = nil
  check: tusb_cdc_acm_init(addr acmPpp)

  # CDC1 for logs/console
  var acmLog: tinyusb_config_cdcacm_t
  acmLog.usb_dev = TINYUSB_USBDEV_0
  acmLog.cdc_port = TINYUSB_CDC_ACM_1
  acmLog.callback_line_state_changed = onLineState
  check: tusb_cdc_acm_init(addr acmLog)
  check: esp_tusb_init_console(TINYUSB_CDC_ACM_1)

  # Event group and handler
  sEventGroup = xEventGroupCreate()
  if sEventGroup.isNil: return ESP_ERR_NO_MEM
  check: esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID.cint, onIpEvent, nil)

  # Create PPP netif using inherent defaults and custom driver
  var baseCfg = ESP_NETIF_INHERENT_DEFAULT_PPP()
  baseCfg.if_desc = "example_netif_ppp"

  driverCfg.handle = cast[pointer](1)
  driverCfg.transmit = pppTransmit

  var netifCfg: esp_netif_config_t
  netifCfg.base = addr baseCfg
  netifCfg.driver = addr driverCfg
  netifCfg.stack = ESP_NETIF_NETSTACK_DEFAULT_PPP

  sNetif = esp_netif_new(addr netifCfg)
  doAssert sNetif != nil
  esp_netif_action_start(sNetif, nil, 0, nil)
  esp_netif_action_connected(sNetif, nil, 0, nil)

  logi(TAG, "Waiting for IP...")
  let bits = xEventGroupWaitBits(sEventGroup, EventBits_t(CONNECT_BITS), pdFALSE, pdFALSE, portMAX_DELAY)
  if (bits and EventBits_t(CONN_FAILED)) != 0:
    loge(TAG, "PPP connect failed")
    return ESP_FAIL
  logi(TAG, "PPP connected")
  return ESP_OK

proc examplePppShutdownDualCdc*() =
  discard esp_event_handler_unregister(IP_EVENT, ESP_EVENT_ANY_ID.cint, onIpEvent)
  if sNetif != nil:
    esp_netif_action_disconnected(sNetif, nil, 0, nil)
    esp_netif_action_stop(sNetif, nil, 0, nil)
    esp_netif_destroy(sNetif)
    sNetif = nil
  if sEventGroup != nil:
    vEventGroupDelete(sEventGroup)
    sEventGroup = nil
  discard esp_tusb_deinit_console(TINYUSB_CDC_ACM_1)
