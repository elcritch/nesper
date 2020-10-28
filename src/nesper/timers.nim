
import consts
import general

import esp/esp_timer
export esp_timer

type
  TimerError* = object of OSError
    code*: esp_err_t

proc createTimer*(
        callback: esp_timer_cb_t, ## !< Function to call when timer expires
        arg: pointer, ## !< Argument to pass to the callback
        dispatch_method: esp_timer_dispatch_t, ## !< Call the callback from task or from ISR
        name: cstring
      ): esp_timer_handle_t =
  ## !< Timer name, used in esp_timer_dump function

  var create_args: esp_timer_create_args_t
  var out_handle: esp_timer_handle_t

  let ret = esp_timer_create(addr(create_args), addr(out_handle))

  if ESP_OK != ret:
    raise newEspError[TimerError]("timer: " & $esp_err_to_name(ret), ret)

  return out_handle


proc microsRaw*(): uint64 {.inline.} =
  return cast[uint64](esp_timer_get_time())

proc micros*(): Micros =
  return Micros(microsRaw())

proc millis*(): Millis =
  return Millis(micros().uint64 div 1000U)

converter toTicks*(ms: Millis): TickType_t =
  TickType_t(uint32(ms) div portTICK_PERIOD_MS)

proc delayMillis*(ms: int) =
  vTaskDelay(Millis(ms).toTicks())

# void IRAM_ATTR delayMicroseconds(uint32_t us)
proc delayMicros*(us: Micros): Micros =
  if us.uint64 == 0:
    return

  var curr: uint64 = microsRaw()
  var target = curr + us.uint64
  if target < curr: # overflow?
    while curr > target:
      curr = microsRaw()

  while(curr < target):
    curr = microsRaw()

  return curr.Micros()

proc delay*(ts: Millis) = delayMillis(ts)
proc delay*(ts: Micros) = discard delayMicros(ts)

template timeBlock*(n: string, blk: untyped): untyped =
  let t0 = micros()
  blk
  echo n & " took: ", $(micros() - t0), " micros "

template timeBlockDebug*(n: string, blk: untyped): untyped =
  when defined(debugRpcTimes):
    let t0 = micros()
    blk
    echo n & " took: ", $(micros() - t0), " micros "
  else:
    blk
