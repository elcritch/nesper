##
##  SPDX-FileCopyrightText: 2020-2022 Espressif Systems (Shanghai) CO LTD
##
##  SPDX-License-Identifier: Apache-2.0
##

type

  tinyusb_cdcacm_itf_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief CDC ports available to setup
                              ##
    TINYUSB_CDC_ACM_0 = 0x0, TINYUSB_CDC_ACM_1, TINYUSB_CDC_ACM_MAX


type

  cdcacm_event_rx_wanted_char_data_t* {.importc: "cdcacm_event_rx_wanted_char_data_t",
                                        header: "tusb_cdc_acm.h", bycopy.} = object ##
                              ##  Callbacks and events
                              ## ********************************************************************
                              ##
                              ##  @brief Data provided to the input of the `callback_rx_wanted_char` callback
                              ##
    wanted_char* {.importc: "wanted_char".}: char
    ## !< Wanted character


  cdcacm_event_line_state_changed_data_t* {.
      importc: "cdcacm_event_line_state_changed_data_t",
      header: "tusb_cdc_acm.h", bycopy.} = object ##
                              ##
                              ##  @brief Data provided to the input of the `callback_line_state_changed` callback
                              ##
    dtr* {.importc: "dtr".}: bool ## !< Data Terminal Ready (DTR) line state
    rts* {.importc: "rts".}: bool
    ## !< Request To Send (RTS) line state


  cdcacm_event_line_coding_changed_data_t* {.
      importc: "cdcacm_event_line_coding_changed_data_t",
      header: "tusb_cdc_acm.h", bycopy.} = object ##
                              ##
                              ##  @brief Data provided to the input of the `line_coding_changed` callback
                              ##
    p_line_coding* {.importc: "p_line_coding".}: ptr cdc_line_coding_t
    ## !< New line coding value


  cdcacm_event_type_t* {.size: sizeof(cint).} = enum ##
                              ##
                              ##  @brief Types of CDC ACM events
                              ##
    CDC_EVENT_RX, CDC_EVENT_RX_WANTED_CHAR, CDC_EVENT_LINE_STATE_CHANGED,
    CDC_EVENT_LINE_CODING_CHANGED


type

  cdcacm_event_t* {.importc: "cdcacm_event_t", header: "tusb_cdc_acm.h", bycopy.} = object ##
                              ##
                              ##  @brief Describes an event passing to the input of a callbacks
                              ##
    `type`* {.importc: "type".}: cdcacm_event_type_t ##
                              ## !< Event type
    rx_wanted_char_data* {.importc: "rx_wanted_char_data".}: cdcacm_event_rx_wanted_char_data_t ##
                              ## !< Data input of the `callback_rx_wanted_char` callback
    line_state_changed_data* {.importc: "line_state_changed_data".}: cdcacm_event_line_state_changed_data_t ##
                              ## !< Data input of the `callback_line_state_changed` callback
    line_coding_changed_data* {.importc: "line_coding_changed_data".}: cdcacm_event_line_coding_changed_data_t
    ## !< Data input of the `line_coding_changed` callback


  tusb_cdcacm_callback_t* = proc (itf: cint; event: ptr cdcacm_event_t) {.cdecl.} ##
                              ##
                              ##  @brief CDC-ACM callback type
                              ##

  tinyusb_config_cdcacm_t* {.importc: "tinyusb_config_cdcacm_t",
                             header: "tusb_cdc_acm.h", bycopy.} = object ##
                              ## ********************************************************************* Callbacks and events
                              ##  Other structs
                              ## ********************************************************************
                              ##
                              ##  @brief Configuration structure for CDC-ACM
                              ##
    usb_dev* {.importc: "usb_dev".}: tinyusb_usbdev_t ##
                              ## !< Usb device to set up
    cdc_port* {.importc: "cdc_port".}: tinyusb_cdcacm_itf_t ##
                              ## !< CDC port
    rx_unread_buf_sz* {.importc: "rx_unread_buf_sz".}: csize_t ##
                              ## !< Amount of data that can be passed to the ACM at once
    callback_rx* {.importc: "callback_rx".}: tusb_cdcacm_callback_t ##
                              ## !< Pointer to the function with the `tusb_cdcacm_callback_t` type that will be handled as a callback
    callback_rx_wanted_char* {.importc: "callback_rx_wanted_char".}: tusb_cdcacm_callback_t ##
                              ## !< Pointer to the function with the `tusb_cdcacm_callback_t` type that will be handled as a callback
    callback_line_state_changed* {.importc: "callback_line_state_changed".}: tusb_cdcacm_callback_t ##
                              ## !< Pointer to the function with the `tusb_cdcacm_callback_t` type that will be handled as a callback
    callback_line_coding_changed* {.importc: "callback_line_coding_changed".}: tusb_cdcacm_callback_t
    ## !< Pointer to the function with the `tusb_cdcacm_callback_t` type that will be handled as a callback



proc tusb_cdc_acm_init*(cfg: ptr tinyusb_config_cdcacm_t): esp_err_t {.cdecl,
    importc: "tusb_cdc_acm_init", header: "tusb_cdc_acm.h".}
  ##
                              ## ********************************************************************* Other structs
                              ##  Public functions
                              ## ********************************************************************
                              ##
                              ##  @brief Initialize CDC ACM. Initialization will be finished with
                              ##           the `tud_cdc_line_state_cb` callback
                              ##
                              ##  @param cfg - init configuration structure
                              ##  @return esp_err_t
                              ##

proc tinyusb_cdcacm_register_callback*(itf: tinyusb_cdcacm_itf_t;
                                       event_type: cdcacm_event_type_t;
                                       callback: tusb_cdcacm_callback_t): esp_err_t {.
    cdecl, importc: "tinyusb_cdcacm_register_callback", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Register a callback invoking on CDC event. If the callback had been
                              ##         already registered, it will be overwritten
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param event_type - type of registered event for a callback
                              ##  @param callback  - callback function
                              ##  @return esp_err_t - ESP_OK or ESP_ERR_INVALID_ARG
                              ##

proc tinyusb_cdcacm_unregister_callback*(itf: tinyusb_cdcacm_itf_t;
    event_type: cdcacm_event_type_t): esp_err_t {.cdecl,
    importc: "tinyusb_cdcacm_unregister_callback", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Unregister a callback invoking on CDC event.
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param event_type - type of registered event for a callback
                              ##  @return esp_err_t - ESP_OK or ESP_ERR_INVALID_ARG
                              ##

proc tinyusb_cdcacm_write_queue_char*(itf: tinyusb_cdcacm_itf_t; ch: char): csize_t {.
    cdecl, importc: "tinyusb_cdcacm_write_queue_char", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Sent one character to a write buffer
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param ch - character to send
                              ##  @return size_t - amount of queued bytes
                              ##

proc tinyusb_cdcacm_write_queue*(itf: tinyusb_cdcacm_itf_t; in_buf: ptr uint8;
                                 in_size: csize_t): csize_t {.cdecl,
    importc: "tinyusb_cdcacm_write_queue", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Write data to write buffer from a byte array
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param in_buf - a source array
                              ##  @param in_size - size to write from arr_src
                              ##  @return size_t - amount of queued bytes
                              ##

proc tinyusb_cdcacm_write_flush*(itf: tinyusb_cdcacm_itf_t;
                                 timeout_ticks: uint32): esp_err_t {.cdecl,
    importc: "tinyusb_cdcacm_write_flush", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Send all data from a write buffer. Use `tinyusb_cdcacm_write_queue` to add data to the buffer.
                              ##
                              ##         WARNING! TinyUSB can block output Endpoint for several RX callbacks, after will do additional flush
                              ##         after the each trasfer. That can leads to the situation when you requested a flush, but it will fail until
                              ##         ont of the next callbacks ends.
                              ##         SO USING OF THE FLUSH WITH TIMEOUTS IN CALLBACKS IS NOT RECOMENDED - YOU CAN GET A LOCK FOR THE TIMEOUT
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param timeout_ticks - waiting until flush will be considered as failed
                              ##  @return esp_err_t -  ESP_OK if (timeout_ticks > 0) and and flush was successful,
                              ##                       ESP_ERR_TIMEOUT if timeout occurred3 or flush was successful with (timeout_ticks == 0)
                              ##                       ESP_FAIL if flush was unsuccessful
                              ##

proc tinyusb_cdcacm_read*(itf: tinyusb_cdcacm_itf_t; out_buf: ptr uint8;
                          out_buf_sz: csize_t; rx_data_size: ptr csize_t): esp_err_t {.
    cdecl, importc: "tinyusb_cdcacm_read", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Read a content to the array, and defines it's size to the sz_store
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @param out_buf - to this array will be stored the object from a CDC buffer
                              ##  @param out_buf_sz - size of buffer for results
                              ##  @param rx_data_size - to this address will be stored the object's size
                              ##  @return esp_err_t ESP_OK, ESP_FAIL or ESP_ERR_INVALID_STATE
                              ##

proc tusb_cdc_acm_initialized*(itf: tinyusb_cdcacm_itf_t): bool {.cdecl,
    importc: "tusb_cdc_acm_initialized", header: "tusb_cdc_acm.h".}
  ##
                              ##
                              ##  @brief Check if the ACM initialized
                              ##
                              ##  @param itf - number of a CDC object
                              ##  @return true or false
                              ##
## ********************************************************************* Public functions
