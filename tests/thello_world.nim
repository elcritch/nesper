import std/strutils
import nesper
import nesper/[consts, general, timers]
import nesper/esp/esp_system

const
  TAG*: cstring = "main"

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