##
##  SPDX-FileCopyrightText: 2022-2024 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

import ../../consts

type

  esp_etm_channel_t* {.importc: "esp_etm_channel_t", header: "esp_etm.h", incompleteStruct, bycopy.} = object
  esp_etm_event_t* {.importc: "esp_etm_event_t", header: "esp_etm.h", incompleteStruct, bycopy.} = object
  esp_etm_task_t* {.importc: "esp_etm_task_t", header: "esp_etm.h", incompleteStruct, bycopy.} = object

  esp_etm_channel_handle_t* = ptr esp_etm_channel_t ##
                              ##
                              ##  @brief ETM channel handle
                              ##

  esp_etm_event_handle_t* = ptr esp_etm_event_t ##
                                                ##  @brief ETM event handle
                                                ##

  esp_etm_task_handle_t* = ptr esp_etm_task_t ##
                                              ##  @brief ETM task handle
                                              ##

  etm_chan_flags_esp_etm_1* {.importc: "esp_etm_channel_config_t::no_name",
                              header: "esp_etm.h", bycopy.} = object ##
                              ##
                              ##  @brief ETM channel configuration
                              ##
    allow_pd* {.importc: "allow_pd", bitsize: 1.}: uint32
    ## !< If set, driver allows the power domain to be powered off when system enters sleep mode.
    ##                                     This can save power, but at the expense of more RAM being consumed to save register context.


  esp_etm_channel_config_t* {.importc: "esp_etm_channel_config_t",
                              header: "esp_etm.h", bycopy.} = object
    flags* {.importc: "flags".}: etm_chan_flags_esp_etm_1 ##
                              ##  Extra configuration flags for ETM channel
    ## !< ETM channel flags



proc esp_etm_new_channel*(config: ptr esp_etm_channel_config_t;
                          ret_chan: ptr esp_etm_channel_handle_t): esp_err_t {.
    cdecl, importc: "esp_etm_new_channel", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Allocate an ETM channel
                              ##
                              ##  @note The channel can later be freed by `esp_etm_del_channel`
                              ##
                              ##  @param[in] config ETM channel configuration
                              ##  @param[out] ret_chan Returned ETM channel handle
                              ##  @return
                              ##       - ESP_OK: Allocate ETM channel successfully
                              ##       - ESP_ERR_INVALID_ARG: Allocate ETM channel failed because of invalid argument
                              ##       - ESP_ERR_NO_MEM: Allocate ETM channel failed because of out of memory
                              ##       - ESP_ERR_NOT_FOUND: Allocate ETM channel failed because all channels are used up and no more free one
                              ##       - ESP_FAIL: Allocate ETM channel failed because of other reasons
                              ##

proc esp_etm_del_channel*(chan: esp_etm_channel_handle_t): esp_err_t {.cdecl,
    importc: "esp_etm_del_channel", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Delete an ETM channel
                              ##
                              ##  @param[in] chan ETM channel handle that created by `esp_etm_new_channel`
                              ##  @return
                              ##       - ESP_OK: Delete ETM channel successfully
                              ##       - ESP_ERR_INVALID_ARG: Delete ETM channel failed because of invalid argument
                              ##       - ESP_FAIL: Delete ETM channel failed because of other reasons
                              ##

proc esp_etm_channel_enable*(chan: esp_etm_channel_handle_t): esp_err_t {.cdecl,
    importc: "esp_etm_channel_enable", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Enable ETM channel
                              ##
                              ##  @note This function will transit the channel state from init to enable.
                              ##
                              ##  @param[in] chan ETM channel handle that created by `esp_etm_new_channel`
                              ##  @return
                              ##       - ESP_OK: Enable ETM channel successfully
                              ##       - ESP_ERR_INVALID_ARG: Enable ETM channel failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Enable ETM channel failed because the channel has been enabled already
                              ##       - ESP_FAIL: Enable ETM channel failed because of other reasons
                              ##

proc esp_etm_channel_disable*(chan: esp_etm_channel_handle_t): esp_err_t {.
    cdecl, importc: "esp_etm_channel_disable", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Disable ETM channel
                              ##
                              ##  @note This function will transit the channel state from enable to init.
                              ##
                              ##  @param[in] chan ETM channel handle that created by `esp_etm_new_channel`
                              ##  @return
                              ##       - ESP_OK: Disable ETM channel successfully
                              ##       - ESP_ERR_INVALID_ARG: Disable ETM channel failed because of invalid argument
                              ##       - ESP_ERR_INVALID_STATE: Disable ETM channel failed because the channel is not enabled yet
                              ##       - ESP_FAIL: Disable ETM channel failed because of other reasons
                              ##

proc esp_etm_channel_connect*(chan: esp_etm_channel_handle_t;
                              event: esp_etm_event_handle_t;
                              task: esp_etm_task_handle_t): esp_err_t {.cdecl,
    importc: "esp_etm_channel_connect", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Connect an ETM event to an ETM task via a previously allocated ETM channel
                              ##
                              ##  @note Setting the ETM event/task handle to NULL means to disconnect the channel from any event/task
                              ##
                              ##  @param[in] chan ETM channel handle that created by `esp_etm_new_channel`
                              ##  @param[in] event ETM event handle obtained from a driver/peripheral, e.g. `xxx_new_etm_event`
                              ##  @param[in] task ETM task handle obtained from a driver/peripheral, e.g. `xxx_new_etm_task`
                              ##  @return
                              ##       - ESP_OK: Connect ETM event and task to the channel successfully
                              ##       - ESP_ERR_INVALID_ARG: Connect ETM event and task to the channel failed because of invalid argument
                              ##       - ESP_FAIL: Connect ETM event and task to the channel failed because of other reasons
                              ##

proc esp_etm_del_event*(event: esp_etm_event_handle_t): esp_err_t {.cdecl,
    importc: "esp_etm_del_event", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Delete ETM event
                              ##
                              ##  @note Although the ETM event comes from various peripherals, we provide the same user API to delete the event handle seamlessly.
                              ##
                              ##  @param[in] event ETM event handle obtained from a driver/peripheral, e.g. `xxx_new_etm_event`
                              ##  @return
                              ##       - ESP_OK: Delete ETM event successfully
                              ##       - ESP_ERR_INVALID_ARG: Delete ETM event failed because of invalid argument
                              ##       - ESP_FAIL: Delete ETM event failed because of other reasons
                              ##

proc esp_etm_del_task*(task: esp_etm_task_handle_t): esp_err_t {.cdecl,
    importc: "esp_etm_del_task", header: "esp_etm.h".}
  ##
                              ##
                              ##  @brief Delete ETM task
                              ##
                              ##  @note Although the ETM task comes from various peripherals, we provide the same user API to delete the task handle seamlessly.
                              ##
                              ##  @param[in] task ETM task handle obtained from a driver/peripheral, e.g. `xxx_new_etm_task`
                              ##  @return
                              ##       - ESP_OK: Delete ETM task successfully
                              ##       - ESP_ERR_INVALID_ARG: Delete ETM task failed because of invalid argument
                              ##       - ESP_FAIL: Delete ETM task failed because of other reasons
                              ##

proc esp_etm_dump*(out_stream: ptr FILE): esp_err_t {.cdecl,
    importc: "esp_etm_dump", header: "esp_etm.h".}
  ##
                                                  ##  @brief Dump ETM channel usages to the given IO stream
                                                  ##
                                                  ##  @param[in] out_stream IO stream (e.g. stdout)
                                                  ##  @return
                                                  ##       - ESP_OK: Dump ETM channel usages successfully
                                                  ##       - ESP_ERR_INVALID_ARG: Dump ETM channel usages failed because of invalid argument
                                                  ##       - ESP_FAIL: Dump ETM channel usages failed because of other reasons
                                                  ## 