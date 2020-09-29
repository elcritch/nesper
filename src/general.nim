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
proc ESP_ERROR_CHECK*(x: cint) {.cdecl, importc: "ESP_ERROR_CHECK", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK_WITHOUT_ABORT*(x: cint) {.cdecl,
    importc: "ESP_ERROR_CHECK_WITHOUT_ABORT", header: "freertos/FreeRTOS.h".}

#define ESP_LOGI( tag, format, ... )  
#define LOG_FORMAT(letter, format)  LOG_COLOR_ ## letter #letter " (%d) %s: " format LOG_RESET_COLOR "\n"
proc esp_log_write(level: esp_log_level_t, tag: cstring, format: cstring, ...) {.importc: "esp_log_write", varargs, header: "esp_log.h".}

proc esp_loge*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGE", varargs, header: "esp_log.h".}
proc esp_logw*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGW", varargs, header: "esp_log.h".}
proc esp_logi*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGI", varargs, header: "esp_log.h".}
proc esp_logd*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGD", varargs, header: "esp_log.h".}
proc esp_logv*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGV", varargs, header: "esp_log.h".}

proc esp_log_timestamp*(void): uint32 {.cdecl, importc: "esp_log_timestamp", header: "esp_log.h".}



