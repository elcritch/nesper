import consts
import macros
import esp/esp_log
import tasks

export esp_log, tasks

var portMAX_DELAY* {.importc: "portMAX_DELAY", header: "<freertos/FreeRTOS.h>".}: TickType_t
var portTICK_PERIOD_MS* {.importc: "portTICK_PERIOD_MS", header: "<freertos/FreeRTOS.h>".}: uint32
var portNOP* {.importc: "portNOP", header: "<freertos/FreeRTOS.h>".}: uint32
var configTICK_RATE_HZ* {.importc: "configTICK_RATE_HZ", header: "<freertos/FreeRTOSConfig.h>".}: uint32

proc NimMain() {.importc.}

converter toBits*(x: bytes): bits =
  bits(8*x.int())

converter toTicks*(ts: Millis): TickType_t =
  return TickType_t(uint32(ts) div portTICK_PERIOD_MS)

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

proc joinBytes32*[T](bs: openArray[byte], count: range[0..4], top=false): T =
  var n = 0'u32
  let N = min(count, bs.len())
  for i in 0 ..< N:
    n = (n shl 8) or bs[i]
  if top:
    n = n shl (32-N*8)
  return cast[T](n)

proc joinBytes64*[T](bs: openArray[byte], count: range[0..8], top=false): T =
  var n = 0'u64
  let N = min(count, bs.len())
  for i in 0 ..< N:
    n = (n shl 8) or bs[i]
  if top:
    n = n shl (64-N*8)
  return cast[T](n)

proc splitBytes*[T](val: T, count: range[0..8], top=false): seq[byte] =
  let szT = sizeof(T)
  let N = min(count, szT)

  var x = val
  result = newSeqOfCap[byte](N)
  for i in 0 ..< N:
    if top == false:
      result.add(byte(x))
      x = x shr 8
    else:
      result.add( byte(x shr (8*szT-8) ))
      x = x shl 8


