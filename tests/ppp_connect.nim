import nesper/general
import nesper/esp/event_groups
import nesper/esp/esp_event
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_ppp
import nesper/esp/net/esp_netif_defaults
import nesper/esp/net/esp_netif_impl
import nesper/esp/net/esp_netif_types
import nesper/esp/driver/uart
import nesper/uarts

when defined(ESP_IDF_V4_0):
  import nesper/esp/net/tcpip_adapter
else:
  var IP_EVENT* {.importc: "IP_EVENT", header: "esp_netif_types.h".}: esp_event_base_t

export esp_event
export esp_netif
export esp_netif_ppp

const
  TAG: cstring = "example_connect_ppp"
  EXAMPLE_NETIF_DESC_PPP* = "example_netif_ppp"

  GOT_IPV4 = EventBits_t(BIT(0))
  CONNECTION_FAILED = EventBits_t(BIT(1))
when defined(CONFIG_EXAMPLE_CONNECT_IPV6):
  const GOT_IPV6 = EventBits_t(BIT(2))

when defined(CONFIG_EXAMPLE_CONNECT_IPV6):
  const CONNECT_BITS = GOT_IPV4 or GOT_IPV6 or CONNECTION_FAILED
else:
  const CONNECT_BITS = GOT_IPV4 or CONNECTION_FAILED

const
  DefaultBufSize = 1024.SzBytes

## Allow overriding at compile time: -d:PPP_CONN_MAX_RETRY=3
const PPP_CONN_MAX_RETRY* {.intdefine.} = 5

var
  sRetryNum: int = 0
  sEventGroup: EventGroupHandle_t
  sNetif: ptr esp_netif_t
  sStopTask: bool = false
  gUartPort: uart_port_t = UART_NUM_1
  gUart: Uart

proc pppTransmit(h: pointer; buffer: pointer; len: csize_t): esp_err_t {.cdecl.} =
  # For UART device: write bytes out on the configured UART port
  discard uart_write_bytes(gUartPort, cast[cstring](buffer), len)
  return ESP_OK

var driverCfg = esp_netif_driver_ifconfig_t(
  handle: cast[pointer](1),     # singleton driver, just != NULL
  transmit: pppTransmit
)

proc onIpEvent(arg: pointer; event_base: esp_event_base_t; event_id: int32; event_data: pointer) {.cdecl.} =
  if event_id == ip_event_t.IP_EVENT_PPP_GOT_IP.ord:
    let ev = cast[ptr ip_event_got_ip_t](event_data)
    if ev.esp_netif != sNetif:
      return
    TAG.logi("PPP got IPv4")
    var dnsInfo: esp_netif_dns_info_t
    discard esp_netif_get_dns_info(sNetif, esp_netif_dns_type_t.ESP_NETIF_DNS_MAIN, addr dnsInfo)
    discard xEventGroupSetBits(sEventGroup, GOT_IPV4)
  elif event_id == ip_event_t.IP_EVENT_GOT_IP6.ord:
    let ev6 = cast[ptr ip_event_got_ip6_t](event_data)
    if ev6.esp_netif != sNetif:
      return
    TAG.logi("PPP got IPv6")
    when defined(CONFIG_EXAMPLE_CONNECT_IPV6):
      discard xEventGroupSetBits(sEventGroup, GOT_IPV6)
  elif event_id == ip_event_t.IP_EVENT_PPP_LOST_IP.ord:
    TAG.logi("PPP disconnected from server")
    inc sRetryNum
    if sRetryNum > PPP_CONN_MAX_RETRY:
      TAG.loge("PPP Connection failed %d times, stop reconnecting.", sRetryNum.cint)
      discard xEventGroupSetBits(sEventGroup, CONNECTION_FAILED)
    else:
      TAG.logi("PPP Connection failed %d times, reconnecting...", sRetryNum.cint)
      esp_netif_action_start(sNetif, nil, 0, nil)
      esp_netif_action_connected(sNetif, nil, 0, nil)

proc pppUartTask(arg: pointer) {.cdecl.} =
  while not sStopTask:
    let data = gUart.read(size = DefaultBufSize, wait = 1.Millis)
    if data.len > 0:
      discard esp_netif_receive(sNetif, unsafeAddr data[0], data.len.csize_t, nil)
  vTaskDelete(nil)

proc examplePppConnect*(
    uartNum: uart_port_t = UART_NUM_1,
    txPin: gpio_num_t,
    rxPin: gpio_num_t,
    baudrate: int = 115_200,
    stackSize: uint32 = 4096,
    taskPrio: UBaseType_t = 5
  ): esp_err_t =

  TAG.logi("Start example_connect (PPP over UART)")

  sEventGroup = xEventGroupCreate()
  if sEventGroup.isNil:
    TAG.loge("Failed to create event group")
    return ESP_FAIL

  check: esp_event_handler_register(IP_EVENT, ESP_EVENT_ANY_ID, onIpEvent, nil)

  var baseCfg = ESP_NETIF_INHERENT_DEFAULT_PPP()
  baseCfg.if_desc = EXAMPLE_NETIF_DESC_PPP
  var netifCfg = esp_netif_config_t(
    base: addr baseCfg,
    driver: addr driverCfg,
    stack: ESP_NETIF_NETSTACK_DEFAULT_PPP
  )

  sNetif = esp_netif_new(addr netifCfg)
  if sNetif.isNil:
    TAG.loge("Failed to create PPP netif")
    return ESP_FAIL

  # Initialize UART for PPPoS framing
  gUartPort = uartNum
  var ucfg = newUartConfig(baud_rate = baudrate)
  gUart = newUart(ucfg, uartNum, txPin, rxPin, buffer = DefaultBufSize, event_size = 0)

  sStopTask = false
  if xTaskCreate(pppUartTask, "ppp connect", stackSize, nil, taskPrio, nil) != pdTRUE:
    TAG.loge("Failed to create PPP task")
    return ESP_FAIL

  # Bring the netif up (start + connected)
  esp_netif_action_start(sNetif, nil, 0, nil)
  esp_netif_action_connected(sNetif, nil, 0, nil)

  TAG.logi("Waiting for IP address")
  let bits = xEventGroupWaitBits(sEventGroup, CONNECT_BITS, pdFALSE, pdFALSE, portMAX_DELAY)
  if (bits and CONNECTION_FAILED) != 0:
    TAG.loge("PPP connection failed")
    return ESP_FAIL

  TAG.logi("PPP connected!")
  return ESP_OK

proc examplePppShutdown*() =
  discard esp_event_handler_unregister(IP_EVENT, ESP_EVENT_ANY_ID, onIpEvent)

  sStopTask = true
  vTaskDelay(pdMS_TO_TICKS(1000)) # wait for the PPP task to stop

  esp_netif_action_disconnected(sNetif, nil, 0, nil)

  vEventGroupDelete(sEventGroup)
  esp_netif_action_stop(sNetif, nil, 0, nil)
  esp_netif_destroy(sNetif)
  sNetif = nil
  sEventGroup = nil

