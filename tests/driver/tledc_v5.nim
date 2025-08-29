import nesper
import nesper/ledcs

export ledcs

# Compile-only sanity for the v5 LEDC wrapper
block:
  let timer = newLedcTimer(
    mode = LEDC_LOW_SPEED_MODE,
    timer = LEDC_TIMER_0,
    dutyRes = LEDC_TIMER_13_BIT,
    freqHz = 4_000'u32,
    clkCfg = LEDC_AUTO_CLK
  )

  let ch = newLedcChannel(
    gpio = gpio_num_t(5),
    mode = LEDC_LOW_SPEED_MODE,
    channel = LEDC_CHANNEL_0,
    timer = LEDC_TIMER_0,
    duty = 0,
    hpoint = 0
  )

  # Basic duty set (50%) using helper
  discard ch.setDutyPercent(50.0)

  # Fade support (install ISR and start a non-blocking fade back to 0)
  discard ledc_fade_func_install(0)
  discard ch.fadeToDutyMs(0'u32, 1000'u32, LEDC_FADE_NO_WAIT)

  # Print basic configuration for confirmation
  echo repr(timer.cfg)
  echo repr(ch.cfg)

