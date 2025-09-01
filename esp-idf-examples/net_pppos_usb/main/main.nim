import std/strutils
import nesper
import nesper/[consts, general, timers]
import nesper/esp/esp_system
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_ppp

const
  TAG*: cstring = "main"

proc setupPPP(): bool =
  # Network interface configuration
  var cfg: esp_netif_config_t = ESP_NETIF_DEFAULT_PPP()
  let esp_netif: ptr esp_netif_t = esp_netif_new(addr cfg)

  # PPP-specific configuration
  var ppp_config: esp_netif_ppp_config_t
  ppp_config.ppp_phase_event_enabled = true
  ppp_config.ppp_error_event_enabled = true
  check: esp_netif_ppp_set_params(esp_netif, addr ppp_config)
  return true

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

  while true:
    logi(TAG, "Hello, World!")
    delay(1_000.Millis)