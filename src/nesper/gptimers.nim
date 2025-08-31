import ./consts
import ./general

# Low-level driver bindings
import ./esp/driver/gptimer
import ./esp/driver/timer_types

export timer_types
export gptimer
export consts.bits, consts.bytes

const TAG = "gptimers_v5"

type
  GpTimerError* = object of OSError
    code*: esp_err_t

  GpTimer* = ref object
    handle*: gptimer_handle_t
    cfg*: gptimer_config_t
    cbs: gptimer_event_callbacks_t
    userData: pointer

converter toHandle*(t: GpTimer): gptimer_handle_t = t.handle

proc `=destroy`(t: var typeof(GpTimer()[])) =
  if t.handle != nil:
    discard gptimer_stop(t.handle)
    discard gptimer_disable(t.handle)
    discard gptimer_del_timer(t.handle)
    t.handle = nil

proc newGpTimer*(
    clkSrc: gptimer_clock_source_t = gptimer_clock_source_t(0.cint),
    direction: gptimer_count_direction_t = GPTIMER_COUNT_UP,
    resolutionHz: uint32 = 1_000_000'u32,
    intrPriority: cint = 0,
    intrShared: bool = false,
    allowPd: bool = false
  ): GpTimer =
  ## Create and configure a general purpose timer.
  result = GpTimer()
  result.cfg.clk_src = clkSrc
  result.cfg.direction = direction
  result.cfg.resolution_hz = resolutionHz
  result.cfg.intr_priority = intrPriority
  result.cfg.flags.intr_shared = (if intrShared: 1'u32 else: 0'u32)
  result.cfg.flags.allow_pd = (if allowPd: 1'u32 else: 0'u32)

  var h: gptimer_handle_t
  let ret = gptimer_new_timer(addr result.cfg, addr h)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_new_timer failed (" & $esp_err_to_name(ret) & ")", ret)
  result.handle = h

# Basic control
proc enable*(t: GpTimer): esp_err_t {.discardable.} =
  let ret = gptimer_enable(t.handle)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_enable failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc disable*(t: GpTimer): esp_err_t {.discardable.} =
  let ret = gptimer_disable(t.handle)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_disable failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc start*(t: GpTimer): esp_err_t {.discardable.} =
  let ret = gptimer_start(t.handle)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_start failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc stop*(t: GpTimer): esp_err_t {.discardable.} =
  let ret = gptimer_stop(t.handle)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_stop failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

# Count helpers
proc setRawCount*(t: GpTimer; value: uint64): esp_err_t {.discardable.} =
  let ret = gptimer_set_raw_count(t.handle, value)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_set_raw_count failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc getRawCount*(t: GpTimer; outValue: var uint64): esp_err_t {.discardable.} =
  let ret = gptimer_get_raw_count(t.handle, addr outValue)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_get_raw_count failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc getCapturedCount*(t: GpTimer; outValue: var uint64): esp_err_t {.discardable.} =
  let ret = gptimer_get_captured_count(t.handle, addr outValue)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_get_captured_count failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc getResolutionHz*(t: GpTimer): uint32 =
  var hz: uint32
  let ret = gptimer_get_resolution(t.handle, addr hz)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_get_resolution failed (" & $esp_err_to_name(ret) & ")", ret)
  hz

# Alarm helpers
proc setAlarm*(t: GpTimer; alarmCount: uint64; reloadCount: uint64 = 0'u64; autoReload: bool = false): esp_err_t {.discardable.} =
  var cfg: gptimer_alarm_config_t
  cfg.alarm_count = alarmCount
  cfg.reload_count = reloadCount
  cfg.flags.auto_reload_on_alarm = (if autoReload: 1'u32 else: 0'u32)
  let ret = gptimer_set_alarm_action(t.handle, addr cfg)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_set_alarm_action failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc onAlarm*(t: GpTimer; cb: gptimer_alarm_cb_t; userData: pointer = nil): esp_err_t {.discardable.} =
  t.cbs.on_alarm = cb
  t.userData = userData
  let ret = gptimer_register_event_callbacks(t.handle, addr t.cbs, t.userData)
  if ret != ESP_OK:
    raise newEspError[GpTimerError]("gptimer_register_event_callbacks failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

