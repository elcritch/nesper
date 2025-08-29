##
##  SPDX-FileCopyrightText: 2015-2025 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../../consts
import ../hal/ledc_types

const hdr = "<driver/ledc.h>"

const
  LEDC_ERR_DUTY* = (0xFFFFFFFF)
  LEDC_ERR_VAL* = (-1)

type

  ledc_sleep_mode_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Strategies to be applied to the LEDC channel during system Light-sleep period
                              ##
    LEDC_SLEEP_MODE_NO_ALIVE_NO_PD = 0, ## !< The default mode: no LEDC output, and no power off the LEDC power domain.
    LEDC_SLEEP_MODE_NO_ALIVE_ALLOW_PD, ## !< The low-power-consumption mode: no LEDC output, and allow to power off the LEDC power domain.
                                        ##                                               This can save power, but at the expense of more RAM being consumed to save register context.
                                        ##                                               This option is only available on targets that support TOP domain to be powered down.
    LEDC_SLEEP_MODE_KEEP_ALIVE, ## !< The high-power-consumption mode: keep LEDC output when the system enters Light-sleep.
    LEDC_SLEEP_MODE_INVALID  ## !< Invalid LEDC sleep mode strategy


type

  INNER_C_STRUCT_ledc_1* = object ##
                              ##
                              ##  @brief Configuration parameters of LEDC channel for ledc_channel_config function
                              ##
    output_invert* {.importc: "output_invert", bitsize: 1.}: cuint
    ## !< Enable (1) or disable (0) gpio output invert


  ledc_channel_config_t* {.importc: "ledc_channel_config_t", header: hdr,
                           bycopy.} = object
    gpio_num* {.importc: "gpio_num".}: cint ## !< the LEDC output gpio_num, if you want to use gpio16, gpio_num = 16
    speed_mode* {.importc: "speed_mode".}: ledc_mode_t ##
                              ## !< LEDC speed speed_mode, high-speed mode (only exists on esp32) or low-speed mode
    channel* {.importc: "channel".}: ledc_channel_t ##
                              ## !< LEDC channel (0 - LEDC_CHANNEL_MAX-1)
    intr_type* {.importc: "intr_type".}: ledc_intr_type_t ##
                              ## !< configure interrupt, Fade interrupt enable  or Fade interrupt disable
    timer_sel* {.importc: "timer_sel".}: ledc_timer_t ##
                              ## !< Select the timer source of channel (0 - LEDC_TIMER_MAX-1)
    duty* {.importc: "duty".}: uint32 ## !< LEDC channel duty, the range of duty setting is [0, (2**duty_resolution)]
    hpoint* {.importc: "hpoint".}: cint ## !< LEDC channel hpoint value, the range is [0, (2**duty_resolution)-1]
    sleep_mode* {.importc: "sleep_mode".}: ledc_sleep_mode_t ##
                              ## !< choose the desired behavior for the LEDC channel in Light-sleep
    flags* {.importc: "flags".}: INNER_C_STRUCT_ledc_1
    ## !< LEDC flags


  ledc_timer_config_t* {.importc: "ledc_timer_config_t", header: hdr,
                         bycopy.} = object ##
                                            ##  @brief Configuration parameters of LEDC timer for ledc_timer_config function
                                            ##
    speed_mode* {.importc: "speed_mode".}: ledc_mode_t ##
                              ## !< LEDC speed speed_mode, high-speed mode (only exists on esp32) or low-speed mode
    duty_resolution* {.importc: "duty_resolution".}: ledc_timer_bit_t ##
                              ## !< LEDC channel duty resolution
    timer_num* {.importc: "timer_num".}: ledc_timer_t ##
                              ## !< The timer source of channel (0 - LEDC_TIMER_MAX-1)
    freq_hz* {.importc: "freq_hz".}: uint32 ## !< LEDC timer frequency (Hz)
    clk_cfg* {.importc: "clk_cfg".}: ledc_clk_cfg_t ##
                              ## !< Configure LEDC source clock from ledc_clk_cfg_t.
                              ##                                                 Note that LEDC_USE_RC_FAST_CLK and LEDC_USE_XTAL_CLK are
                              ##                                                 non-timer-specific clock sources. You can not have one LEDC timer uses
                              ##                                                 RC_FAST_CLK as the clock source and have another LEDC timer uses XTAL_CLK
                              ##                                                 as its clock source. All chips except esp32 and esp32s2 do not have
                              ##                                                 timer-specific clock sources, which means clock source for all timers
                              ##                                                 must be the same one.
    deconfigure* {.importc: "deconfigure".}: bool
    ## !< Set this field to de-configure a LEDC timer which has been configured before
    ##                                                 Note that it will not check whether the timer wants to be de-configured
    ##                                                 is binded to any channel. Also, the timer has to be paused first before
    ##                                                 it can be de-configured.
    ##                                                 When this field is set, duty_resolution, freq_hz, clk_cfg fields are ignored.


  ledc_isr_handle_t* = intr_handle_t

  ledc_cb_event_t* {.size: sizeof(cint).} = enum ##
                                                  ##  @brief LEDC callback event type
                                                  ##
    LEDC_FADE_END_EVT        ## < LEDC fade end event


type

  ledc_cb_param_t* {.importc: "ledc_cb_param_t", header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief LEDC callback parameter
                              ##
    event* {.importc: "event".}: ledc_cb_event_t ## < Event name
    speed_mode* {.importc: "speed_mode".}: uint32 ## < Speed mode of the LEDC channel group
    channel* {.importc: "channel".}: uint32 ## < LEDC channel (0 - LEDC_CHANNEL_MAX-1)
    duty* {.importc: "duty".}: uint32
    ## < LEDC current duty of the channel, the range of duty is [0, (2**duty_resolution)]


  ledc_cb_t* = proc (param: ptr ledc_cb_param_t; user_arg: pointer): bool {.
      cdecl.} ##
              ##  @brief Type of LEDC event callback
              ##  @param param LEDC callback parameter
              ##  @param user_arg User registered data
              ##  @return Whether a high priority task has been waken up by this function
              ##

  ledc_cbs_t* {.importc: "ledc_cbs_t", header: hdr, bycopy.} = object ##
                              ##
                              ##  @brief Group of supported LEDC callbacks
                              ##  @note The callbacks are all running under ISR environment
                              ##
    fade_cb* {.importc: "fade_cb".}: ledc_cb_t
    ## < LEDC fade_end callback function



proc ledc_channel_config*(ledc_conf: ptr ledc_channel_config_t): esp_err_t {.
    cdecl, importc: "ledc_channel_config", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC channel configuration
                              ##         Configure LEDC channel with the given channel/output gpio_num/interrupt/source timer/frequency(Hz)/LEDC duty
                              ##
                              ##  @param ledc_conf Pointer of LEDC channel configure struct
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##

proc ledc_find_suitable_duty_resolution*(src_clk_freq: uint32;
    timer_freq: uint32): uint32 {.cdecl, importc: "ledc_find_suitable_duty_resolution",
                                  header: hdr.}
  ##
                              ##
                              ##  @brief Helper function to find the maximum possible duty resolution in bits for ledc_timer_config()
                              ##
                              ##  @param src_clk_freq LEDC timer source clock frequency (Hz) (See doxygen comments of `ledc_clk_cfg_t` or get from `esp_clk_tree_src_get_freq_hz`)
                              ##  @param timer_freq Desired LEDC timer frequency (Hz)
                              ##
                              ##  @return
                              ##      - 0 The timer frequency cannot be achieved
                              ##      - Others The largest duty resolution value to be set
                              ##

proc ledc_timer_config*(timer_conf: ptr ledc_timer_config_t): esp_err_t {.cdecl,
    importc: "ledc_timer_config", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC timer configuration
                              ##         Configure LEDC timer with the given source timer/frequency(Hz)/duty_resolution
                              ##
                              ##  @param  timer_conf Pointer of LEDC timer configure struct
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_FAIL Can not find a proper pre-divider number base on the given frequency and the current duty_resolution.
                              ##      - ESP_ERR_INVALID_STATE Timer cannot be de-configured because timer is not configured or is not paused
                              ##

proc ledc_update_duty*(speed_mode: ledc_mode_t; channel: ledc_channel_t): esp_err_t {.
    cdecl, importc: "ledc_update_duty", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC update channel parameters
                              ##
                              ##  @note  Call this function to activate the LEDC updated parameters.
                              ##         After ledc_set_duty, we need to call this function to update the settings.
                              ##         And the new LEDC parameters don't take effect until the next PWM cycle.
                              ##  @note  ledc_set_duty, ledc_set_duty_with_hpoint and ledc_update_duty are not thread-safe, do not call these functions to
                              ##         control one LEDC channel in different tasks at the same time.
                              ##         A thread-safe version of API is ledc_set_duty_and_update
                              ##  @note  If `CONFIG_LEDC_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##         makes it possible to execute even when the Cache is disabled.
                              ##  @note  This function is allowed to run within ISR context.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##

proc ledc_set_pin*(gpio_num: cint; speed_mode: ledc_mode_t;
                   channel: ledc_channel_t): esp_err_t {.cdecl,
    importc: "ledc_set_pin", header: hdr.}
  ##
                                               ##  @brief Set LEDC output gpio.
                                               ##
                                               ##  @note This function only routes the LEDC signal to GPIO through matrix, other LEDC resources initialization are not involved.
                                               ##        Please use `ledc_channel_config()` instead to fully configure a LEDC channel.
                                               ##
                                               ##  @param  gpio_num The LEDC output gpio
                                               ##  @param  speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                                               ##  @param  channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                                               ##
                                               ##  @return
                                               ##      - ESP_OK Success
                                               ##      - ESP_ERR_INVALID_ARG Parameter error
                                               ##

proc ledc_stop*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                idle_level: uint32): esp_err_t {.cdecl, importc: "ledc_stop",
    header: hdr.}
  ##
                      ##  @brief LEDC stop.
                      ##         Disable LEDC output, and set idle level
                      ##
                      ##  @note  If `CONFIG_LEDC_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                      ##         makes it possible to execute even when the Cache is disabled.
                      ##  @note  This function is allowed to run within ISR context.
                      ##
                      ##  @param  speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                      ##  @param  channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                      ##  @param  idle_level Set output idle level after LEDC stops.
                      ##
                      ##  @return
                      ##      - ESP_OK Success
                      ##      - ESP_ERR_INVALID_ARG Parameter error
                      ##

proc ledc_set_freq*(speed_mode: ledc_mode_t; timer_num: ledc_timer_t;
                    freq_hz: uint32): esp_err_t {.cdecl,
    importc: "ledc_set_freq", header: hdr.}
  ##
                                                ##  @brief LEDC set channel frequency (Hz)
                                                ##
                                                ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                                                ##  @param  timer_num LEDC timer index (0-3), select from ledc_timer_t
                                                ##  @param  freq_hz Set the LEDC frequency
                                                ##
                                                ##  @return
                                                ##      - ESP_OK Success
                                                ##      - ESP_ERR_INVALID_ARG Parameter error
                                                ##      - ESP_FAIL Can not find a proper pre-divider number base on the given frequency and the current duty_resolution.
                                                ##

proc ledc_get_freq*(speed_mode: ledc_mode_t; timer_num: ledc_timer_t): uint32 {.
    cdecl, importc: "ledc_get_freq", header: hdr.}
  ##
                              ##
                              ##  @brief      LEDC get channel frequency (Hz)
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param timer_num LEDC timer index (0-3), select from ledc_timer_t
                              ##
                              ##  @return
                              ##      - 0  error
                              ##      - Others Current LEDC frequency
                              ##

proc ledc_set_duty_with_hpoint*(speed_mode: ledc_mode_t;
                                channel: ledc_channel_t; duty: uint32;
                                hpoint: uint32): esp_err_t {.cdecl,
    importc: "ledc_set_duty_with_hpoint", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC set duty and hpoint value
                              ##         Only after calling ledc_update_duty will the duty update.
                              ##
                              ##  @note  ledc_set_duty, ledc_set_duty_with_hpoint and ledc_update_duty are not thread-safe, do not call these functions to
                              ##         control one LEDC channel in different tasks at the same time.
                              ##         A thread-safe version of API is ledc_set_duty_and_update
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param duty Set the LEDC duty, the range of duty setting is [0, (2**duty_resolution)]
                              ##  @param hpoint Set the LEDC hpoint value, the range is [0, (2**duty_resolution)-1]
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##

proc ledc_get_hpoint*(speed_mode: ledc_mode_t; channel: ledc_channel_t): cint {.
    cdecl, importc: "ledc_get_hpoint", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC get hpoint value, the counter value when the output is set high level.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##
                              ##  @return
                              ##      - LEDC_ERR_VAL if parameter error
                              ##      - Others Current hpoint value of LEDC channel
                              ##

proc ledc_set_duty*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                    duty: uint32): esp_err_t {.cdecl, importc: "ledc_set_duty",
    header: hdr.}
  ##
                      ##  @brief LEDC set duty
                      ##         This function do not change the hpoint value of this channel. if needed, please call ledc_set_duty_with_hpoint.
                      ##         only after calling ledc_update_duty will the duty update.
                      ##
                      ##  @note  ledc_set_duty, ledc_set_duty_with_hpoint and ledc_update_duty are not thread-safe, do not call these functions to
                      ##         control one LEDC channel in different tasks at the same time.
                      ##         A thread-safe version of API is ledc_set_duty_and_update.
                      ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                      ##         Other duty operations will have to wait until the fade operation has finished.
                      ##
                      ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                      ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                      ##  @param duty Set the LEDC duty, the range of duty setting is [0, (2**duty_resolution)]
                      ##
                      ##  @return
                      ##      - ESP_OK Success
                      ##      - ESP_ERR_INVALID_ARG Parameter error
                      ##

proc ledc_get_duty*(speed_mode: ledc_mode_t; channel: ledc_channel_t): uint32 {.
    cdecl, importc: "ledc_get_duty", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC get duty
                              ##         This function returns the duty at the present PWM cycle.
                              ##         You shouldn't expect the function to return the new duty in the same cycle of calling ledc_update_duty,
                              ##         because duty update doesn't take effect until the next cycle.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##
                              ##  @return
                              ##      - LEDC_ERR_DUTY if parameter error
                              ##      - Others Current LEDC duty
                              ##

proc ledc_set_fade*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                    duty: uint32; fade_direction: ledc_duty_direction_t;
                    step_num: uint32; duty_cycle_num: uint32; duty_scale: uint32): esp_err_t {.
    cdecl, importc: "ledc_set_fade", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC set gradient
                              ##         Set LEDC gradient, After the function calls the ledc_update_duty function, the function can take effect.
                              ##
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param duty Set the start of the gradient duty, the range of duty setting is [0, (2**duty_resolution)]
                              ##  @param fade_direction Set the direction of the gradient
                              ##  @param step_num Set the number of the gradient
                              ##  @param duty_cycle_num Set how many LEDC tick each time the gradient lasts
                              ##  @param duty_scale Set gradient change amplitude
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##

proc ledc_isr_register*(fn: proc (a1: pointer) {.cdecl.}; arg: pointer;
                        intr_alloc_flags: cint; handle: ptr ledc_isr_handle_t): esp_err_t {.
    cdecl, importc: "ledc_isr_register", header: hdr.}
  ##
                              ##
                              ##  @brief Register LEDC interrupt handler, the handler is an ISR.
                              ##         The handler will be attached to the same CPU core that this function is running on.
                              ##
                              ##  @param fn Interrupt handler function.
                              ##  @param arg User-supplied argument passed to the handler function.
                              ##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
                              ##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
                              ##  @param handle Pointer to return handle. If non-NULL, a handle for the interrupt will
                              ##         be returned here.
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_NOT_FOUND Failed to find available interrupt source
                              ##

proc ledc_timer_set*(speed_mode: ledc_mode_t; timer_sel: ledc_timer_t;
                     clock_divider: uint32; duty_resolution: uint32;
                     clk_src: ledc_clk_src_t): esp_err_t {.cdecl,
    importc: "ledc_timer_set", header: hdr.}
  ##
                                                 ##  @brief Configure LEDC timer settings
                                                 ##
                                                 ##  This function does not take care of whether the chosen clock source is enabled or not, also does not handle the clock source
                                                 ##  to meet channel sleep mode choice.
                                                 ##
                                                 ##  If the chosen clock source is a new clock source to the LEDC timer, please use `ledc_timer_config`;
                                                 ##  If the clock source is kept to be the same, but frequency needs to be updated, please use `ledc_set_freq`.
                                                 ##
                                                 ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                                                 ##  @param timer_sel  Timer index (0-3), there are 4 timers in LEDC module
                                                 ##  @param clock_divider Timer clock divide value, the timer clock is divided from the selected clock source
                                                 ##  @param duty_resolution Resolution of duty setting in number of bits. The range is [1, SOC_LEDC_TIMER_BIT_WIDTH]
                                                 ##  @param clk_src Select LEDC source clock.
                                                 ##
                                                 ##  @return
                                                 ##      - (-1) Parameter error
                                                 ##      - Other Current LEDC duty
                                                 ##

proc ledc_timer_rst*(speed_mode: ledc_mode_t; timer_sel: ledc_timer_t): esp_err_t {.
    cdecl, importc: "ledc_timer_rst", header: hdr.}
  ##
                              ##
                              ##  @brief Reset LEDC timer
                              ##
                              ##  @param  speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param  timer_sel LEDC timer index (0-3), select from ledc_timer_t
                              ##
                              ##  @return
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_OK Success
                              ##

proc ledc_timer_pause*(speed_mode: ledc_mode_t; timer_sel: ledc_timer_t): esp_err_t {.
    cdecl, importc: "ledc_timer_pause", header: hdr.}
  ##
                              ##
                              ##  @brief Pause LEDC timer counter
                              ##
                              ##  @param  speed_mode  Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param  timer_sel LEDC timer index (0-3), select from ledc_timer_t
                              ##
                              ##  @return
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_OK Success
                              ##

proc ledc_timer_resume*(speed_mode: ledc_mode_t; timer_sel: ledc_timer_t): esp_err_t {.
    cdecl, importc: "ledc_timer_resume", header: hdr.}
  ##
                              ##
                              ##  @brief Resume LEDC timer
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param timer_sel LEDC timer index (0-3), select from ledc_timer_t
                              ##
                              ##  @return
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_OK Success
                              ##

proc ledc_bind_channel_timer*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                              timer_sel: ledc_timer_t): esp_err_t {.cdecl,
    importc: "ledc_bind_channel_timer", header: hdr.}
  ##
                              ##
                              ##  @brief Bind LEDC channel with the selected timer
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param timer_sel LEDC timer index (0-3), select from ledc_timer_t
                              ##
                              ##  @return
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_OK Success
                              ##

proc ledc_set_fade_with_step*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                              target_duty: uint32; scale: uint32;
                              cycle_num: uint32): esp_err_t {.cdecl,
    importc: "ledc_set_fade_with_step", header: hdr.}
  ##
                              ##
                              ##  @brief Set LEDC fade function.
                              ##
                              ##  @note  Call ledc_fade_func_install() once before calling this function.
                              ##         Call ledc_fade_start() after this to start fading.
                              ##  @note  ledc_set_fade_with_step, ledc_set_fade_with_time and ledc_fade_start are not thread-safe, do not call these functions to
                              ##         control one LEDC channel in different tasks at the same time.
                              ##         A thread-safe version of API is ledc_set_fade_step_and_start
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param target_duty Target duty of fading [0, (2**duty_resolution)]
                              ##  @param scale Controls the increase or decrease step scale.
                              ##  @param cycle_num increase or decrease the duty every cycle_num cycles
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_FAIL Fade function init error
                              ##

proc ledc_set_fade_with_time*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                              target_duty: uint32; desired_fade_time_ms: cint): esp_err_t {.
    cdecl, importc: "ledc_set_fade_with_time", header: hdr.}
  ##
                              ##
                              ##  @brief Set LEDC fade function, with a limited time.
                              ##
                              ##  @note  Call ledc_fade_func_install() once before calling this function.
                              ##         Call ledc_fade_start() after this to start fading.
                              ##  @note  ledc_set_fade_with_step, ledc_set_fade_with_time and ledc_fade_start are not thread-safe, do not call these functions to
                              ##         control one LEDC channel in different tasks at the same time.
                              ##         A thread-safe version of API is ledc_set_fade_step_and_start
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param target_duty Target duty of fading [0, (2**duty_resolution)]
                              ##  @param desired_fade_time_ms The intended time of the fading ( ms ).
                              ##                              Note that the actual time it takes to complete the fade could vary by a factor of up to 2x shorter
                              ##                              or longer than the expected time due to internal rounding errors in calculations.
                              ##                              Specifically:
                              ##                              * The total number of cycles (total_cycle_num = desired_fade_time_ms * freq / 1000)
                              ##                              * The difference in duty cycle (duty_delta = |target_duty - current_duty|)
                              ##                              The fade may complete faster than expected if total_cycle_num larger than duty_delta. Conversely,
                              ##                              it may take longer than expected if total_cycle_num is less than duty_delta.
                              ##                              The closer the ratio of total_cycle_num/duty_delta (or its inverse) is to a whole number (the floor value),
                              ##                              the more accurately the actual fade duration will match the intended time.
                              ##                              If an exact fade time is expected, please consider to split the entire fade into several smaller linear fades.
                              ##                              The split should make each fade step has a divisible total_cycle_num/duty_delta (or its inverse) ratio.
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_FAIL Fade function init error
                              ##

proc ledc_fade_func_install*(intr_alloc_flags: cint): esp_err_t {.cdecl,
    importc: "ledc_fade_func_install", header: hdr.}
  ##
                              ##
                              ##  @brief Install LEDC fade function. This function will occupy interrupt of LEDC module.
                              ##
                              ##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
                              ##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Intr flag error
                              ##      - ESP_ERR_NOT_FOUND Failed to find available interrupt source
                              ##      - ESP_ERR_INVALID_STATE Fade function already installed
                              ##

proc ledc_fade_func_uninstall*() {.cdecl, importc: "ledc_fade_func_uninstall",
                                   header: hdr.}
  ##
                              ##
                              ##  @brief Uninstall LEDC fade function.
                              ##

proc ledc_fade_start*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                      fade_mode: ledc_fade_mode_t): esp_err_t {.cdecl,
    importc: "ledc_fade_start", header: hdr.}
  ##
                                                  ##  @brief Start LEDC fading.
                                                  ##
                                                  ##  @note  Call ledc_fade_func_install() once before calling this function.
                                                  ##         Call this API right after ledc_set_fade_with_time or ledc_set_fade_with_step before to start fading.
                                                  ##  @note  Starting fade operation with this API is not thread-safe, use with care.
                                                  ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                                                  ##         Other duty operations will have to wait until the fade operation has finished.
                                                  ##
                                                  ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                                                  ##  @param channel LEDC channel number
                                                  ##  @param fade_mode Whether to block until fading done. See ledc_types.h ledc_fade_mode_t for more info.
                                                  ##         Note that this function will not return until fading to the target duty if LEDC_FADE_WAIT_DONE mode is selected.
                                                  ##
                                                  ##  @return
                                                  ##      - ESP_OK Success
                                                  ##      - ESP_ERR_INVALID_STATE Channel not initialized or fade function not installed.
                                                  ##      - ESP_ERR_INVALID_ARG Parameter error.
                                                  ##
when defined(SOC_LEDC_SUPPORT_FADE_STOP):

  proc ledc_fade_stop*(speed_mode: ledc_mode_t; channel: ledc_channel_t): esp_err_t {.
      cdecl, importc: "ledc_fade_stop", header: hdr.}
    ##
                              ##
                              ##  @brief Stop LEDC fading. The duty of the channel is guaranteed to be fixed at most one PWM cycle after the function returns.
                              ##
                              ##  @note  This API can be called if a new fixed duty or a new fade want to be set while the last fade operation is still running in progress.
                              ##  @note  Call this API will abort the fading operation only if it was started by calling ledc_fade_start with LEDC_FADE_NO_WAIT mode.
                              ##  @note  If a fade was started with LEDC_FADE_WAIT_DONE mode, calling this API afterwards has no use in stopping the fade. Fade will continue until it reaches the target duty.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel number
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_FAIL Fade function init error
                              ##

proc ledc_set_duty_and_update*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                               duty: uint32; hpoint: uint32): esp_err_t {.cdecl,
    importc: "ledc_set_duty_and_update", header: hdr.}
  ##
                              ##
                              ##  @brief A thread-safe API to set duty for LEDC channel and return when duty updated.
                              ##
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param duty Set the LEDC duty, the range of duty setting is [0, (2**duty_resolution)]
                              ##  @param hpoint Set the LEDC hpoint value, the range is [0, (2**duty_resolution)-1]
                              ##
                              ##  @return
                              ##       - ESP_OK Success
                              ##       - ESP_ERR_INVALID_STATE Channel not initialized
                              ##       - ESP_ERR_INVALID_ARG Parameter error
                              ##       - ESP_FAIL Fade function init error
                              ##

proc ledc_set_fade_time_and_start*(speed_mode: ledc_mode_t;
                                   channel: ledc_channel_t; target_duty: uint32;
                                   desired_fade_time_ms: uint32;
                                   fade_mode: ledc_fade_mode_t): esp_err_t {.
    cdecl, importc: "ledc_set_fade_time_and_start", header: hdr.}
  ##
                              ##
                              ##  @brief A thread-safe API to set and start LEDC fade function, with a limited time.
                              ##
                              ##  @note  Call ledc_fade_func_install() once, before calling this function.
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param target_duty Target duty of fading [0, (2**duty_resolution)]
                              ##  @param desired_fade_time_ms The intended time of the fading ( ms ).
                              ##                              Note that the actual time it takes to complete the fade could vary by a factor of up to 2x shorter
                              ##                              or longer than the expected time due to internal rounding errors in calculations.
                              ##                              Specifically:
                              ##                              * The total number of cycles (total_cycle_num = desired_fade_time_ms * freq / 1000)
                              ##                              * The difference in duty cycle (duty_delta = |target_duty - current_duty|)
                              ##                              The fade may complete faster than expected if total_cycle_num larger than duty_delta. Conversely,
                              ##                              it may take longer than expected if total_cycle_num is less than duty_delta.
                              ##                              The closer the ratio of total_cycle_num/duty_delta (or its inverse) is to a whole number (the floor value),
                              ##                              the more accurately the actual fade duration will match the intended time.
                              ##                              If an exact fade time is expected, please consider to split the entire fade into several smaller linear fades.
                              ##                              The split should make each fade step has a divisible total_cycle_num/duty_delta (or its inverse) ratio.
                              ##  @param fade_mode choose blocking or non-blocking mode
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_FAIL Fade function init error
                              ##

proc ledc_set_fade_step_and_start*(speed_mode: ledc_mode_t;
                                   channel: ledc_channel_t; target_duty: uint32;
                                   scale: uint32; cycle_num: uint32;
                                   fade_mode: ledc_fade_mode_t): esp_err_t {.
    cdecl, importc: "ledc_set_fade_step_and_start", header: hdr.}
  ##
                              ##
                              ##  @brief A thread-safe API to set and start LEDC fade function.
                              ##
                              ##  @note  Call ledc_fade_func_install() once before calling this function.
                              ##  @note  For ESP32, hardware does not support any duty change while a fade operation is running in progress on that channel.
                              ##         Other duty operations will have to wait until the fade operation has finished.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param target_duty Target duty of fading [0, (2**duty_resolution)]
                              ##  @param scale Controls the increase or decrease step scale.
                              ##  @param cycle_num increase or decrease the duty every cycle_num cycles
                              ##  @param fade_mode choose blocking or non-blocking mode
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_FAIL Fade function init error
                              ##

proc ledc_cb_register*(speed_mode: ledc_mode_t; channel: ledc_channel_t;
                       cbs: ptr ledc_cbs_t; user_arg: pointer): esp_err_t {.
    cdecl, importc: "ledc_cb_register", header: hdr.}
  ##
                              ##
                              ##  @brief LEDC callback registration function
                              ##
                              ##  @note  The callback is called from an ISR, it must never attempt to block, and any FreeRTOS API called must be ISR capable.
                              ##
                              ##  @param speed_mode Select the LEDC channel group with specified speed mode. Note that not all targets support high speed mode.
                              ##  @param channel LEDC channel index (0 - LEDC_CHANNEL_MAX-1), select from ledc_channel_t
                              ##  @param cbs Group of LEDC callback functions
                              ##  @param user_arg user registered data for the callback function
                              ##
                              ##  @return
                              ##      - ESP_OK Success
                              ##      - ESP_ERR_INVALID_ARG Parameter error
                              ##      - ESP_ERR_INVALID_STATE Channel not initialized
                              ##      - ESP_FAIL Fade function init error
                              ## 