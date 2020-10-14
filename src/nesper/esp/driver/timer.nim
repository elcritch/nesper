##  Copyright 2010-2016 Espressif Systems (Shanghai) PTE LTD
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

import ../../consts

const
  TIMER_BASE_CLK* = (APB_CLK_FREQ) ## !< Frequency of the clock on the input of the timer groups

## *
##  @brief Selects a Timer-Group out of 2 available groups
##

type
  timer_group_t* {.size: sizeof(cint).} = enum
    TIMER_GROUP_0 = 0,          ## !<Hw timer group 0
    TIMER_GROUP_1 = 1,          ## !<Hw timer group 1
    TIMER_GROUP_MAX


## *
##  @brief Select a hardware timer from timer groups
##

type
  timer_idx_t* {.size: sizeof(cint).} = enum
    TIMER_0 = 0,                ## !<Select timer0 of GROUPx
    TIMER_1 = 1,                ## !<Select timer1 of GROUPx
    TIMER_MAX


## *
##  @brief Decides the direction of counter
##

type
  timer_count_dir_t* {.size: sizeof(cint).} = enum
    TIMER_COUNT_DOWN = 0,       ## !< Descending Count from cnt.high|cnt.low
    TIMER_COUNT_UP = 1,         ## !< Ascending Count from Zero
    TIMER_COUNT_MAX


## *
##  @brief Decides whether timer is on or paused
##

type
  timer_start_t* {.size: sizeof(cint).} = enum
    TIMER_PAUSE = 0,            ## !<Pause timer counter
    TIMER_START = 1             ## !<Start timer counter


## *
##  @brief Decides whether to enable alarm mode
##

type
  timer_alarm_t* {.size: sizeof(cint).} = enum
    TIMER_ALARM_DIS = 0,        ## !< Disable timer alarm
    TIMER_ALARM_EN = 1,         ## !< Enable timer alarm
    TIMER_ALARM_MAX


## *
##  @brief Select interrupt type if running in alarm mode.
##

type
  timer_intr_mode_t* {.size: sizeof(cint).} = enum
    TIMER_INTR_LEVEL = 0,       ## !< Interrupt mode: level mode
                       ## TIMER_INTR_EDGE = 1, /*!< Interrupt mode: edge mode, Not supported Now*/
    TIMER_INTR_MAX


## *
##  @brief Select if Alarm needs to be loaded by software or automatically reload by hardware.
##

type
  timer_autoreload_t* {.size: sizeof(cint).} = enum
    TIMER_AUTORELOAD_DIS = 0,   ## !< Disable auto-reload: hardware will not load counter value after an alarm event
    TIMER_AUTORELOAD_EN = 1,    ## !< Enable auto-reload: hardware will load counter value after an alarm event
    TIMER_AUTORELOAD_MAX


## *
##  @brief Data structure with timer's configuration settings
##

type
  timer_config_t* {.importc: "timer_config_t", header: "timer.h", bycopy.} = object
    alarm_en* {.importc: "alarm_en".}: bool ## !< Timer alarm enable
    counter_en* {.importc: "counter_en".}: bool ## !< Counter enable
    intr_type* {.importc: "intr_type".}: timer_intr_mode_t ## !< Interrupt mode
    counter_dir* {.importc: "counter_dir".}: timer_count_dir_t ## !< Counter direction
    auto_reload* {.importc: "auto_reload".}: bool ## !< Timer auto-reload
    divider* {.importc: "divider".}: uint32 ## !< Counter clock divider. The divider's range is from from 2 to 65536.


## *
##  @brief Interrupt handle, used in order to free the isr after use.
##  Aliases to an int handle for now.
##

type
  timer_isr_handle_t* = intr_handle_t

## *
##  @brief Read the counter value of hardware timer.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param timer_val Pointer to accept timer counter value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_get_counter_value*(group_num: timer_group_t; timer_num: timer_idx_t;
                             timer_val: ptr uint64): esp_err_t {.
    importc: "timer_get_counter_value", header: "timer.h".}
## *
##  @brief Read the counter value of hardware timer, in unit of a given scale.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param time Pointer, type of double*, to accept timer counter value, in seconds.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_get_counter_time_sec*(group_num: timer_group_t; timer_num: timer_idx_t;
                                time: ptr cdouble): esp_err_t {.
    importc: "timer_get_counter_time_sec", header: "timer.h".}
## *
##  @brief Set counter value to hardware timer.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param load_val Counter value to write to the hardware timer.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_counter_value*(group_num: timer_group_t; timer_num: timer_idx_t;
                             load_val: uint64): esp_err_t {.
    importc: "timer_set_counter_value", header: "timer.h".}
## *
##  @brief Start the counter of hardware timer.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_start*(group_num: timer_group_t; timer_num: timer_idx_t): esp_err_t {.
    importc: "timer_start", header: "timer.h".}
## *
##  @brief Pause the counter of hardware timer.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_pause*(group_num: timer_group_t; timer_num: timer_idx_t): esp_err_t {.
    importc: "timer_pause", header: "timer.h".}
## *
##  @brief Set counting mode for hardware timer.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param counter_dir Counting direction of timer, count-up or count-down
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_counter_mode*(group_num: timer_group_t; timer_num: timer_idx_t;
                            counter_dir: timer_count_dir_t): esp_err_t {.
    importc: "timer_set_counter_mode", header: "timer.h".}
## *
##  @brief Enable or disable counter reload function when alarm event occurs.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param reload Counter reload mode.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_auto_reload*(group_num: timer_group_t; timer_num: timer_idx_t;
                           reload: timer_autoreload_t): esp_err_t {.
    importc: "timer_set_auto_reload", header: "timer.h".}
## *
##  @brief Set hardware timer source clock divider. Timer groups clock are divider from APB clock.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param divider Timer clock divider value. The divider's range is from from 2 to 65536.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_divider*(group_num: timer_group_t; timer_num: timer_idx_t;
                       divider: uint32): esp_err_t {.
    importc: "timer_set_divider", header: "timer.h".}
## *
##  @brief Set timer alarm value.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param alarm_value A 64-bit value to set the alarm value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_alarm_value*(group_num: timer_group_t; timer_num: timer_idx_t;
                           alarm_value: uint64): esp_err_t {.
    importc: "timer_set_alarm_value", header: "timer.h".}
## *
##  @brief Get timer alarm value.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param alarm_value Pointer of A 64-bit value to accept the alarm value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_get_alarm_value*(group_num: timer_group_t; timer_num: timer_idx_t;
                           alarm_value: ptr uint64): esp_err_t {.
    importc: "timer_get_alarm_value", header: "timer.h".}
## *
##  @brief Enable or disable generation of timer alarm events.
##
##  @param group_num Timer group, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param alarm_en To enable or disable timer alarm function.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_set_alarm*(group_num: timer_group_t; timer_num: timer_idx_t;
                     alarm_en: timer_alarm_t): esp_err_t {.
    importc: "timer_set_alarm", header: "timer.h".}
## *
##  @brief Register Timer interrupt handler, the handler is an ISR.
##         The handler will be attached to the same CPU core that this function is running on.
##
##  @param group_num Timer group number
##  @param timer_num Timer index of timer group
##  @param fn Interrupt handler function.
##  @param arg Parameter for handler function
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##  @param handle Pointer to return handle. If non-NULL, a handle for the interrupt will
##         be returned here.
##
##  @note If the intr_alloc_flags value ESP_INTR_FLAG_IRAM is set,
##        the handler function must be declared with IRAM_ATTR attribute
##        and can only call functions in IRAM or ROM. It cannot call other timer APIs.
##        Use direct register access to configure timers from inside the ISR in this case.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_isr_register*(group_num: timer_group_t; timer_num: timer_idx_t;
                        fn: proc (a1: pointer) {.cdecl.}; arg: pointer; intr_alloc_flags: cint;
                        handle: ptr timer_isr_handle_t): esp_err_t {.
    importc: "timer_isr_register", header: "timer.h".}
## * @brief Initializes and configure the timer.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param config Pointer to timer initialization parameters.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_init*(group_num: timer_group_t; timer_num: timer_idx_t;
                config: ptr timer_config_t): esp_err_t {.importc: "timer_init",
    header: "timer.h".}
## * @brief Get timer configure value.
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index, 0 for hw_timer[0] & 1 for hw_timer[1]
##  @param config Pointer of struct to accept timer parameters.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_get_config*(group_num: timer_group_t; timer_num: timer_idx_t;
                      config: ptr timer_config_t): esp_err_t {.
    importc: "timer_get_config", header: "timer.h".}
## * @brief Enable timer group interrupt, by enable mask
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param en_mask Timer interrupt enable mask.
##         Use TIMG_T0_INT_ENA_M to enable t0 interrupt
##         Use TIMG_T1_INT_ENA_M to enable t1 interrupt
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_group_intr_enable*(group_num: timer_group_t; en_mask: uint32): esp_err_t {.
    importc: "timer_group_intr_enable", header: "timer.h".}
## * @brief Disable timer group interrupt, by disable mask
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param disable_mask Timer interrupt disable mask.
##         Use TIMG_T0_INT_ENA_M to disable t0 interrupt
##         Use TIMG_T1_INT_ENA_M to disable t1 interrupt
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_group_intr_disable*(group_num: timer_group_t; disable_mask: uint32): esp_err_t {.
    importc: "timer_group_intr_disable", header: "timer.h".}
## * @brief Enable timer interrupt
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_enable_intr*(group_num: timer_group_t; timer_num: timer_idx_t): esp_err_t {.
    importc: "timer_enable_intr", header: "timer.h".}
## * @brief Disable timer interrupt
##
##  @param group_num Timer group number, 0 for TIMERG0 or 1 for TIMERG1
##  @param timer_num Timer index.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc timer_disable_intr*(group_num: timer_group_t; timer_num: timer_idx_t): esp_err_t {.
    importc: "timer_disable_intr", header: "timer.h".}