import consts

var portMAX_DELAY* {.importc: "portMAX_DELAY", header: "<freertos/FreeRTOS.h>".}: TickType_t
var portTICK_PERIOD_MS* {.importc: "portTICK_PERIOD_MS", header: "<freertos/FreeRTOS.h>".}: uint32

proc delay*( milsecs: cint ) {.cdecl, importc: "delay".}
proc esp_restart*() {.cdecl, importc: "esp_restart".}

proc vTaskDelete*( handle: any )
  {.cdecl, importc: "vTaskDelete", header: "<freertos/FreeRTOS.h>".}

proc esp_err_to_name*(code: esp_err_t): cstring {.cdecl, importc: "esp_err_to_name",
    header: "freertos/FreeRTOS.h".}
proc esp_err_to_name_r*(code: esp_err_t; buf: cstring; buflen: csize_t): cstring {.cdecl,
    importc: "esp_err_to_name_r", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK*(x: esp_err_t) {.cdecl, importc: "ESP_ERROR_CHECK", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK_WITHOUT_ABORT*(x: esp_err_t) {.cdecl,
  importc: "ESP_ERROR_CHECK_WITHOUT_ABORT", header: "freertos/FreeRTOS.h".}

#define ESP_LOGI( tag, format, ... )  
#define LOG_FORMAT(letter, format)  LOG_COLOR_ ## letter #letter " (%d) %s: " format LOG_RESET_COLOR "\n"

proc toIpAddress(ip: ip4_addr): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv4)
  let address = ip4_addr.address
  for i in 0..3:
    result.address_v4[i] = uint8(address shl i*8)

proc toIpAddress(ip: ip4_addr): IpAddress =
  result = IpAddress(family: IpAddressFamily.IPv6)
  let address = ip4_addr.address
  for i in 0..15:
    result.address_v4[i] = uint8(address shl i*8)
