##  LEDC (LED Controller) fade example
##
##    This example code is in the Public Domain (or CC0 licensed, at your option.)
##
##    Unless required by applicable law or agreed to in writing, this
##    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.
##

import
  freertos/FreeRTOS, freertos/task, driver/ledc, esp_err

##
##  About this example
##
##  1. Start with initializing LEDC module:
##     a. Set the timer of LEDC first, this determines the frequency
##        and resolution of PWM.
##     b. Then set the LEDC channel you want to use,
##        and bind with one of the timers.
##
##  2. You need first to install a default fade function,
##     then you can use fade APIs.
##
##  3. You can also set a target duty directly without fading.
##
##  4. This example uses GPIO18/19/4/5 as LEDC output,
##     and it will change the duty repeatedly.
##
##  5. GPIO18/19 are from high speed channel group.
##     GPIO4/5 are from low speed channel group.
##
##

const
  LEDC_HS_TIMER* = LEDC_TIMER_0
  LEDC_HS_MODE* = LEDC_HIGH_SPEED_MODE
  LEDC_HS_CH0_GPIO* = (18)
  LEDC_HS_CH0_CHANNEL* = LEDC_CHANNEL_0
  LEDC_HS_CH1_GPIO* = (19)
  LEDC_HS_CH1_CHANNEL* = LEDC_CHANNEL_1
  LEDC_LS_TIMER* = LEDC_TIMER_1
  LEDC_LS_MODE* = LEDC_LOW_SPEED_MODE
  LEDC_LS_CH2_GPIO* = (4)
  LEDC_LS_CH2_CHANNEL* = LEDC_CHANNEL_2
  LEDC_LS_CH3_GPIO* = (5)
  LEDC_LS_CH3_CHANNEL* = LEDC_CHANNEL_3
  LEDC_TEST_CH_NUM* = (4)
  LEDC_TEST_DUTY* = (4000)
  LEDC_TEST_FADE_TIME* = (3000)

proc app_main*() =
  var ch: cint
  ##
  ##  Prepare and set configuration of timers
  ##  that will be used by LED Controller
  ##
  var ledc_timer: ledc_timer_config_t
  ledc_timer.duty_resolution = LEDC_TIMER_13_BIT
  ##  resolution of PWM duty
  ledc_timer.freq_hz = 5000
  ##  frequency of PWM signal
  ledc_timer.speed_mode = LEDC_HS_MODE
  ##  timer mode
  ledc_timer.timer_num = LEDC_HS_TIMER
  ##  timer index
  ledc_timer.clk_cfg = LEDC_AUTO_CLK
  ##  Auto select the source clock
  ##  Set configuration of timer0 for high speed channels
  ledc_timer_config(addr(ledc_timer))
  ##  Prepare and set configuration of timer1 for low speed channels
  ledc_timer.speed_mode = LEDC_LS_MODE
  ledc_timer.timer_num = LEDC_LS_TIMER
  ledc_timer_config(addr(ledc_timer))
  ##
  ##  Prepare individual configuration
  ##  for each channel of LED Controller
  ##  by selecting:
  ##  - controller's channel number
  ##  - output duty cycle, set initially to 0
  ##  - GPIO number where LED is connected to
  ##  - speed mode, either high or low
  ##  - timer servicing selected channel
  ##    Note: if different channels use one timer,
  ##          then frequency and bit_num of these channels
  ##          will be the same
  ##
  var ledc_channel: array[LEDC_TEST_CH_NUM, ledc_channel_config_t]
  ledc_channel[0].channel = LEDC_HS_CH0_CHANNEL
  ledc_channel[0].duty = 0
  ledc_channel[0].gpio_num = LEDC_HS_CH0_GPIO
  ledc_channel[0].speed_mode = LEDC_HS_MODE
  ledc_channel[0].hpoint = 0
  ledc_channel[0].timer_sel = LEDC_HS_TIMER
  ledc_channel[1].channel = LEDC_HS_CH1_CHANNEL
  ledc_channel[1].duty = 0
  ledc_channel[1].gpio_num = LEDC_HS_CH1_GPIO
  ledc_channel[1].speed_mode = LEDC_HS_MODE
  ledc_channel[1].hpoint = 0
  ledc_channel[1].timer_sel = LEDC_HS_TIMER
  ledc_channel[2].channel = LEDC_LS_CH2_CHANNEL
  ledc_channel[2].duty = 0
  ledc_channel[2].gpio_num = LEDC_LS_CH2_GPIO
  ledc_channel[2].speed_mode = LEDC_LS_MODE
  ledc_channel[2].hpoint = 0
  ledc_channel[2].timer_sel = LEDC_LS_TIMER
  ledc_channel[3].channel = LEDC_LS_CH3_CHANNEL
  ledc_channel[3].duty = 0
  ledc_channel[3].gpio_num = LEDC_LS_CH3_GPIO
  ledc_channel[3].speed_mode = LEDC_LS_MODE
  ledc_channel[3].hpoint = 0
  ledc_channel[3].timer_sel = LEDC_LS_TIMER
  ##  Set LED Controller with previously prepared configuration
  ch = 0
  while ch < LEDC_TEST_CH_NUM:
    ledc_channel_config(addr(ledc_channel[ch]))
    inc(ch)
  ##  Initialize fade service.
  ledc_fade_func_install(0)
  while 1:
    printf("1. LEDC fade up to duty = %d\n", LEDC_TEST_DUTY)
    ch = 0
    while ch < LEDC_TEST_CH_NUM:
      ledc_set_fade_with_time(ledc_channel[ch].speed_mode,
                              ledc_channel[ch].channel, LEDC_TEST_DUTY,
                              LEDC_TEST_FADE_TIME)
      ledc_fade_start(ledc_channel[ch].speed_mode, ledc_channel[ch].channel,
                      LEDC_FADE_NO_WAIT)
      inc(ch)
    vTaskDelay(LEDC_TEST_FADE_TIME div portTICK_PERIOD_MS)
    printf("2. LEDC fade down to duty = 0\n")
    ch = 0
    while ch < LEDC_TEST_CH_NUM:
      ledc_set_fade_with_time(ledc_channel[ch].speed_mode,
                              ledc_channel[ch].channel, 0, LEDC_TEST_FADE_TIME)
      ledc_fade_start(ledc_channel[ch].speed_mode, ledc_channel[ch].channel,
                      LEDC_FADE_NO_WAIT)
      inc(ch)
    vTaskDelay(LEDC_TEST_FADE_TIME div portTICK_PERIOD_MS)
    printf("3. LEDC set duty = %d without fade\n", LEDC_TEST_DUTY)
    ch = 0
    while ch < LEDC_TEST_CH_NUM:
      ledc_set_duty(ledc_channel[ch].speed_mode, ledc_channel[ch].channel,
                    LEDC_TEST_DUTY)
      ledc_update_duty(ledc_channel[ch].speed_mode, ledc_channel[ch].channel)
      inc(ch)
    vTaskDelay(1000 div portTICK_PERIOD_MS)
    printf("4. LEDC set duty = 0 without fade\n")
    ch = 0
    while ch < LEDC_TEST_CH_NUM:
      ledc_set_duty(ledc_channel[ch].speed_mode, ledc_channel[ch].channel, 0)
      ledc_update_duty(ledc_channel[ch].speed_mode, ledc_channel[ch].channel)
      inc(ch)
    vTaskDelay(1000 div portTICK_PERIOD_MS)
