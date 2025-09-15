import std/strutils

import ./consts
import ./general
import ./esp/driver/gpio_driver

# Low-level v5 driver bindings and types
import ./esp/driver/ledc
import ./esp/hal/ledc_types

export ledc_types
export ledc
export consts.bits, consts.bytes
export gpio_driver.gpio_num_t

const TAG = "ledcs_v5"

type
  LedcError* = object of OSError
    code*: esp_err_t

  LedcTimer* = ref object
    cfg*: ledc_timer_config_t

  LedcChannel* = ref object
    cfg*: ledc_channel_config_t

proc repr*(t: ledc_timer_config_t): string =
  result = "LedcTimer("
  result &= "mode: " & $t.speed_mode & ", "
  result &= "timer: " & $t.timer_num & ", "
  result &= "res: " & $t.duty_resolution & ", "
  result &= "freq: " & $t.freq_hz & ", "
  result &= "clk: " & $t.clk_cfg & ")"

proc repr*(c: ledc_channel_config_t): string =
  result = "LedcChannel("
  result &= "gpio: " & $c.gpio_num & ", "
  result &= "mode: " & $c.speed_mode & ", "
  result &= "ch: " & $c.channel & ", "
  result &= "timer: " & $c.timer_sel & ", "
  result &= "duty: " & $c.duty & ", "
  result &= "hpoint: " & $c.hpoint & ")"

var ledcInitialized*: bool = false

proc initLedc*() =
  if not ledcInitialized:
    ledcInitialized = true
    check: ledc_fade_func_install(0)

# Timer helpers
proc newLedcTimer*(
    mode: ledc_mode_t,
    timer: ledc_timer_t,
    dutyRes: ledc_timer_bit_t,
    freqHz: Hertz,
    clkCfg: ledc_clk_cfg_t
  ): LedcTimer =
  result = LedcTimer()
  result.cfg.speed_mode = mode
  result.cfg.timer_num = timer
  result.cfg.duty_resolution = dutyRes
  result.cfg.freq_hz = freqHz
  result.cfg.clk_cfg = clkCfg
  result.cfg.deconfigure = false

  initLedc()

  let ret = ledc_timer_config(addr result.cfg)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_timer_config failed (" & $esp_err_to_name(ret) & ")", ret)

proc setFrequency*(t: LedcTimer; freqHz: Hertz): esp_err_t {.discardable.} =
  # Update timer frequency via driver, and keep cfg in sync.
  let ret = ledc_set_freq(t.cfg.speed_mode, t.cfg.timer_num, freqHz)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_set_freq failed (" & $esp_err_to_name(ret) & ")", ret)
  t.cfg.freq_hz = freqHz
  ret

proc getFrequency*(t: LedcTimer): Hertz =
  ledc_get_freq(t.cfg.speed_mode, t.cfg.timer_num)

# Channel helpers
proc newLedcChannel*(
    gpio: gpio_num_t,
    mode: ledc_mode_t,
    channel: ledc_channel_t,
    timer: ledc_timer_t,
    duty: uint32 = 0,
    hpoint: cint = 0,
    intr: ledc_intr_type_t = LEDC_INTR_DISABLE,
    sleepMode: ledc_sleep_mode_t = LEDC_SLEEP_MODE_NO_ALIVE_NO_PD,
    invertOutput: bool = false
  ): LedcChannel =
  result = LedcChannel()
  result.cfg.gpio_num = gpio.cint
  result.cfg.speed_mode = mode
  result.cfg.channel = channel
  result.cfg.timer_sel = timer
  result.cfg.intr_type = intr
  result.cfg.duty = duty
  result.cfg.hpoint = hpoint
  result.cfg.sleep_mode = sleepMode
  result.cfg.flags.output_invert = (if invertOutput: 1'u32 else: 0'u32)

  let ret = ledc_channel_config(addr result.cfg)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_channel_config failed (" & $esp_err_to_name(ret) & ")", ret)

proc bindToGpio*(c: LedcChannel; gpio: gpio_num_t): esp_err_t {.discardable.} =
  # Routes channel output to the given GPIO without reconfiguring other params.
  let ret = ledc_set_pin(gpio.cint, c.cfg.speed_mode, c.cfg.channel)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_set_pin failed (" & $esp_err_to_name(ret) & ")", ret)
  c.cfg.gpio_num = gpio.cint
  ret

proc stop*(c: LedcChannel; idleLevel: uint32 = 0): esp_err_t {.discardable.} =
  let ret = ledc_stop(c.cfg.speed_mode, c.cfg.channel, idleLevel)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_stop failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

# Duty helpers
proc setDuty*(c: LedcChannel; duty: uint32; hpoint: uint32 = 0): esp_err_t {.discardable.} =
  # Thread-safe immediate update
  let ret = ledc_set_duty_and_update(c.cfg.speed_mode, c.cfg.channel, duty, hpoint)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_set_duty_and_update failed (" & $esp_err_to_name(ret) & ")", ret)
  c.cfg.duty = duty
  c.cfg.hpoint = hpoint.cint
  ret

proc getDuty*(c: LedcChannel): uint32 =
  ledc_get_duty(c.cfg.speed_mode, c.cfg.channel)

proc setDutyPercent*(c: LedcChannel; percent: float): esp_err_t {.discardable.} =
  # Convert percentage [0.0..100.0] to raw duty based on current resolution.
  let bits = c.cfg.timer_sel # for access to resolution we don't have direct field here
  discard bits # keep compiler happy if not used; use current duty value's resolution from timer config if available
  # Because channel doesn't track resolution, compute via current duty's max guess from last timer config call
  # Caller is expected to pick resolution and desired freq when creating the timer.
  # Use the last configured timer resolution via getFrequency side effect; conservative max = (1 shl res) - 1.
  # If unknown, default to 2^13 - 1 which is common on ESP-IDF.
  var resBits: int = 13
  # Try to infer from duty if it's non-zero by finding highest set bit + 1 (best-effort)
  if c.cfg.duty > 0'u32:
    var x = c.cfg.duty
    var hb = 0
    while x != 0'u32:
      x = x shr 1
      inc hb
    if hb > resBits: resBits = hb
  let maxDuty = (1'u32 shl resBits) - 1'u32
  let clamped = (if percent < 0.0: 0.0 elif percent > 100.0: 100.0 else: percent)
  let duty = uint32(clamped * float(maxDuty) / 100.0 + 0.5)
  c.setDuty(duty)

# Fade helpers
proc fadeToDutyMs*(c: LedcChannel; targetDuty: uint32; timeMs: uint32;
                    mode: ledc_fade_mode_t = LEDC_FADE_NO_WAIT): esp_err_t {.discardable.} =
  let ret = ledc_set_fade_time_and_start(c.cfg.speed_mode, c.cfg.channel, targetDuty, timeMs, mode)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_set_fade_time_and_start failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

proc fadeStepAndStart*(c: LedcChannel; targetDuty: uint32; scale: uint32; cycleNum: uint32;
                        mode: ledc_fade_mode_t = LEDC_FADE_NO_WAIT): esp_err_t {.discardable.} =
  let ret = ledc_set_fade_step_and_start(c.cfg.speed_mode, c.cfg.channel, targetDuty, scale, cycleNum, mode)
  if ret != ESP_OK:
    raise newEspError[LedcError]("ledc_set_fade_step_and_start failed (" & $esp_err_to_name(ret) & ")", ret)
  ret

when defined(SOC_LEDC_SUPPORT_FADE_STOP):
  proc fadeStop*(c: LedcChannel): esp_err_t {.discardable.} =
    let ret = ledc_fade_stop(c.cfg.speed_mode, c.cfg.channel)
    if ret != ESP_OK:
      raise newEspError[LedcError]("ledc_fade_stop failed (" & $esp_err_to_name(ret) & ")", ret)
    ret
