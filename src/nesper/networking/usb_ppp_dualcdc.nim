import nesper
import nesper/[general, gpios, timers]
import nesper/esp/[esp_log, esp_event, event_groups]
import nesper/esp/esp_system
import nesper/events
import nesper/esp/net/[esp_netif, esp_netif_ppp, esp_netif_types, esp_netif_impl]
import nesper/components/esp_tinyusb/[tinyusb, tinyusb_net, tusb_cdc_acm]

export esp_netif
export esp_netif_ppp
export esp_netif_types
export esp_netif_impl

## Code that is specific to the USB PPP over Dual CDC (CDC0=PPP, CDC1=console)
## Requires TinyUSB and incompatible with USB JTAG or OTG Modes
## CDC0 is used for PPP data, CDC1 is used for console
## 
## Example /etc/ppp/ipv6-up script:
## ```sh
## #!/bin/sh
## 
## INTERFACE=$1
## DEVICE=$2
## SPEED=$3
## LOCAL_IP=$4
## REMOTE_IP=$5
## IPPARAM=$6
## 
## echo 0 > /proc/sys/net/ipv6/conf/$1/use_tempaddr
## echo 2 > /proc/sys/net/ipv6/conf/$1/accept_ra
## echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
## 
## ULA_PREFIX="fd12:1234:0E74" # Choose your own prefix!!!
## HOST_ULA="${ULA_PREFIX}::1/64"
## DEVICE_ULA="${ULA_PREFIX}::2/64"
## 
## # Add the ULA address to the PPP interface
## ip -6 addr add $HOST_ULA dev $INTERFACE
## 
## # Add a route to the device's ULA address
## ip -6 route add $DEVICE_ULA dev $INTERFACE
## 
## # Optional: Add the ULA subnet to the routing table
## ip -6 route add ${ULA_PREFIX}::/64 dev $INTERFACE
## 
## # Log the configuration
## logger "IPv6-up: Added ULA addresses - Host: $HOST_ULA, Device: $DEVICE_ULA on $INTERFACE"
## ```
## 
## Example of /etc/ppp/peers/esp32 config:
## 
## ```sh
## # Serial device
## /dev/ttyACM0
## # Baud rate (match your ESP32-S3 configuration)
## 115200
## # Hardware flow control
## crtscts
## # Don't use modem control lines
## local
## # Don't require authentication from peer
## noauth
## # Set this side as client
## noipdefault
## defaultroute
## # Use peer's DNS
## usepeerdns
## # Enable debug (remove after testing)
## debug
## dump
## # Keep connection alive
## persist
## maxfail 0
## 
## # Optional: specific IP addresses if your ESP32-S3 assigns them
## # 192.168.1.100:192.168.1.101
## +ipv6
## ```
## 
## Then you can simply run `sudo pppd call esp32`

const
  TAG* = "pppos_dualcdc"

# State
var
  sNetif: ptr esp_netif_t
  sEventGroup: EventGroupHandle_t
  sLogItf: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_0
  sPppItf: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_1
  rxBuf = newSeq[uint8](CONFIG_TINYUSB_CDC_RX_BUFSIZE + 1)

const
  GOT_IPV4 = 1 shl 0
  CONN_FAILED = 1 shl 1
  GOT_IPV6 = 1 shl 2
  CONNECT_BITS = GOT_IPV4 or GOT_IPV6 or CONN_FAILED

# PPP transmit: push bytes to CDC PPP interface
proc pppTransmit*(h: pointer; buffer: pointer; len: csize_t): esp_err_t {.cdecl.} =
  # logi(TAG, "CDC TX: %d", len)
  discard tinyusb_cdcacm_write_queue(sPppItf, cast[ptr uint8](buffer), len)
  result = tinyusb_cdcacm_write_flush(sPppItf, 0'u32)

var driverCfg: esp_netif_driver_ifconfig_t

# CDC RX: feed data to esp_netif
proc onCdcRx*(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  # logi(TAG, "CDC RX: interface %d", itf)
  if tinyusb_cdcacm_itf_t(itf) != sPppItf:
    # logi(TAG, "CDC RX: interface %d not sPppItf", itf)
    return
  var rxSize: csize_t = 0
  let ret = tinyusb_cdcacm_read(tinyusb_cdcacm_itf_t(itf), addr rxBuf[0], CONFIG_TINYUSB_CDC_RX_BUFSIZE.csize_t, addr rxSize)
  # logi(TAG, "CDC RX: interface %d returned %d rxBuf: %d", itf, ret, rxBuf.len())
  if ret == ESP_OK and rxSize > 0:
    discard esp_netif_receive(sNetif, addr rxBuf[0], rxSize, nil)

proc onLineState*(itf: cint; event: ptr cdcacm_event_t) {.cdecl.} =
  # logi(TAG, "Line state changed on itf %d", itf)
  # Allow host tools (esptool) to reset via DTR/RTS on the console CDC
  if tinyusb_cdcacm_itf_t(itf) == sLogItf:
    let ls = event.line_state_changed_data
    # logi(TAG, "DTR/RTS triggered on console rts: %s, dtr: %s", $ls.rts, $ls.dtr)
    # Common esptool pattern: RTS asserted and DTR deasserted -> reset to enter flashing
    if ls.rts and not ls.dtr:
      # logi(TAG, "DTR/RTS trigger: restarting...")
      delay(10.Millis)
      esp_restart()

# IP events handler: filter for our PPP netif and set bits
proc onIpEvent*(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
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
    logi(TAG, "PPP IPv6 lost")
    discard xEventGroupSetBits(sEventGroup, EventBits_t(CONN_FAILED))
  else:
    discard

proc cdcSetupNetworking*() =
  # Initialize esp-netif and default event loop
  check: esp_netif_init()
  check: esp_event_loop_create_default()

proc cdcSetupConsole*(
    usb_dev: tinyusb_usbdev_t = TINYUSB_USBDEV_0,
    cdc_port: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_0
) =
  # CDC0 for logs/console
  var acmLog: tinyusb_config_cdcacm_t
  acmLog.usb_dev = usb_dev
  acmLog.cdc_port = cdc_port
  acmLog.callback_line_state_changed = onLineState
  check: tusb_cdc_acm_init(addr acmLog)
  check: esp_tusb_init_console(cdc_port)

proc cdcSetupPpp*(
    usb_dev: tinyusb_usbdev_t = TINYUSB_USBDEV_1,
    cdc_port: tinyusb_cdcacm_itf_t = TINYUSB_CDC_ACM_1
) =
  # CDC1 for PPP
  var acmPpp: tinyusb_config_cdcacm_t
  acmPpp.usb_dev = usb_dev
  acmPpp.cdc_port = cdc_port
  acmPpp.callback_rx = onCdcRx
  acmPpp.callback_rx_wanted_char = nil
  acmPpp.callback_line_state_changed = onLineState
  acmPpp.callback_line_coding_changed = nil
  check: tusb_cdc_acm_init(addr acmPpp)

proc initPppConnectDualCdc*(): esp_err_t =
  ## Initializes USB CDC for PPPoS and a serial console
  ## requires TinyUSB and incompatible with USB JTAG or OTG Modes
  ## CDC0 is used for PPP data, CDC1 is used for console
  ## 
  logi(TAG, "Starting dual-CDC PPPoS (PPP=CDC0, console=CDC1)")

  var tusbCfg: tinyusb_config_t
  tusbCfg.external_phy = false
  check: tinyusb_driver_install(addr tusbCfg)

  cdcSetupConsole()
  cdcSetupPpp()

  # Event group and handler
  sEventGroup = xEventGroupCreate()
  if sEventGroup.isNil: return ESP_ERR_NO_MEM
  check: esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID.cint, onIpEvent, nil)

  # Create PPP netif using inherent defaults and custom driver
  logi(TAG, "Creating PPP netif...")
  var baseCfg = ESP_NETIF_INHERENT_DEFAULT_PPP()
  baseCfg.if_desc = "ppp_dualcdc"

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

proc shutdownPppConnectDualCdc*() =
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

proc pppInterface*(): ptr esp_netif_t =
  ## Returns the PPP esp-netif created by initPppConnectDualCdc
  sNetif
