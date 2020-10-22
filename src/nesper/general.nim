import consts
import macros
import esp/esp_log
import tasks

export esp_log

var portMAX_DELAY* {.importc: "portMAX_DELAY", header: "<freertos/FreeRTOS.h>".}: TickType_t
var portTICK_PERIOD_MS* {.importc: "portTICK_PERIOD_MS", header: "<freertos/FreeRTOS.h>".}: uint32

proc NimMain() {.importc.}

converter toBits*(x: bytes): bits =
  bits(8*x.int())


template app_main*(blk: untyped): untyped =

  proc app_main*() {.exportc.} =
    NimMain() # initialize garbage collector memory, types and stack
    blk

type
  EspError* = object of OSError
    code*: esp_err_t

proc esp_restart*() {.cdecl, importc: "esp_restart".}

proc vTaskDelete*( handle: any )
  {.cdecl, importc: "vTaskDelete", header: "<freertos/FreeRTOS.h>".}

proc esp_err_to_name*(code: esp_err_t): cstring {.cdecl, importc: "esp_err_to_name",
    header: "freertos/FreeRTOS.h".}
proc esp_err_to_name_r*(code: esp_err_t; buf: cstring; buflen: csize_t): cstring {.cdecl,
    importc: "esp_err_to_name_r", header: "freertos/FreeRTOS.h".}

proc doCheck*(ret: esp_err_t) =
  if ret != ESP_OK:
    raise newException(OSError, "error: " & $esp_err_to_name(ret))

template check*(blk: untyped) =
  doCheck(blk)

proc ESP_ERROR_CHECK*(x: esp_err_t) {.cdecl, importc: "ESP_ERROR_CHECK", header: "freertos/FreeRTOS.h".}
proc ESP_ERROR_CHECK_WITHOUT_ABORT*(x: esp_err_t) {.cdecl,
  importc: "ESP_ERROR_CHECK_WITHOUT_ABORT", header: "freertos/FreeRTOS.h".}

#define ESP_LOGI( tag, format, ... )  
#define LOG_FORMAT(letter, format)  LOG_COLOR_ ## letter #letter " (%d) %s: " format LOG_RESET_COLOR "\n"

proc newEspError*[E](msg: string, error: esp_err_t): ref E =
  new(result)
  result.msg = msg
  result.code = error

proc setFromString*(val: var openArray[uint8], str: cstring) =
  let lstr = len(str)
  if lstr > len(val):
    raise newException(ValueError, "string to large for array")

  copyMem(addr(val), str, lstr)

proc ms_to_ticks*(ms: int): TickType_t =
  TickType_t(uint32(ms) div portTICK_PERIOD_MS )

proc delayMillis*( milsecs: int ) =
  vTaskDelay(milsecs.ms_to_ticks())

proc joinBytes32*[T](bs: openArray[byte], count: range[1..4], top=false): T =
  var n = 0'u32
  let N = min(count, bs.len())
  for i in 0 ..< N:
    n = (n shl 8) or bs[i]
  if top:
    n = n shl (32-N*8)
  return cast[T](n)

proc joinBytes64*[T](bs: openArray[byte], count: range[1..8], top=false): T =
  var n = 0'u64
  let N = min(count, bs.len())
  for i in 0 ..< N:
    n = (n shl 8) or bs[i]
  if top:
    n = n shl (64-N*8)
  return cast[T](n)


type 
  MallocCapacity = enum
    MALLOC_CAP_EXEC           =  BIT(0)  # ///< Memory must be able to run executable code
    MALLOC_CAP_32BIT          =  BIT(1)  # ///< Memory must allow for aligned 32-bit data accesses
    MALLOC_CAP_8BIT           =  BIT(2)  # ///< Memory must allow for 8/16/...-bit data accesses
    MALLOC_CAP_DMA            =  BIT(3)  # ///< Memory must be able to accessed by DMA
    MALLOC_CAP_PID2           =  BIT(4)  # ///< Memory must be mapped to PID2 memory space (PIDs are not currently used)
    MALLOC_CAP_PID3           =  BIT(5)  # ///< Memory must be mapped to PID3 memory space (PIDs are not currently used)
    MALLOC_CAP_PID4           =  BIT(6)  # ///< Memory must be mapped to PID4 memory space (PIDs are not currently used)
    MALLOC_CAP_PID5           =  BIT(7)  # ///< Memory must be mapped to PID5 memory space (PIDs are not currently used)
    MALLOC_CAP_PID6           =  BIT(8)  # ///< Memory must be mapped to PID6 memory space (PIDs are not currently used)
    MALLOC_CAP_PID7           =  BIT(9)  # ///< Memory must be mapped to PID7 memory space (PIDs are not currently used)
    MALLOC_CAP_SPIRAM         =  BIT(10) # ///< Memory must be in SPI RAM
    MALLOC_CAP_INTERNAL       =  BIT(11) # ///< Memory must be internal; specifically it should not disappear when flash/spiram cache is switched off
    MALLOC_CAP_DEFAULT        =  BIT(12) # ///< Memory can be returned in a non-capability-specific memory allocation (e.g. malloc(), calloc()) call
    MALLOC_CAP_INVALID        =  BIT(31) # ///< Memory can't be used / list end marker

proc  heap_caps_print_heap_info*(cap: MallocCapacity) {.importc: "$1", header: "heap/include/esp_heap_caps.h".}
