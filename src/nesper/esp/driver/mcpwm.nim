##  Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

import
  esp_err, soc/soc, driver/gpio, driver/periph_ctrl, esp_intr_alloc

## *
##  @brief IO signals for the MCPWM
##
##         - 6 MCPWM output pins that generate PWM signals
##         - 3 MCPWM fault input pins to detect faults like overcurrent, overvoltage, etc.
##         - 3 MCPWM sync input pins to synchronize MCPWM outputs signals
##         - 3 MCPWM capture input pins to gather feedback from controlled motors, using e.g. hall sensors
##

type
  mcpwm_io_signals_t* {.size: sizeof(cint).} = enum
    MCPWM0A = 0,                ## !<PWM0A output pin
    MCPWM0B,                  ## !<PWM0B output pin
    MCPWM1A,                  ## !<PWM1A output pin
    MCPWM1B,                  ## !<PWM1B output pin
    MCPWM2A,                  ## !<PWM2A output pin
    MCPWM2B,                  ## !<PWM2B output pin
    MCPWM_SYNC_0,             ## !<SYNC0  input pin
    MCPWM_SYNC_1,             ## !<SYNC1  input pin
    MCPWM_SYNC_2,             ## !<SYNC2  input pin
    MCPWM_FAULT_0,            ## !<FAULT0 input pin
    MCPWM_FAULT_1,            ## !<FAULT1 input pin
    MCPWM_FAULT_2,            ## !<FAULT2 input pin
    MCPWM_CAP_0 = 84,           ## !<CAP0   input pin
    MCPWM_CAP_1,              ## !<CAP1   input pin
    MCPWM_CAP_2               ## !<CAP2   input pin


## *
##  @brief MCPWM pin number for
##
##

type
  mcpwm_pin_config_t* {.importc: "mcpwm_pin_config_t", header: "mcpwm.h", bycopy.} = object
    mcpwm0a_out_num* {.importc: "mcpwm0a_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm0b_out_num* {.importc: "mcpwm0b_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm1a_out_num* {.importc: "mcpwm1a_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm1b_out_num* {.importc: "mcpwm1b_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm2a_out_num* {.importc: "mcpwm2a_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm2b_out_num* {.importc: "mcpwm2b_out_num".}: cint ## !<MCPWM0A out pin
    mcpwm_sync0_in_num* {.importc: "mcpwm_sync0_in_num".}: cint ## !<SYNC0  in pin
    mcpwm_sync1_in_num* {.importc: "mcpwm_sync1_in_num".}: cint ## !<SYNC1  in pin
    mcpwm_sync2_in_num* {.importc: "mcpwm_sync2_in_num".}: cint ## !<SYNC2  in pin
    mcpwm_fault0_in_num* {.importc: "mcpwm_fault0_in_num".}: cint ## !<FAULT0 in pin
    mcpwm_fault1_in_num* {.importc: "mcpwm_fault1_in_num".}: cint ## !<FAULT1 in pin
    mcpwm_fault2_in_num* {.importc: "mcpwm_fault2_in_num".}: cint ## !<FAULT2 in pin
    mcpwm_cap0_in_num* {.importc: "mcpwm_cap0_in_num".}: cint ## !<CAP0   in pin
    mcpwm_cap1_in_num* {.importc: "mcpwm_cap1_in_num".}: cint ## !<CAP1   in pin
    mcpwm_cap2_in_num* {.importc: "mcpwm_cap2_in_num".}: cint ## !<CAP2   in pin


## *
##  @brief Select MCPWM unit
##

type
  mcpwm_unit_t* {.size: sizeof(cint).} = enum
    MCPWM_UNIT_0 = 0,           ## !<MCPWM unit0 selected
    MCPWM_UNIT_1,             ## !<MCPWM unit1 selected
    MCPWM_UNIT_MAX            ## !<Num of MCPWM units on ESP32


## *
##  @brief Select MCPWM timer
##

type
  mcpwm_timer_t* {.size: sizeof(cint).} = enum
    MCPWM_TIMER_0 = 0,          ## !<Select MCPWM timer0
    MCPWM_TIMER_1,            ## !<Select MCPWM timer1
    MCPWM_TIMER_2,            ## !<Select MCPWM timer2
    MCPWM_TIMER_MAX           ## !<Num of MCPWM timers on ESP32


## *
##  @brief Select MCPWM operator
##

type
  mcpwm_operator_t* {.size: sizeof(cint).} = enum
    MCPWM_OPR_A = 0,            ## !<Select MCPWMXA, where 'X' is timer number
    MCPWM_OPR_B,              ## !<Select MCPWMXB, where 'X' is timer number
    MCPWM_OPR_MAX             ## !<Num of operators to each timer of MCPWM


## *
##  @brief Select type of MCPWM counter
##

type
  mcpwm_counter_type_t* {.size: sizeof(cint).} = enum
    MCPWM_UP_COUNTER = 1,       ## !<For asymmetric MCPWM
    MCPWM_DOWN_COUNTER,       ## !<For asymmetric MCPWM
    MCPWM_UP_DOWN_COUNTER,    ## !<For symmetric MCPWM, frequency is half of MCPWM frequency set
    MCPWM_COUNTER_MAX         ## !<Maximum counter mode


## *
##  @brief Select type of MCPWM duty cycle mode
##

type
  mcpwm_duty_type_t* {.size: sizeof(cint).} = enum
    MCPWM_DUTY_MODE_0 = 0,      ## !<Active high duty, i.e. duty cycle proportional to high time for asymmetric MCPWM
    MCPWM_DUTY_MODE_1,        ## !<Active low duty,  i.e. duty cycle proportional to low  time for asymmetric MCPWM, out of phase(inverted) MCPWM
    MCPWM_DUTY_MODE_MAX       ## !<Num of duty cycle modes


## *
##  @brief MCPWM carrier oneshot mode, in this mode the width of the first pulse of carrier can be programmed
##

type
  mcpwm_carrier_os_t* {.size: sizeof(cint).} = enum
    MCPWM_ONESHOT_MODE_DIS = 0, ## !<Enable oneshot mode
    MCPWM_ONESHOT_MODE_EN     ## !<Disable oneshot mode


## *
##  @brief MCPWM carrier output inversion, high frequency carrier signal active with MCPWM signal is high
##

type
  mcpwm_carrier_out_ivt_t* {.size: sizeof(cint).} = enum
    MCPWM_CARRIER_OUT_IVT_DIS = 0, ## !<Enable  carrier output inversion
    MCPWM_CARRIER_OUT_IVT_EN  ## !<Disable carrier output inversion


## *
##  @brief MCPWM select sync signal input
##

type
  mcpwm_sync_signal_t* {.size: sizeof(cint).} = enum
    MCPWM_SELECT_SYNC0 = 4,     ## !<Select SYNC0 as input
    MCPWM_SELECT_SYNC1,       ## !<Select SYNC1 as input
    MCPWM_SELECT_SYNC2        ## !<Select SYNC2 as input


## *
##  @brief MCPWM select fault signal input
##

type
  mcpwm_fault_signal_t* {.size: sizeof(cint).} = enum
    MCPWM_SELECT_F0 = 0,        ## !<Select F0 as input
    MCPWM_SELECT_F1,          ## !<Select F1 as input
    MCPWM_SELECT_F2           ## !<Select F2 as input


## *
##  @brief MCPWM select triggering level of fault signal
##

type
  mcpwm_fault_input_level_t* {.size: sizeof(cint).} = enum
    MCPWM_LOW_LEVEL_TGR = 0,    ## !<Fault condition occurs when fault input signal goes from high to low, currently not supported
    MCPWM_HIGH_LEVEL_TGR      ## !<Fault condition occurs when fault input signal goes low to high


## *
##  @brief MCPWM select action to be taken on MCPWMXA when fault occurs
##

type
  mcpwm_action_on_pwmxa_t* {.size: sizeof(cint).} = enum
    MCPWM_NO_CHANGE_IN_MCPWMXA = 0, ## !<No change in MCPWMXA output
    MCPWM_FORCE_MCPWMXA_LOW,  ## !<Make MCPWMXA output low
    MCPWM_FORCE_MCPWMXA_HIGH, ## !<Make MCPWMXA output high
    MCPWM_TOG_MCPWMXA         ## !<Make MCPWMXA output toggle


## *
##  @brief MCPWM select action to be taken on MCPWMxB when fault occurs
##

type
  mcpwm_action_on_pwmxb_t* {.size: sizeof(cint).} = enum
    MCPWM_NO_CHANGE_IN_MCPWMXB = 0, ## !<No change in MCPWMXB output
    MCPWM_FORCE_MCPWMXB_LOW,  ## !<Make MCPWMXB output low
    MCPWM_FORCE_MCPWMXB_HIGH, ## !<Make MCPWMXB output high
    MCPWM_TOG_MCPWMXB         ## !<Make MCPWMXB output toggle


## *
##  @brief MCPWM select capture signal input
##

type
  mcpwm_capture_signal_t* {.size: sizeof(cint).} = enum
    MCPWM_SELECT_CAP0 = 0,      ## !<Select CAP0 as input
    MCPWM_SELECT_CAP1,        ## !<Select CAP1 as input
    MCPWM_SELECT_CAP2         ## !<Select CAP2 as input


## *
##  @brief MCPWM select capture starts from which edge
##

type
  mcpwm_capture_on_edge_t* {.size: sizeof(cint).} = enum
    MCPWM_NEG_EDGE = 0,         ## !<Capture starts from negative edge
    MCPWM_POS_EDGE            ## !<Capture starts from positive edge


## *
##  @brief MCPWM deadtime types, used to generate deadtime, RED refers to rising edge delay and FED refers to falling edge delay
##

type
  mcpwm_deadtime_type_t* {.size: sizeof(cint).} = enum
    MCPWM_BYPASS_RED = 0,       ## !<MCPWMXA = no change, MCPWMXB = falling edge delay
    MCPWM_BYPASS_FED,         ## !<MCPWMXA = rising edge delay, MCPWMXB = no change
    MCPWM_ACTIVE_HIGH_MODE,   ## !<MCPWMXA = rising edge delay,  MCPWMXB = falling edge delay
    MCPWM_ACTIVE_LOW_MODE,    ## !<MCPWMXA = compliment of rising edge delay,  MCPWMXB = compliment of falling edge delay
    MCPWM_ACTIVE_HIGH_COMPLIMENT_MODE, ## !<MCPWMXA = rising edge delay,  MCPWMXB = compliment of falling edge delay
    MCPWM_ACTIVE_LOW_COMPLIMENT_MODE, ## !<MCPWMXA = compliment of rising edge delay,  MCPWMXB = falling edge delay
    MCPWM_ACTIVE_RED_FED_FROM_PWMXA, ## !<MCPWMXA = MCPWMXB = rising edge delay as well as falling edge delay, generated from MCPWMXA
    MCPWM_ACTIVE_RED_FED_FROM_PWMXB, ## !<MCPWMXA = MCPWMXB = rising edge delay as well as falling edge delay, generated from MCPWMXB
    MCPWM_DEADTIME_TYPE_MAX


## *
##  @brief MCPWM config structure
##

type
  mcpwm_config_t* {.importc: "mcpwm_config_t", header: "mcpwm.h", bycopy.} = object
    frequency* {.importc: "frequency".}: uint32 ## !<Set frequency of MCPWM in Hz
    cmpr_a* {.importc: "cmpr_a".}: cfloat ## !<Set % duty cycle for operator a(MCPWMXA), i.e for 62.3% duty cycle, duty_a = 62.3
    cmpr_b* {.importc: "cmpr_b".}: cfloat ## !<Set % duty cycle for operator b(MCPWMXB), i.e for 48% duty cycle, duty_b = 48.0
    duty_mode* {.importc: "duty_mode".}: mcpwm_duty_type_t ## !<Set type of duty cycle
    counter_mode* {.importc: "counter_mode".}: mcpwm_counter_type_t ## !<Set  type of MCPWM counter


## *
##  @brief MCPWM config carrier structure
##

type
  mcpwm_carrier_config_t* {.importc: "mcpwm_carrier_config_t", header: "mcpwm.h",
                           bycopy.} = object
    carrier_period* {.importc: "carrier_period".}: uint8 ## !<Set carrier period = (carrier_period + 1)*800ns, carrier_period should be < 16
    carrier_duty* {.importc: "carrier_duty".}: uint8 ## !<Set carrier duty cycle, carrier_duty should be less than 8 (increment every 12.5%)
    pulse_width_in_os* {.importc: "pulse_width_in_os".}: uint8 ## !<Set pulse width of first pulse in one shot mode = (carrier period)*(pulse_width_in_os + 1), should be less then 16
    carrier_os_mode* {.importc: "carrier_os_mode".}: mcpwm_carrier_os_t ## !<Enable or disable carrier oneshot mode
    carrier_ivt_mode* {.importc: "carrier_ivt_mode".}: mcpwm_carrier_out_ivt_t ## !<Invert output of carrier


## *
##  @brief This function initializes each gpio signal for MCPWM
##         @note
##         This function initializes one gpio at a time.
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param io_signal set MCPWM signals, each MCPWM unit has 6 output(MCPWMXA, MCPWMXB) and 9 input(SYNC_X, FAULT_X, CAP_X)
##                   'X' is timer_num(0-2)
##  @param gpio_num set this to configure gpio for MCPWM, if you want to use gpio16, gpio_num = 16
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_gpio_init*(mcpwm_num: mcpwm_unit_t; io_signal: mcpwm_io_signals_t;
                     gpio_num: cint): esp_err_t {.importc: "mcpwm_gpio_init",
    header: "mcpwm.h".}
## *
##  @brief Initialize MCPWM gpio structure
##         @note
##         This function can be used to initialize more then one gpio at a time.
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param mcpwm_pin MCPWM pin structure
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_pin*(mcpwm_num: mcpwm_unit_t; mcpwm_pin: ptr mcpwm_pin_config_t): esp_err_t {.
    importc: "mcpwm_set_pin", header: "mcpwm.h".}
## *
##  @brief Initialize MCPWM parameters
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param mcpwm_conf configure structure mcpwm_config_t
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_init*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                mcpwm_conf: ptr mcpwm_config_t): esp_err_t {.importc: "mcpwm_init",
    header: "mcpwm.h".}
## *
##  @brief Set frequency(in Hz) of MCPWM timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param frequency set the frequency in Hz of each timer
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_frequency*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                         frequency: uint32): esp_err_t {.
    importc: "mcpwm_set_frequency", header: "mcpwm.h".}
## *
##  @brief Set duty cycle of each operator(MCPWMXA/MCPWMXB)
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'X' is timer number selected
##  @param duty set duty cycle in %(i.e for 62.3% duty cycle, duty = 62.3) of each operator
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_duty*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                    op_num: mcpwm_operator_t; duty: cfloat): esp_err_t {.
    importc: "mcpwm_set_duty", header: "mcpwm.h".}
## *
##  @brief Set duty cycle of each operator(MCPWMXA/MCPWMXB) in us
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'x' is timer number selected
##  @param duty set duty value in microseconds of each operator
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_duty_in_us*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                          op_num: mcpwm_operator_t; duty: uint32): esp_err_t {.
    importc: "mcpwm_set_duty_in_us", header: "mcpwm.h".}
## *
##  @brief Set duty either active high or active low(out of phase/inverted)
##         @note
##         Call this function every time after mcpwm_set_signal_high or mcpwm_set_signal_low to resume with previously set duty cycle
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'x' is timer number selected
##  @param duty_num set active low or active high duty type
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_duty_type*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                         op_num: mcpwm_operator_t; duty_num: mcpwm_duty_type_t): esp_err_t {.
    importc: "mcpwm_set_duty_type", header: "mcpwm.h".}
## *
##  @brief Get frequency of timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - frequency of timer
##

proc mcpwm_get_frequency*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): uint32 {.
    importc: "mcpwm_get_frequency", header: "mcpwm.h".}
## *
##  @brief Get duty cycle of each operator
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'x' is timer number selected
##
##  @return
##      - duty cycle in % of each operator(56.7 means duty is 56.7%)
##

proc mcpwm_get_duty*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                    op_num: mcpwm_operator_t): cfloat {.importc: "mcpwm_get_duty",
    header: "mcpwm.h".}
## *
##  @brief Use this function to set MCPWM signal high
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'x' is timer number selected
##
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_signal_high*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                           op_num: mcpwm_operator_t): esp_err_t {.
    importc: "mcpwm_set_signal_high", header: "mcpwm.h".}
## *
##  @brief Use this function to set MCPWM signal low
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param op_num set the operator(MCPWMXA/MCPWMXB), 'x' is timer number selected
##
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_set_signal_low*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                          op_num: mcpwm_operator_t): esp_err_t {.
    importc: "mcpwm_set_signal_low", header: "mcpwm.h".}
## *
##  @brief Start MCPWM signal on timer 'x'
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_start*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_start", header: "mcpwm.h".}
## *
##  @brief Start MCPWM signal on timer 'x'
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_stop*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_stop", header: "mcpwm.h".}
## *
##  @brief  Initialize carrier configuration
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param carrier_conf configure structure mcpwm_carrier_config_t
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_init*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                        carrier_conf: ptr mcpwm_carrier_config_t): esp_err_t {.
    importc: "mcpwm_carrier_init", header: "mcpwm.h".}
## *
##  @brief Enable MCPWM carrier submodule, for respective timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_enable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_carrier_enable", header: "mcpwm.h".}
## *
##  @brief Disable MCPWM carrier submodule, for respective timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_disable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_carrier_disable", header: "mcpwm.h".}
## *
##  @brief Set period of carrier
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param carrier_period set the carrier period of each timer, carrier period = (carrier_period + 1)*800ns
##                     (carrier_period <= 15)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_set_period*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                              carrier_period: uint8): esp_err_t {.
    importc: "mcpwm_carrier_set_period", header: "mcpwm.h".}
## *
##  @brief Set duty_cycle of carrier
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param carrier_duty set duty_cycle of carrier , carrier duty cycle = carrier_duty*12.5%
##                   (chop_duty <= 7)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_set_duty_cycle*(mcpwm_num: mcpwm_unit_t;
                                  timer_num: mcpwm_timer_t; carrier_duty: uint8): esp_err_t {.
    importc: "mcpwm_carrier_set_duty_cycle", header: "mcpwm.h".}
## *
##  @brief Enable and set width of first pulse in carrier oneshot mode
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param pulse_width set pulse width of first pulse in oneshot mode, width = (carrier period)*(pulse_width +1)
##                     (pulse_width <= 15)
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_oneshot_mode_enable*(mcpwm_num: mcpwm_unit_t;
                                       timer_num: mcpwm_timer_t;
                                       pulse_width: uint8): esp_err_t {.
    importc: "mcpwm_carrier_oneshot_mode_enable", header: "mcpwm.h".}
## *
##  @brief Disable oneshot mode, width of first pulse = carrier period
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_oneshot_mode_disable*(mcpwm_num: mcpwm_unit_t;
                                        timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_carrier_oneshot_mode_disable", header: "mcpwm.h".}
## *
##  @brief Enable or disable carrier output inversion
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param carrier_ivt_mode enable or disable carrier output inversion
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_carrier_output_invert*(mcpwm_num: mcpwm_unit_t;
                                 timer_num: mcpwm_timer_t;
                                 carrier_ivt_mode: mcpwm_carrier_out_ivt_t): esp_err_t {.
    importc: "mcpwm_carrier_output_invert", header: "mcpwm.h".}
## *
##  @brief Enable and initialize deadtime for each MCPWM timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param dt_mode set deadtime mode
##  @param red set rising edge delay = red*100ns
##  @param fed set rising edge delay = fed*100ns
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_deadtime_enable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                           dt_mode: mcpwm_deadtime_type_t; red: uint32;
                           fed: uint32): esp_err_t {.
    importc: "mcpwm_deadtime_enable", header: "mcpwm.h".}
## *
##  @brief Disable deadtime on MCPWM timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_deadtime_disable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_deadtime_disable", header: "mcpwm.h".}
## *
##  @brief Initialize fault submodule, currently low level triggering is not supported
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param intput_level set fault signal level, which will cause fault to occur
##  @param fault_sig set the fault pin, which needs to be enabled
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_fault_init*(mcpwm_num: mcpwm_unit_t;
                      intput_level: mcpwm_fault_input_level_t;
                      fault_sig: mcpwm_fault_signal_t): esp_err_t {.
    importc: "mcpwm_fault_init", header: "mcpwm.h".}
## *
##  @brief Set oneshot mode on fault detection, once fault occur in oneshot mode reset is required to resume MCPWM signals
##         @note
##         currently low level triggering is not supported
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param fault_sig set the fault pin, which needs to be enabled for oneshot mode
##  @param action_on_pwmxa action to be taken on MCPWMXA when fault occurs, either no change or high or low or toggle
##  @param action_on_pwmxb action to be taken on MCPWMXB when fault occurs, either no change or high or low or toggle
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_fault_set_oneshot_mode*(mcpwm_num: mcpwm_unit_t;
                                  timer_num: mcpwm_timer_t;
                                  fault_sig: mcpwm_fault_signal_t;
                                  action_on_pwmxa: mcpwm_action_on_pwmxa_t;
                                  action_on_pwmxb: mcpwm_action_on_pwmxb_t): esp_err_t {.
    importc: "mcpwm_fault_set_oneshot_mode", header: "mcpwm.h".}
## *
##  @brief Set cycle-by-cycle mode on fault detection, once fault occur in cyc mode MCPWM signal resumes as soon as fault signal becomes inactive
##         @note
##         currently low level triggering is not supported
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param fault_sig set the fault pin, which needs to be enabled for cyc mode
##  @param action_on_pwmxa action to be taken on MCPWMXA when fault occurs, either no change or high or low or toggle
##  @param action_on_pwmxb action to be taken on MCPWMXB when fault occurs, either no change or high or low or toggle
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_fault_set_cyc_mode*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                              fault_sig: mcpwm_fault_signal_t;
                              action_on_pwmxa: mcpwm_action_on_pwmxa_t;
                              action_on_pwmxb: mcpwm_action_on_pwmxb_t): esp_err_t {.
    importc: "mcpwm_fault_set_cyc_mode", header: "mcpwm.h".}
## *
##  @brief Disable fault signal
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param fault_sig fault pin, which needs to be disabled
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_fault_deinit*(mcpwm_num: mcpwm_unit_t; fault_sig: mcpwm_fault_signal_t): esp_err_t {.
    importc: "mcpwm_fault_deinit", header: "mcpwm.h".}
## *
##  @brief Initialize capture submodule
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param cap_edge set capture edge, BIT(0) - negative edge, BIT(1) - positive edge
##  @param cap_sig capture pin, which needs to be enabled
##  @param num_of_pulse count time between rising/falling edge between 2 *(pulses mentioned), counter uses APB_CLK
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_capture_enable*(mcpwm_num: mcpwm_unit_t;
                          cap_sig: mcpwm_capture_signal_t;
                          cap_edge: mcpwm_capture_on_edge_t;
                          num_of_pulse: uint32): esp_err_t {.
    importc: "mcpwm_capture_enable", header: "mcpwm.h".}
## *
##  @brief Disable capture signal
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param cap_sig capture pin, which needs to be disabled
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_capture_disable*(mcpwm_num: mcpwm_unit_t;
                           cap_sig: mcpwm_capture_signal_t): esp_err_t {.
    importc: "mcpwm_capture_disable", header: "mcpwm.h".}
## *
##  @brief Get capture value
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param cap_sig capture pin on which value is to be measured
##
##  @return
##      Captured value
##

proc mcpwm_capture_signal_get_value*(mcpwm_num: mcpwm_unit_t;
                                    cap_sig: mcpwm_capture_signal_t): uint32 {.
    importc: "mcpwm_capture_signal_get_value", header: "mcpwm.h".}
## *
##  @brief Get edge of capture signal
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param cap_sig capture pin of whose edge is to be determined
##
##  @return
##      Capture signal edge: 1 - positive edge, 2 - negtive edge
##

proc mcpwm_capture_signal_get_edge*(mcpwm_num: mcpwm_unit_t;
                                   cap_sig: mcpwm_capture_signal_t): uint32 {.
    importc: "mcpwm_capture_signal_get_edge", header: "mcpwm.h".}
## *
##  @brief Initialize sync submodule
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##  @param sync_sig set the synchronization pin, which needs to be enabled
##  @param phase_val phase value in 1/1000 (for 86.7%, phase_val = 867) which timer moves to on sync signal
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_sync_enable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t;
                       sync_sig: mcpwm_sync_signal_t; phase_val: uint32): esp_err_t {.
    importc: "mcpwm_sync_enable", header: "mcpwm.h".}
## *
##  @brief Disable sync submodule on given timer
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param timer_num set timer number(0-2) of MCPWM, each MCPWM unit has 3 timers
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc mcpwm_sync_disable*(mcpwm_num: mcpwm_unit_t; timer_num: mcpwm_timer_t): esp_err_t {.
    importc: "mcpwm_sync_disable", header: "mcpwm.h".}
## *
##  @brief Register MCPWM interrupt handler, the handler is an ISR.
##         the handler will be attached to the same CPU core that this function is running on.
##
##  @param mcpwm_num set MCPWM unit(0-1)
##  @param fn interrupt handler function.
##  @param arg user-supplied argument passed to the handler function.
##  @param intr_alloc_flags flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. see esp_intr_alloc.h for more info.
##  @param arg parameter for handler function
##  @param handle pointer to return handle. If non-NULL, a handle for the interrupt will
##         be returned here.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Function pointer error.
##

proc mcpwm_isr_register*(mcpwm_num: mcpwm_unit_t; fn: proc (a1: pointer); arg: pointer;
                        intr_alloc_flags: cint; handle: ptr intr_handle_t): esp_err_t {.
    importc: "mcpwm_isr_register", header: "mcpwm.h".}