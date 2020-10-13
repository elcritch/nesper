##  Copyright 2017 Espressif Systems (Shanghai) PTE LTD
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

## *
##  @file esp_timer.h
##  @brief microsecond-precision 64-bit timer API, replacement for ets_timer
##
##  esp_timer APIs allow components to receive callbacks when a hardware timer
##  reaches certain value. The timer provides microsecond accuracy and
##  up to 64 bit range. Note that while the timer itself provides microsecond
##  accuracy, callbacks are dispatched from an auxiliary task. Some time is
##  needed to notify this task from timer ISR, and then to invoke the callback.
##  If more than one callback needs to be dispatched at any particular time,
##  each subsequent callback will be dispatched only when the previous callback
##  returns. Therefore, callbacks should not do much work; instead, they should
##  use RTOS notification mechanisms (queues, semaphores, event groups, etc.) to
##  pass information to other tasks.
##
##  To be implemented: it should be possible to request the callback to be called
##  directly from the ISR. This reduces the latency, but has potential impact on
##  all other callbacks which need to be dispatched. This option should only be
##  used for simple callback functions, which do not take longer than a few
##  microseconds to run.
##
##  Implementation note: on the ESP32, esp_timer APIs use the "legacy" FRC2
##  timer. Timer callbacks are called from a task running on the PRO CPU.
##

import ../consts

## *
##  @brief Timer callback function type
##  @param arg pointer to opaque user-specific data
##

type
  esp_timer_cb_t* = proc (arg: pointer) {.cdecl.}

type
  INNER_C_UNION_esp_timer_55* {.importc: "no_name", header: "esp_timer.h", bycopy, union.} = object
    callback* {.importc: "callback".}: esp_timer_cb_t
    event_id* {.importc: "event_id".}: uint32

  INNER_C_STRUCT_esp_timer_64* {.importc: "no_name", header: "esp_timer.h", bycopy.} = object
    le_next* {.importc: "le_next".}: ptr esp_timer ##  next element
    le_prev* {.importc: "le_prev".}: ptr ptr esp_timer ##  address of previous next element

  esp_timer* {.importc: "esp_timer", header: "esp_timer.h", bycopy.} = object
    alarm* {.importc: "alarm".}: uint64
    period* {.importc: "period".}: uint64
    ano_esp_timer_57* {.importc: "ano_esp_timer_57".}: INNER_C_UNION_esp_timer_55
    arg* {.importc: "arg".}: pointer
    name* {.importc: "name".}: cstring
    times_triggered* {.importc: "times_triggered".}: csize_t
    times_armed* {.importc: "times_armed".}: csize_t
    total_callback_run_time* {.importc: "total_callback_run_time".}: uint64
    list_entry* {.importc: "list_entry".}: INNER_C_STRUCT_esp_timer_64


## *
##  @brief Opaque type representing a single esp_timer
##

type
  esp_timer_handle_t* = ptr esp_timer

## *
##  @brief Method for dispatching timer callback
##

type
  esp_timer_dispatch_t* {.size: sizeof(cint).} = enum
    ESP_TIMER_TASK ## !< Callback is called from timer task
                  ##  Not supported for now, provision to allow callbacks to run directly
                  ##  from an ISR:
                  ##
                  ##         ESP_TIMER_ISR,      //!< Callback is called from timer ISR
                  ##
                  ##


## *
##  @brief Timer configuration passed to esp_timer_create
##

type
  esp_timer_create_args_t* {.importc: "esp_timer_create_args_t",
                            header: "esp_timer.h", bycopy.} = object
    callback* {.importc: "callback".}: esp_timer_cb_t ## !< Function to call when timer expires
    arg* {.importc: "arg".}: pointer ## !< Argument to pass to the callback
    dispatch_method* {.importc: "dispatch_method".}: esp_timer_dispatch_t ## !< Call the callback from task or from ISR
    name* {.importc: "name".}: cstring ## !< Timer name, used in esp_timer_dump function


## *
##  @brief Initialize esp_timer library
##
##  @note This function is called from startup code. Applications do not need
##  to call this function before using other esp_timer APIs.
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_NO_MEM if allocation has failed
##       - ESP_ERR_INVALID_STATE if already initialized
##       - other errors from interrupt allocator
##

proc esp_timer_init*(): esp_err_t {.importc: "esp_timer_init", header: "esp_timer.h".}


## *
##  @brief De-initialize esp_timer library
##
##  @note Normally this function should not be called from applications
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_STATE if not yet initialized
##

proc esp_timer_deinit*(): esp_err_t {.importc: "esp_timer_deinit",
                                   header: "esp_timer.h".}


## *
##  @brief Create an esp_timer instance
##
##  @note When done using the timer, delete it with esp_timer_delete function.
##
##  @param create_args   Pointer to a structure with timer creation arguments.
##                       Not saved by the library, can be allocated on the stack.
##  @param[out] out_handle  Output, pointer to esp_timer_handle_t variable which
##                          will hold the created timer handle.
##
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if some of the create_args are not valid
##       - ESP_ERR_INVALID_STATE if esp_timer library is not initialized yet
##       - ESP_ERR_NO_MEM if memory allocation fails
##

proc esp_timer_create*(create_args: ptr esp_timer_create_args_t;
                      out_handle: ptr esp_timer_handle_t): esp_err_t {.
    importc: "esp_timer_create", header: "esp_timer.h".}
## *
##  @brief Start one-shot timer
##
##  Timer should not be running when this function is called.
##
##  @param timer timer handle created using esp_timer_create
##  @param timeout_us timer timeout, in microseconds relative to the current moment
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if the handle is invalid
##       - ESP_ERR_INVALID_STATE if the timer is already running
##

proc esp_timer_start_once*(timer: esp_timer_handle_t; timeout_us: uint64): esp_err_t {.
    importc: "esp_timer_start_once", header: "esp_timer.h".}
## *
##  @brief Start a periodic timer
##
##  Timer should not be running when this function is called. This function will
##  start the timer which will trigger every 'period' microseconds.
##
##  @param timer timer handle created using esp_timer_create
##  @param period timer period, in microseconds
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_ARG if the handle is invalid
##       - ESP_ERR_INVALID_STATE if the timer is already running
##

proc esp_timer_start_periodic*(timer: esp_timer_handle_t; period: uint64): esp_err_t {.
    importc: "esp_timer_start_periodic", header: "esp_timer.h".}
## *
##  @brief Stop the timer
##
##  This function stops the timer previously started using esp_timer_start_once
##  or esp_timer_start_periodic.
##
##  @param timer timer handle created using esp_timer_create
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_STATE if the timer is not running
##

proc esp_timer_stop*(timer: esp_timer_handle_t): esp_err_t {.
    importc: "esp_timer_stop", header: "esp_timer.h".}
## *
##  @brief Delete an esp_timer instance
##
##  The timer must be stopped before deleting. A one-shot timer which has expired
##  does not need to be stopped.
##
##  @param timer timer handle allocated using esp_timer_create
##  @return
##       - ESP_OK on success
##       - ESP_ERR_INVALID_STATE if the timer is not running
##

proc esp_timer_delete*(timer: esp_timer_handle_t): esp_err_t {.
    importc: "esp_timer_delete", header: "esp_timer.h".}
## *
##  @brief Get time in microseconds since boot
##  @return number of microseconds since esp_timer_init was called (this normally
##           happens early during application startup).
##

proc esp_timer_get_time*(): int64 {.importc: "esp_timer_get_time",
                                   header: "esp_timer.h".}
## *
##  @brief Get the timestamp when the next timeout is expected to occur
##  @return Timestamp of the nearest timer event, in microseconds.
##          The timebase is the same as for the values returned by esp_timer_get_time.
##

proc esp_timer_get_next_alarm*(): int64 {.importc: "esp_timer_get_next_alarm",
    header: "esp_timer.h".}
## *
##  @brief Dump the list of timers to a stream
##
##  If CONFIG_ESP_TIMER_PROFILING option is enabled, this prints the list of all
##  the existing timers. Otherwise, only the list active timers is printed.
##
##  The format is:
##
##    name  period  alarm  times_armed  times_triggered  total_callback_run_time
##
##  where:
##
##  name — timer name (if CONFIG_ESP_TIMER_PROFILING is defined), or timer pointer
##  period — period of timer, in microseconds, or 0 for one-shot timer
##  alarm - time of the next alarm, in microseconds since boot, or 0 if the timer
##          is not started
##
##  The following fields are printed if CONFIG_ESP_TIMER_PROFILING is defined:
##
##  times_armed — number of times the timer was armed via esp_timer_start_X
##  times_triggered - number of times the callback was called
##  total_callback_run_time - total time taken by callback to execute, across all calls
##
##  @param stream stream (such as stdout) to dump the information to
##  @return
##       - ESP_OK on success
##       - ESP_ERR_NO_MEM if can not allocate temporary buffer for the output
##

proc esp_timer_dump*(stream: ptr FILE): esp_err_t {.importc: "esp_timer_dump",
    header: "esp_timer.h".}