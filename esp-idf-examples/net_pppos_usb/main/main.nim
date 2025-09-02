import std/strutils
import nesper
import nesper/[consts, general, timers]
import nesper/esp/esp_system
import nesper/esp/nvs_flash
import nesper/esp/esp_event
import nesper/esp/net/esp_netif
import nesper/esp/net/esp_netif_ppp
when defined(RUN_NCM):
  import usb/usb_ncm_eth_dualcdc as ncm_eth
else:
  import usb/usb_ppp_connect_dualcdc

const
  TAG*: cstring = "main"

proc setupSystem(): esp_err_t =
  # Initialize esp-netif and default event loop
  check: esp_netif_init()
  check: esp_event_loop_create_default()
  return ESP_OK

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
    discard setupSystem()
    # Start PPPoS over USB with dual CDC (CDC0=PPP, CDC1=console)
    if examplePppConnectDualCdc() == ESP_OK:
      logi(TAG, "PPPoS connected. Idle loop ...")
    else:
      loge(TAG, "PPPoS connect failed")

  # Keep app alive; clean shutdown not triggered in this minimal example
  while true:
    logi(TAG, "PPPoS connected. Idle loop ...")
    delay(1_000.Millis)
