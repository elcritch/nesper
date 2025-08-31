##
##  SPDX-FileCopyrightText: 2022-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../../consts
import ./timer_types

type

  gptimer_t* {.importc: "gptimer_t", header: "gptimer_types.h", bycopy.} = object

  gptimer_handle_t* = ptr gptimer_t ##
                                    ##  @brief Type of General Purpose Timer handle
                                    ##

  gptimer_alarm_event_data_t* {.importc: "gptimer_alarm_event_data_t",
                                header: "gptimer_types.h", bycopy.} = object ##
                              ##
                              ##  @brief GPTimer alarm event data
                              ##
    count_value* {.importc: "count_value".}: uint64 ##
                              ## !< Current count value
    alarm_value* {.importc: "alarm_value".}: uint64
    ## !< Current alarm value


  gptimer_alarm_cb_t* = proc (timer: gptimer_handle_t;
                              edata: ptr gptimer_alarm_event_data_t;
                              user_ctx: pointer): bool {.cdecl.} ##
                              ##
                              ##  @brief Timer alarm callback prototype
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[in] edata Alarm event data, fed by driver
                              ##  @param[in] user_ctx User data, passed from `gptimer_register_event_callbacks`
                              ##  @return Whether a high priority task has been waken up by this function
                              ##
type

  INNER_C_STRUCT_gptimer_1* {.importc: "gptimer_config_t::no_name",
                              header: "gptimer.h", bycopy.} = object ##
                              ##
                              ##  @brief General Purpose Timer configuration
                              ##
    intr_shared* {.importc: "intr_shared", bitsize: 1.}: uint32 ##
                              ## !< Set true, the timer interrupt number can be shared with other peripherals
    allow_pd* {.importc: "allow_pd", bitsize: 1.}: uint32 ##
                              ## !< If set, driver allows the power domain to be powered off when system enters sleep mode.
                              ##                                               This can save power, but at the expense of more RAM being consumed to save register context.
    backup_before_sleep* {.importc: "backup_before_sleep", bitsize: 1.}: uint32
    ## !< @deprecated, same meaning as allow_pd


  gptimer_config_t* {.importc: "gptimer_config_t", header: "gptimer.h", bycopy.} = object
    clk_src* {.importc: "clk_src".}: gptimer_clock_source_t ##
                              ## !< GPTimer clock source
    direction* {.importc: "direction".}: gptimer_count_direction_t ##
                              ## !< Count direction
    resolution_hz* {.importc: "resolution_hz".}: uint32 ##
                              ## !< Counter resolution (working frequency) in Hz,
                              ##                                               hence, the step size of each count tick equals to (1 / resolution_hz) seconds
    intr_priority* {.importc: "intr_priority".}: cint ##
                              ## !< GPTimer interrupt priority,
                              ##                                               if set to 0, the driver will try to allocate an interrupt with a relative low priority (1,2,3)
    flags* {.importc: "flags".}: INNER_C_STRUCT_gptimer_1
    ## !< GPTimer config flags



proc gptimer_new_timer*(config: ptr gptimer_config_t;
                        ret_timer: ptr gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_new_timer", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Create a new General Purpose Timer, and return the handle
                              ##
                              ##  @note The newly created timer is put in the "init" state.
                              ##
                              ##  @param[in] config GPTimer configuration
                              ##  @param[out] ret_timer Returned timer handle
                              ##  @return
                              ##       - ESP_OK: Create GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Create GPTimer failed because of invalid argument
                              ##       - ESP_ERR_NO_MEM: Create GPTimer failed because out of memory
                              ##       - ESP_ERR_NOT_FOUND: Create GPTimer failed because all hardware timers are used up and no more free one
                              ##       - ESP_FAIL: Create GPTimer failed because of other error
                              ##

proc gptimer_del_timer*(timer: gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_del_timer", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Delete the GPTimer handle
                              ##
                              ##  @note A timer must be in the "init" state before it can be deleted.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @return
                              ##       - ESP_OK: Delete GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Delete GPTimer failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Delete GPTimer failed because the timer is not in init state
                              ##       - ESP_FAIL: Delete GPTimer failed because of other error
                              ##

proc gptimer_set_raw_count*(timer: gptimer_handle_t; value: uint64): esp_err_t {.
    cdecl, importc: "gptimer_set_raw_count", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Set GPTimer raw count value
                              ##
                              ##  @note When updating the raw count of an active timer, the timer will immediately start counting from the new value.
                              ##  @note This function is allowed to run within ISR context
                              ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##        makes it possible to execute even when the Flash Cache is disabled.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[in] value Count value to be set
                              ##  @return
                              ##       - ESP_OK: Set GPTimer raw count value successfully
                              ##       - ESP_ERR_INVALID_ARG: Set GPTimer raw count value failed because of invalid argument
                              ##       - ESP_FAIL: Set GPTimer raw count value failed because of other error
                              ##

proc gptimer_get_raw_count*(timer: gptimer_handle_t; value: ptr uint64): esp_err_t {.
    cdecl, importc: "gptimer_get_raw_count", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Get GPTimer raw count value
                              ##
                              ##  @note This function will trigger a software capture event and then return the captured count value.
                              ##  @note With the raw count value and the resolution returned from `gptimer_get_resolution`, you can convert the count value into seconds.
                              ##  @note This function is allowed to run within ISR context
                              ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##        makes it possible to execute even when the Flash Cache is disabled.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[out] value Returned GPTimer count value
                              ##  @return
                              ##       - ESP_OK: Get GPTimer raw count value successfully
                              ##       - ESP_ERR_INVALID_ARG: Get GPTimer raw count value failed because of invalid argument
                              ##       - ESP_FAIL: Get GPTimer raw count value failed because of other error
                              ##

proc gptimer_get_resolution*(timer: gptimer_handle_t; out_resolution: ptr uint32): esp_err_t {.
    cdecl, importc: "gptimer_get_resolution", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Return the real resolution of the timer
                              ##
                              ##  @note usually the timer resolution is same as what you configured in the `gptimer_config_t::resolution_hz`,
                              ##        but some unstable clock source (e.g. RC_FAST) will do a calibration, the real resolution can be different from the configured one.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[out] out_resolution Returned timer resolution, in Hz
                              ##  @return
                              ##       - ESP_OK: Get GPTimer resolution successfully
                              ##       - ESP_ERR_INVALID_ARG: Get GPTimer resolution failed because of invalid argument
                              ##       - ESP_FAIL: Get GPTimer resolution failed because of other error
                              ##

proc gptimer_get_captured_count*(timer: gptimer_handle_t; value: ptr uint64): esp_err_t {.
    cdecl, importc: "gptimer_get_captured_count", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Get GPTimer captured count value
                              ##
                              ##  @note Different from `gptimer_get_raw_count`, this function won't trigger a software capture event. It just returns the last captured count value.
                              ##        It's especially useful when the capture has already been triggered by an external event and you want to read the captured value.
                              ##  @note This function is allowed to run within ISR context
                              ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##        makes it possible to execute even when the Flash Cache is disabled.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[out] value Returned captured count value
                              ##  @return
                              ##       - ESP_OK: Get GPTimer captured count value successfully
                              ##       - ESP_ERR_INVALID_ARG: Get GPTimer captured count value failed because of invalid argument
                              ##       - ESP_FAIL: Get GPTimer captured count value failed because of other error
                              ##
type

  gptimer_event_callbacks_t* {.importc: "gptimer_event_callbacks_t",
                               header: "gptimer.h", bycopy.} = object ##
                              ##
                              ##  @brief Group of supported GPTimer callbacks
                              ##  @note The callbacks are all running under ISR environment
                              ##  @note When CONFIG_GPTIMER_ISR_CACHE_SAFE is enabled, the callback itself and functions called by it should be placed in IRAM.
                              ##
    on_alarm* {.importc: "on_alarm".}: gptimer_alarm_cb_t
    ## !< Timer alarm callback



proc gptimer_register_event_callbacks*(timer: gptimer_handle_t;
                                       cbs: ptr gptimer_event_callbacks_t;
                                       user_data: pointer): esp_err_t {.cdecl,
    importc: "gptimer_register_event_callbacks", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Set callbacks for GPTimer
                              ##
                              ##  @note User registered callbacks are expected to be runnable within ISR context
                              ##  @note The first call to this function needs to be before the call to `gptimer_enable`
                              ##  @note User can deregister a previously registered callback by calling this function and setting the callback member in the `cbs` structure to NULL.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[in] cbs Group of callback functions
                              ##  @param[in] user_data User data, which will be passed to callback functions directly
                              ##  @return
                              ##       - ESP_OK: Set event callbacks successfully
                              ##       - ESP_ERR_INVALID_ARG: Set event callbacks failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Set event callbacks failed because the timer is not in init state
                              ##       - ESP_FAIL: Set event callbacks failed because of other error
                              ##
type

  INNER_C_STRUCT_gptimer_3* {.importc: "gptimer_alarm_config_t::no_name",
                              header: "gptimer.h", bycopy.} = object ##
                              ##
                              ##  @brief General Purpose Timer alarm configuration
                              ##
    auto_reload_on_alarm* {.importc: "auto_reload_on_alarm", bitsize: 1.}: uint32
    ## !< Reload the count value by hardware, immediately at the alarm event


  gptimer_alarm_config_t* {.importc: "gptimer_alarm_config_t",
                            header: "gptimer.h", bycopy.} = object
    alarm_count* {.importc: "alarm_count".}: uint64 ##
                              ## !< Alarm target count value
    reload_count* {.importc: "reload_count".}: uint64 ##
                              ## !< Alarm reload count value, effect only when `auto_reload_on_alarm` is set to true
    flags* {.importc: "flags".}: INNER_C_STRUCT_gptimer_3
    ## !< Alarm config flags



proc gptimer_set_alarm_action*(timer: gptimer_handle_t;
                               config: ptr gptimer_alarm_config_t): esp_err_t {.
    cdecl, importc: "gptimer_set_alarm_action", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Set alarm event actions for GPTimer.
                              ##
                              ##  @note This function is allowed to run within ISR context, so you can update new alarm action immediately in any ISR callback.
                              ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##        makes it possible to execute even when the Flash Cache is disabled.
                              ##        In this case, please also ensure the `gptimer_alarm_config_t` instance is placed in the static data section
                              ##        instead of in the read-only data section. e.g.: `static gptimer_alarm_config_t alarm_config = { ... };`
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @param[in] config Alarm configuration, especially, set config to NULL means disabling the alarm function
                              ##  @return
                              ##       - ESP_OK: Set alarm action for GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Set alarm action for GPTimer failed because of invalid argument
                              ##       - ESP_FAIL: Set alarm action for GPTimer failed because of other error
                              ##

proc gptimer_enable*(timer: gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_enable", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Enable GPTimer
                              ##
                              ##  @note This function will transit the timer state from "init" to "enable".
                              ##  @note This function will enable the interrupt service, if it's lazy installed in `gptimer_register_event_callbacks`.
                              ##  @note This function will acquire a PM lock, if a specific source clock (e.g. APB) is selected in the `gptimer_config_t`, while `CONFIG_PM_ENABLE` is enabled.
                              ##  @note Enable a timer doesn't mean to start it. See also `gptimer_start` for how to make the timer start counting.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @return
                              ##       - ESP_OK: Enable GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Enable GPTimer failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Enable GPTimer failed because the timer is already enabled
                              ##       - ESP_FAIL: Enable GPTimer failed because of other error
                              ##

proc gptimer_disable*(timer: gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_disable", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Disable GPTimer
                              ##
                              ##  @note This function will transit the timer state from "enable" to "init".
                              ##  @note This function will disable the interrupt service if it's installed.
                              ##  @note This function will release the PM lock if it's acquired in the `gptimer_enable`.
                              ##  @note Disable a timer doesn't mean to stop it. See also `gptimer_stop` for how to make the timer stop counting.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @return
                              ##       - ESP_OK: Disable GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Disable GPTimer failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Disable GPTimer failed because the timer is not enabled yet
                              ##       - ESP_FAIL: Disable GPTimer failed because of other error
                              ##

proc gptimer_start*(timer: gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_start", header: "gptimer.h".}
  ##
                              ##
                              ##  @brief Start GPTimer (internal counter starts counting)
                              ##
                              ##  @note This function will transit the timer state from "enable" to "run".
                              ##  @note This function is allowed to run within ISR context
                              ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                              ##        makes it possible to execute even when the Flash Cache is disabled.
                              ##
                              ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                              ##  @return
                              ##       - ESP_OK: Start GPTimer successfully
                              ##       - ESP_ERR_INVALID_ARG: Start GPTimer failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Start GPTimer failed because the timer is not enabled or is already in running
                              ##       - ESP_FAIL: Start GPTimer failed because of other error
                              ##

proc gptimer_stop*(timer: gptimer_handle_t): esp_err_t {.cdecl,
    importc: "gptimer_stop", header: "gptimer.h".}
  ##
                                                  ##  @brief Stop GPTimer (internal counter stops counting)
                                                  ##
                                                  ##  @note This function will transit the timer state from "run" to "enable".
                                                  ##  @note This function is allowed to run within ISR context
                                                  ##  @note If `CONFIG_GPTIMER_CTRL_FUNC_IN_IRAM` is enabled, this function will be placed in the IRAM by linker,
                                                  ##        makes it possible to execute even when the Flash Cache is disabled.
                                                  ##
                                                  ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                                                  ##  @return
                                                  ##       - ESP_OK: Stop GPTimer successfully
                                                  ##       - ESP_ERR_INVALID_ARG: Stop GPTimer failed because of invalid argument
                                                  ##       - ESP_ERR_INVALID_STATE: Stop GPTimer failed because the timer is not in running.
                                                  ##       - ESP_FAIL: Stop GPTimer failed because of other error
                                                  ## 

##
##  @brief GPTimer ETM event configuration
##
type

  gptimer_etm_event_config_t* {.importc: "gptimer_etm_event_config_t",
                                header: "gptimer_etm.h", bycopy.} = object
    event_type* {.importc: "event_type".}: gptimer_etm_event_type_t
    ## !< GPTimer ETM event type


proc gptimer_new_etm_event*(timer: gptimer_handle_t;
                            config: ptr gptimer_etm_event_config_t;
                            out_event: ptr esp_etm_event_handle_t): esp_err_t {.
    cdecl, importc: "gptimer_new_etm_event", header: "gptimer_etm.h".}
  ##
                            ##
                            ##  @brief Get the ETM event for GPTimer
                            ##
                            ##  @note The created ETM event object can be deleted later by calling `esp_etm_del_event`
                            ##
                            ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                            ##  @param[in] config GPTimer ETM event configuration
                            ##  @param[out] out_event Returned ETM event handle
                            ##  @return
                            ##       - ESP_OK: Get ETM event successfully
                            ##       - ESP_ERR_INVALID_ARG: Get ETM event failed because of invalid argument
                            ##       - ESP_FAIL: Get ETM event failed because of other error
                            ##
##
##  @brief GPTimer ETM task configuration
##
type

  gptimer_etm_task_config_t* {.importc: "gptimer_etm_task_config_t",
                                header: "gptimer_etm.h", bycopy.} = object
    task_type* {.importc: "task_type".}: gptimer_etm_task_type_t
    ## !< GPTimer ETM task type


proc gptimer_new_etm_task*(timer: gptimer_handle_t;
                            config: ptr gptimer_etm_task_config_t;
                            out_task: ptr esp_etm_task_handle_t): esp_err_t {.
    cdecl, importc: "gptimer_new_etm_task", header: "gptimer_etm.h".}
  ##
                            ##
                            ##  @brief Get the ETM task for GPTimer
                            ##
                            ##  @note The created ETM task object can be deleted later by calling `esp_etm_del_task`
                            ##
                            ##  @param[in] timer Timer handle created by `gptimer_new_timer`
                            ##  @param[in] config GPTimer ETM task configuration
                            ##  @param[out] out_task Returned ETM task handle
                            ##  @return
                            ##       - ESP_OK: Get ETM task successfully
                            ##       - ESP_ERR_INVALID_ARG: Get ETM task failed because of invalid argument
                            ##       - ESP_FAIL: Get ETM task failed because of other error

