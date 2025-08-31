##
##  SPDX-FileCopyrightText: 2021-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

##
##  @brief Default type
##
type
  gptimer_clock_source_t* = distinct cint

type

  gptimer_count_direction_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief GPTimer count direction
                              ##
    GPTIMER_COUNT_DOWN,     ## !< Decrease count value
    GPTIMER_COUNT_UP         ## !< Increase count value


##
##  @brief GPTimer specific tasks that supported by the ETM module
##
type

  gptimer_etm_task_type_t* {.size: sizeof(cint).} = enum
    GPTIMER_ETM_TASK_START_COUNT, ## !< Start the counter
    GPTIMER_ETM_TASK_STOP_COUNT, ## !< Stop the counter
    GPTIMER_ETM_TASK_EN_ALARM, ## !< Enable the alarm
    GPTIMER_ETM_TASK_RELOAD, ## !< Reload preset value into counter
    GPTIMER_ETM_TASK_CAPTURE, ## !< Capture current count value into specific register
    GPTIMER_ETM_TASK_MAX   ## !< Maximum number of tasks
##
##  @brief GPTimer specific events that supported by the ETM module
##
type

  gptimer_etm_event_type_t* {.size: sizeof(cint).} = enum
    GPTIMER_ETM_EVENT_ALARM_MATCH, ## !< Count value matches the alarm target value
    GPTIMER_ETM_EVENT_MAX  ## !< Maximum number of events