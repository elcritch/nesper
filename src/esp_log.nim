

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

proc esp_log_write*(level: esp_log_level_t; tag: cstring; format: cstring) {.varargs.} =
  discard

##  #define LOG_FORMAT(letter, format)  LOG_COLOR_ ## letter #letter " (%d) %s: " format LOG_RESET_COLOR "\n"
##  #define ESP_LOGE( tag, format, ... )  if (LOG_LOCAL_LEVEL >= ESP_LOG_ERROR)   { esp_log_write(ESP_LOG_ERROR,   tag, LOG_FORMAT(E, format), esp_log_timestamp(), tag, ##__VA_ARGS__); }
##  #define ESP_LOGW( tag, format, ... )  if (LOG_LOCAL_LEVEL >= ESP_LOG_WARN)    { esp_log_write(ESP_LOG_WARN,    tag, LOG_FORMAT(W, format), esp_log_timestamp(), tag, ##__VA_ARGS__); }
##  #define ESP_LOGI( tag, format, ... )  if (LOG_LOCAL_LEVEL >= ESP_LOG_INFO)    { esp_log_write(ESP_LOG_INFO,    tag, LOG_FORMAT(E, format), esp_log_timestamp(), tag, ##__VA_ARGS__); }
##  #define ESP_LOGD( tag, format, ... )  if (LOG_LOCAL_LEVEL >= ESP_LOG_DEBUG)   { esp_log_write(ESP_LOG_DEBUG,   tag, LOG_FORMAT(D, format), esp_log_timestamp(), tag, ##__VA_ARGS__); }
##  #define ESP_LOGV( tag, format, ... )  if (LOG_LOCAL_LEVEL >= ESP_LOG_VERBOSE) { esp_log_write(ESP_LOG_VERBOSE, tag, LOG_FORMAT(V, format), esp_log_timestamp(), tag, ##__VA_ARGS__); }
##  Assume that flash encryption is not enabled. Put here since in partition.c
##  esp_log.h is included later than esp_flash_encrypt.h.

template esp_flash_encryption_enabled*(): untyped =
  false
