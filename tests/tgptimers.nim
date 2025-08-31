import nesper
import nesper/gptimers

# Callbacks mirror the C example signatures
proc cbStop(timer: gptimer_handle_t; edata: ptr gptimer_alarm_event_data_t; user: pointer): bool {.cdecl.} =
  discard gptimer_stop(timer) # stop immediately
  return false

proc cbCollect(timer: gptimer_handle_t; edata: ptr gptimer_alarm_event_data_t; user: pointer): bool {.cdecl.} =
  discard timer # suppress unused warnings
  discard user
  discard edata
  return false

proc cbUpdate(timer: gptimer_handle_t; edata: ptr gptimer_alarm_event_data_t; user: pointer): bool {.cdecl.} =
  discard user
  var alarmCfg: gptimer_alarm_config_t
  alarmCfg.alarm_count = edata.alarm_value + 1_000_000'u64
  discard gptimer_set_alarm_action(timer, addr alarmCfg)
  return false

# Basic configuration and sequence based on the C example
let t = newGpTimer(
  clkSrc = gptimer_clock_source_t(0.cint),
  direction = GPTIMER_COUNT_UP,
  resolutionHz = 1_000_000'u32
)

discard t.onAlarm(cbStop)
discard t.enable()

discard t.setAlarm(alarmCount = 1_000_000'u64)
discard t.start()

discard t.setRawCount(100'u64)
var count: uint64
discard t.getRawCount(count)

discard t.disable()
discard t.onAlarm(cbCollect)
discard t.enable()
discard t.setAlarm(alarmCount = 1_000_000'u64, reloadCount = 0'u64, autoReload = true)
discard t.start()
discard t.stop()

discard t.disable()
discard t.onAlarm(cbUpdate)
discard t.enable()
discard t.setAlarm(alarmCount = 1_000_000'u64)
discard t.start()
discard t.stop()
discard t.disable()

