import std/strutils
import nesper
import nesper/[consts, general, timers]
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/esp/esp_event
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_ppp
import nesper/esp/net/esp_netif_impl
import nesper/net_utils


when defined(RUN_NCM):
  import usb/usb_ncm_eth_dualcdc as ncm_eth
else:
  import nesper/networking/usb_ppp_dualcdc

const
  TAG*: cstring = "main"

proc addIpv6ToNetif*(netif: ptr esp_netif_t; ip: IpAddress): esp_err_t =
  ## Convert Nim IpAddress to esp_ip6_addr_t and add it to the interface
  let espIp6 = toEspIp6Addr(ip)
  result = esp_netif_add_ip6_address(netif, espIp6, preferred=true)

when defined(RPC_JSON):
  import nesper/servers/rpc/rpcsocket_json
  proc setupRpc(rt: var RpcRouter) =
    rt.rpc("hello") do(input: string) -> string:
      # example: ./rpc_cli --ip:$IP -c:1 '{"method": "hello", "params": ["world"]}'
      result = "Hello " & input

    rt.rpc("add") do(a: int, b: int) -> int:
      # example: ./rpc_cli --ip:$IP -c:1 '{"method": "add", "params": [1, 2]}'
      result = a + b

import mummy, mummy/routers

proc indexHandler(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/plain"
  request.respond(200, headers, "Hello, World!")

proc runMummy() =
  var router: Router
  router.get("/", indexHandler)

  let server = newServer(router,
                          websocketHandler=nil,
                          logHandler=nil,
                          workerThreads=1,
                          maxHeadersLen=8*1024,
                          maxBodyLen=128*1024,
                          maxMessageLen=16*1024
                          )
  echo "Serving on http://localhost:8080"
  server.serve(Port(8080), address="::")

app_main:
  logi(TAG, "esp starting ... ")

  # Print chip information
  var chipInfo: esp_chip_info_t
  esp_chip_info(addr chipInfo)
  var features = ""
  try:
    features &= "This is a " & $chipInfo.model 
    features &= " chip with " & $chipInfo.cores & " CPU core(s)"
    if (chipInfo.features and CHIP_FEATURE_WIFI_BGN) != 0:
      features &= "WiFi/"
    if (chipInfo.features and CHIP_FEATURE_BT) != 0:
      features &= "BT"
    if (chipInfo.features and CHIP_FEATURE_BLE) != 0:
      features &= "BLE"
    if (chipInfo.features and CHIP_FEATURE_IEEE802154) != 0:
      features &= "802.15.4 (Zigbee/Thread)"
    logi(TAG, "chip features: %s", features.cstring)
  except Defect, CatchableError:
    logi(TAG, "Error getting chip info")

  when defined(RUN_NCM):
    # Start USB NCM-as-Ethernet with separate CDC console
    ncm_eth.runUsbNcmEthWithConsole()
  else:
    # Basic system setup: NVS, esp-netif, default event loop
    setupNetworking()
    # Start PPPoS over USB with dual CDC (CDC0=PPP, CDC1=console)
    if initPppConnectDualCdc() == ESP_OK:
      logi(TAG, "PPPoS connected. Idle loop ...")

      # Demo: add a static IPv6 address to the PPP netif
      let netif = pppInterface()
      let demoIp = parseIpAddress("fd12:4FE6:B3B5:0E74::2")
      let rc = addIpv6ToNetif(netif, demoIp)
      if rc == ESP_OK:
        logi(TAG, "Added IPv6 %s to PPP interface", $demoIp)
      else:
        logw(TAG, "Failed to add IPv6 (%d)", rc)
    else:
      loge(TAG, "PPPoS connect failed")

  # var rt: RpcRouter = createRpcRouter(4096)
  # rt.setupRpc()

  # startRpcSocketServer(port=Port(5555), address="::", router=rt)

  # Keep app alive; clean shutdown not triggered in this minimal example
  while true:
    logi(TAG, "PPPoS connected. Idle loop ...")
    delay(1_000.Millis)
