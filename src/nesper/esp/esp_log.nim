import ../consts

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

type 
  MallocCapacity* = enum
    MALLOC_CAP_EXEC     = BIT(0)  # ///< Memory must be able to run executable code
    MALLOC_CAP_32BIT    = BIT(1)  # ///< Memory must allow for aligned 32-bit data accesses
    MALLOC_CAP_8BIT     = BIT(2)  # ///< Memory must allow for 8/16/...-bit data accesses
    MALLOC_CAP_DMA      = BIT(3)  # ///< Memory must be able to accessed by DMA
    MALLOC_CAP_PID2     = BIT(4)  # ///< Memory must be mapped to PID2 memory space (PIDs are not currently used)
    MALLOC_CAP_PID3     = BIT(5)  # ///< Memory must be mapped to PID3 memory space (PIDs are not currently used)
    MALLOC_CAP_PID4     = BIT(6)  # ///< Memory must be mapped to PID4 memory space (PIDs are not currently used)
    MALLOC_CAP_PID5     = BIT(7)  # ///< Memory must be mapped to PID5 memory space (PIDs are not currently used)
    MALLOC_CAP_PID6     = BIT(8)  # ///< Memory must be mapped to PID6 memory space (PIDs are not currently used)
    MALLOC_CAP_PID7     = BIT(9)  # ///< Memory must be mapped to PID7 memory space (PIDs are not currently used)
    MALLOC_CAP_SPIRAM   = BIT(10) # ///< Memory must be in SPI RAM
    MALLOC_CAP_INTERNAL = BIT(11) # ///< Memory must be internal; specifically it should not disappear when flash/spiram cache is switched off
    MALLOC_CAP_DEFAULT  = BIT(12) # ///< Memory can be returned in a non-capability-specific memory allocation (e.g. malloc(), calloc()) call
    MALLOC_CAP_INVALID  = BIT(31) # ///< Memory can't be used / list end marker

proc heap_caps_print_heap_info*(cap: MallocCapacity) {.importc: "$1", header: "esp_heap_caps.h".}
proc heap_caps_get_free_size*(cap: MallocCapacity): csize_t {.importc: "$1", header: "esp_heap_caps.h".}
proc multi_heap_free_size*(cap: MallocCapacity): csize_t {.importc: "$1", header: "esp_heap_caps.h".}
