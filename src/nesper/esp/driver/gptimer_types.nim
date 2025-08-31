##
##  SPDX-FileCopyrightText: 2022-2023 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

type

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
