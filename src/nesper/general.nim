import consts

var portTICK_PERIOD_MS* {.importc: "portTICK_PERIOD_MS", header: "<freertos/FreeRTOS.h>".}: cint

proc delay*( milsecs: cint ) {.cdecl, importc: "delay".}
proc esp_restart*() {.cdecl, importc: "esp_restart".}

proc vTaskDelete*( handle: any )
  {.cdecl, importc: "vTaskDelete", header: "<freertos/FreeRTOS.h>".}

proc esp_err_to_name*(code: esp_err_t): cstring {.cdecl, importc: "esp_err_to_name",
    header: "freertos/FreeRTOS.h".}
proc esp_err_to_name_r*(code: esp_err_t; buf: cstring; buflen: csize): cstring {.cdecl,
    importc: "esp_err_to_name_r", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK*(x: esp_err_t) {.cdecl, importc: "ESP_ERROR_CHECK", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK_WITHOUT_ABORT*(x: esp_err_t) {.cdecl,
    importc: "ESP_ERROR_CHECK_WITHOUT_ABORT", header: "freertos/FreeRTOS.h".}

#define ESP_LOGI( tag, format, ... )  
#define LOG_FORMAT(letter, format)  LOG_COLOR_ ## letter #letter " (%d) %s: " format LOG_RESET_COLOR "\n"

