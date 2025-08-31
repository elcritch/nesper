##
##  SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

when defined(SOC_TIMER_SUPPORT_ETM):
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
                              ## 