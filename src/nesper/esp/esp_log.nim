

const
  MALLOC_CAP_INTERNAL* = 0
  MALLOC_CAP_8BIT* = 0

var LOG_LOCAL_LEVEL* {.importc: "CONFIG_LOG_DEFAULT_LEVEL", header: "esp_log.nim".}: cint

type
  esp_log_level_t* {.size: sizeof(cint).} = enum
    ESP_LOG_NONE,             ## !< No log output
    ESP_LOG_ERROR,            ## !< Critical errors, software module can not recover on its own
    ESP_LOG_WARN,             ## !< Error conditions from which recovery measures have been taken
    ESP_LOG_INFO,             ## !< Information messages which describe normal flow of events
    ESP_LOG_DEBUG,            ## !< Extra information which is not necessary for normal use (values, pointers, sizes, etc).
    ESP_LOG_VERBOSE           ## !< Bigger chunks of debugging information, or frequent messages which can potentially flood the output.


proc esp_log_timestamp*(): uint32 {.importc: "esp_log_timestamp", header: "esp_log.h".}

proc esp_log_write*(level: esp_log_level_t, tag: cstring, format: cstring) {.
  importc: "esp_log_write", varargs, header: "esp_log.h".}

proc loge*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGE", varargs, header: "esp_log.h".}
proc logw*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGW", varargs, header: "esp_log.h".}
proc logi*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGI", varargs, header: "esp_log.h".}
proc logd*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGD", varargs, header: "esp_log.h".}
proc logv*(tag: cstring, formatstr: cstring) {.importc: "ESP_LOGV", varargs, header: "esp_log.h".}

proc log_timestamp*(): uint32 {.cdecl, importc: "esp_log_timestamp", header: "esp_log.h".}
