import ../../consts

const
  PCNT_PIN_NOT_USED* = (-1)     ## !< When selected for a pin, this pin will not be used

## *
##  @brief Selection of available modes that determine the counter's action depending on the state of the control signal's input GPIO
##  @note  Configuration covers two actions, one for high, and one for low level on the control input
##

type
  pcnt_ctrl_mode_t* {.size: sizeof(cint).} = enum
    PCNT_MODE_KEEP = 0,         ## !< Control mode: won't change counter mode
    PCNT_MODE_REVERSE = 1,      ## !< Control mode: invert counter mode(increase -> decrease, decrease -> increase)
    PCNT_MODE_DISABLE = 2,      ## !< Control mode: Inhibit counter(counter value will not change in this condition)
    PCNT_MODE_MAX


## *
##  @brief Selection of available modes that determine the counter's action on the edge of the pulse signal's input GPIO
##  @note  Configuration covers two actions, one for positive, and one for negative edge on the pulse input
##

type
  pcnt_count_mode_t* {.size: sizeof(cint).} = enum
    PCNT_COUNT_DIS = 0,         ## !< Counter mode: Inhibit counter(counter value will not change in this condition)
    PCNT_COUNT_INC = 1,         ## !< Counter mode: Increase counter value
    PCNT_COUNT_DEC = 2,         ## !< Counter mode: Decrease counter value
    PCNT_COUNT_MAX


## *
##  @brief Selection of all available PCNT units
##

type
  pcnt_unit_t* {.size: sizeof(cint).} = enum
    PCNT_UNIT_0 = 0,            ## !< PCNT unit 0
    PCNT_UNIT_1 = 1,            ## !< PCNT unit 1
    PCNT_UNIT_2 = 2,            ## !< PCNT unit 2
    PCNT_UNIT_3 = 3,            ## !< PCNT unit 3
    PCNT_UNIT_4 = 4,            ## !< PCNT unit 4
    PCNT_UNIT_5 = 5,            ## !< PCNT unit 5
    PCNT_UNIT_6 = 6,            ## !< PCNT unit 6
    PCNT_UNIT_7 = 7,            ## !< PCNT unit 7
    PCNT_UNIT_MAX


## *
##  @brief Selection of channels available for a single PCNT unit
##

type
  pcnt_channel_t* {.size: sizeof(cint).} = enum
    PCNT_CHANNEL_0 = 0x00000000, ## !< PCNT channel 0
    PCNT_CHANNEL_1 = 0x00000001, ## !< PCNT channel 1
    PCNT_CHANNEL_MAX


## *
##  @brief Selection of counter's events the may trigger an interrupt
##

type
  pcnt_evt_type_t* {.size: sizeof(cint).} = enum
    PCNT_EVT_L_LIM = 0,         ## !< PCNT watch point event: Minimum counter value
    PCNT_EVT_H_LIM = 1,         ## !< PCNT watch point event: Maximum counter value
    PCNT_EVT_THRES_0 = 2,       ## !< PCNT watch point event: threshold0 value event
    PCNT_EVT_THRES_1 = 3,       ## !< PCNT watch point event: threshold1 value event
    PCNT_EVT_ZERO = 4,          ## !< PCNT watch point event: counter value zero event
    PCNT_EVT_MAX


## *
##  @brief Pulse Counter configuration for a single channel
##

type
  pcnt_config_t* {.importc: "pcnt_config_t", header: "pcnt.h", bycopy.} = object
    pulse_gpio_num* {.importc: "pulse_gpio_num".}: cint ## !< Pulse input GPIO number, if you want to use GPIO16, enter pulse_gpio_num = 16, a negative value will be ignored
    ctrl_gpio_num* {.importc: "ctrl_gpio_num".}: cint ## !< Control signal input GPIO number, a negative value will be ignored
    lctrl_mode* {.importc: "lctrl_mode".}: pcnt_ctrl_mode_t ## !< PCNT low control mode
    hctrl_mode* {.importc: "hctrl_mode".}: pcnt_ctrl_mode_t ## !< PCNT high control mode
    pos_mode* {.importc: "pos_mode".}: pcnt_count_mode_t ## !< PCNT positive edge count mode
    neg_mode* {.importc: "neg_mode".}: pcnt_count_mode_t ## !< PCNT negative edge count mode
    counter_h_lim* {.importc: "counter_h_lim".}: int16 ## !< Maximum counter value
    counter_l_lim* {.importc: "counter_l_lim".}: int16 ## !< Minimum counter value
    unit* {.importc: "unit".}: pcnt_unit_t ## !< PCNT unit number
    channel* {.importc: "channel".}: pcnt_channel_t ## !< the PCNT channel

  pcnt_isr_handle_t* = intr_handle_t

## *
##  @brief Configure Pulse Counter unit
##         @note
##         This function will disable three events: PCNT_EVT_L_LIM, PCNT_EVT_H_LIM, PCNT_EVT_ZERO.
##
##  @param pcnt_config Pointer of Pulse Counter unit configure parameter
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_unit_config*(pcnt_config: ptr pcnt_config_t): esp_err_t {.
    importc: "pcnt_unit_config", header: "pcnt.h".}
## *
##  @brief Get pulse counter value
##
##  @param pcnt_unit  Pulse Counter unit number
##  @param count Pointer to accept counter value
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_get_counter_value*(pcnt_unit: pcnt_unit_t; count: ptr int16): esp_err_t {.
    importc: "pcnt_get_counter_value", header: "pcnt.h".}
## *
##  @brief Pause PCNT counter of PCNT unit
##
##  @param pcnt_unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_counter_pause*(pcnt_unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_counter_pause", header: "pcnt.h".}
## *
##  @brief Resume counting for PCNT counter
##
##  @param pcnt_unit PCNT unit number, select from pcnt_unit_t
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_counter_resume*(pcnt_unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_counter_resume", header: "pcnt.h".}
## *
##  @brief Clear and reset PCNT counter value to zero
##
##  @param  pcnt_unit PCNT unit number, select from pcnt_unit_t
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_counter_clear*(pcnt_unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_counter_clear", header: "pcnt.h".}
## *
##  @brief Enable PCNT interrupt for PCNT unit
##         @note
##         Each Pulse counter unit has five watch point events that share the same interrupt.
##         Configure events with pcnt_event_enable() and pcnt_event_disable()
##
##  @param pcnt_unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_intr_enable*(pcnt_unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_intr_enable", header: "pcnt.h".}
## *
##  @brief Disable PCNT interrupt for PCNT unit
##
##  @param pcnt_unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_intr_disable*(pcnt_unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_intr_disable", header: "pcnt.h".}
## *
##  @brief Enable PCNT event of PCNT unit
##
##  @param unit PCNT unit number
##  @param evt_type Watch point event type.
##                  All enabled events share the same interrupt (one interrupt per pulse counter unit).
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_event_enable*(unit: pcnt_unit_t; evt_type: pcnt_evt_type_t): esp_err_t {.
    importc: "pcnt_event_enable", header: "pcnt.h".}
## *
##  @brief Disable PCNT event of PCNT unit
##
##  @param unit PCNT unit number
##  @param evt_type Watch point event type.
##                  All enabled events share the same interrupt (one interrupt per pulse counter unit).
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_event_disable*(unit: pcnt_unit_t; evt_type: pcnt_evt_type_t): esp_err_t {.
    importc: "pcnt_event_disable", header: "pcnt.h".}
## *
##  @brief Set PCNT event value of PCNT unit
##
##  @param unit PCNT unit number
##  @param evt_type Watch point event type.
##                  All enabled events share the same interrupt (one interrupt per pulse counter unit).
##
##  @param value Counter value for PCNT event
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_set_event_value*(unit: pcnt_unit_t; evt_type: pcnt_evt_type_t;
                          value: int16): esp_err_t {.
    importc: "pcnt_set_event_value", header: "pcnt.h".}
## *
##  @brief Get PCNT event value of PCNT unit
##
##  @param unit PCNT unit number
##  @param evt_type Watch point event type.
##                  All enabled events share the same interrupt (one interrupt per pulse counter unit).
##  @param value Pointer to accept counter value for PCNT event
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_get_event_value*(unit: pcnt_unit_t; evt_type: pcnt_evt_type_t;
                          value: ptr int16): esp_err_t {.
    importc: "pcnt_get_event_value", header: "pcnt.h".}
## *
##  @brief Register PCNT interrupt handler, the handler is an ISR.
##         The handler will be attached to the same CPU core that this function is running on.
##         Please do not use pcnt_isr_service_install if this function was called.
##
##  @param fn Interrupt handler function.
##  @param arg Parameter for handler function
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##  @param handle Pointer to return handle. If non-NULL, a handle for the interrupt will
##         be returned here. Calling esp_intr_free to unregister this ISR service if needed,
##         but only if the handle is not NULL.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_NOT_FOUND Can not find the interrupt that matches the flags.
##      - ESP_ERR_INVALID_ARG Function pointer error.
##

proc pcnt_isr_register*(fn: proc (a1: pointer) {.cdecl.}; arg: pointer; intr_alloc_flags: cint;
                       handle: ptr pcnt_isr_handle_t): esp_err_t {.
    importc: "pcnt_isr_register", header: "pcnt.h".}
## *
##  @brief Configure PCNT pulse signal input pin and control input pin
##
##  @param unit PCNT unit number
##  @param channel PCNT channel number
##  @param pulse_io Pulse signal input GPIO
##  @param ctrl_io Control signal input GPIO
##
##  @note  Set the signal input to PCNT_PIN_NOT_USED if unused.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_set_pin*(unit: pcnt_unit_t; channel: pcnt_channel_t; pulse_io: cint;
                  ctrl_io: cint): esp_err_t {.importc: "pcnt_set_pin",
    header: "pcnt.h".}
## *
##  @brief Enable PCNT input filter
##
##  @param unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_filter_enable*(unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_filter_enable", header: "pcnt.h".}
## *
##  @brief Disable PCNT input filter
##
##  @param unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_filter_disable*(unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_filter_disable", header: "pcnt.h".}
## *
##  @brief Set PCNT filter value
##
##  @param unit PCNT unit number
##  @param filter_val PCNT signal filter value, counter in APB_CLK cycles.
##         Any pulses lasting shorter than this will be ignored when the filter is enabled.
##         @note
##         filter_val is a 10-bit value, so the maximum filter_val should be limited to 1023.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_set_filter_value*(unit: pcnt_unit_t; filter_val: uint16): esp_err_t {.
    importc: "pcnt_set_filter_value", header: "pcnt.h".}
## *
##  @brief Get PCNT filter value
##
##  @param unit PCNT unit number
##  @param filter_val Pointer to accept PCNT filter value.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_get_filter_value*(unit: pcnt_unit_t; filter_val: ptr uint16): esp_err_t {.
    importc: "pcnt_get_filter_value", header: "pcnt.h".}
## *
##  @brief Set PCNT counter mode
##
##  @param unit PCNT unit number
##  @param channel PCNT channel number
##  @param pos_mode Counter mode when detecting positive edge
##  @param neg_mode Counter mode when detecting negative edge
##  @param hctrl_mode Counter mode when control signal is high level
##  @param lctrl_mode Counter mode when control signal is low level
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_set_mode*(unit: pcnt_unit_t; channel: pcnt_channel_t;
                   pos_mode: pcnt_count_mode_t; neg_mode: pcnt_count_mode_t;
                   hctrl_mode: pcnt_ctrl_mode_t; lctrl_mode: pcnt_ctrl_mode_t): esp_err_t {.
    importc: "pcnt_set_mode", header: "pcnt.h".}
## *
##  @brief Add ISR handler for specified unit.
##
##  Call this function after using pcnt_isr_service_install() to
##  install the PCNT driver's ISR handler service.
##
##  The ISR handlers do not need to be declared with IRAM_ATTR,
##  unless you pass the ESP_INTR_FLAG_IRAM flag when allocating the
##  ISR in pcnt_isr_service_install().
##
##  This ISR handler will be called from an ISR. So there is a stack
##  size limit (configurable as "ISR stack size" in menuconfig). This
##  limit is smaller compared to a global PCNT interrupt handler due
##  to the additional level of indirection.
##
##  @param unit PCNT unit number
##  @param isr_handler Interrupt handler function.
##  @param args Parameter for handler function
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_isr_handler_add*(unit: pcnt_unit_t; isr_handler: proc (a1: pointer) {.cdecl.};
                          args: pointer): esp_err_t {.
    importc: "pcnt_isr_handler_add", header: "pcnt.h".}
## *
##  @brief Install PCNT ISR service.
##  @note We can manage different interrupt service for each unit.
##        This function will use the default ISR handle service, Calling pcnt_isr_service_uninstall to
##        uninstall the default service if needed. Please do not use pcnt_isr_register if this function was called.
##
##  @param intr_alloc_flags Flags used to allocate the interrupt. One or multiple (ORred)
##         ESP_INTR_FLAG_* values. See esp_intr_alloc.h for more info.
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_NO_MEM No memory to install this service
##      - ESP_ERR_INVALID_STATE ISR service already installed
##

proc pcnt_isr_service_install*(intr_alloc_flags: cint): esp_err_t {.
    importc: "pcnt_isr_service_install", header: "pcnt.h".}
## *
##  @brief Uninstall PCNT ISR service, freeing related resources.
##

proc pcnt_isr_service_uninstall*() {.importc: "pcnt_isr_service_uninstall",
                                   header: "pcnt.h".}
## *
##  @brief Delete ISR handler for specified unit.
##
##  @param unit PCNT unit number
##
##  @return
##      - ESP_OK Success
##      - ESP_ERR_INVALID_ARG Parameter error
##

proc pcnt_isr_handler_remove*(unit: pcnt_unit_t): esp_err_t {.
    importc: "pcnt_isr_handler_remove", header: "pcnt.h".}
## *
##  @addtogroup pcnt-examples
##
##  @{
##
##  EXAMPLE OF PCNT CONFIGURATION
##  ==============================
##  @code{c}
##  //1. Config PCNT unit
##  pcnt_config_t pcnt_config = {
##      .pulse_gpio_num = 4,         //set gpio4 as pulse input gpio
##      .ctrl_gpio_num = 5,          //set gpio5 as control gpio
##      .channel = PCNT_CHANNEL_0,         //use unit 0 channel 0
##      .lctrl_mode = PCNT_MODE_REVERSE,   //when control signal is low, reverse the primary counter mode(inc->dec/dec->inc)
##      .hctrl_mode = PCNT_MODE_KEEP,      //when control signal is high, keep the primary counter mode
##      .pos_mode = PCNT_COUNT_INC,        //increment the counter
##      .neg_mode = PCNT_COUNT_DIS,        //keep the counter value
##      .counter_h_lim = 10,
##      .counter_l_lim = -10,
##  };
##  pcnt_unit_config(&pcnt_config);        //init unit
##  @endcode
##
##  EXAMPLE OF PCNT EVENT SETTING
##  ==============================
##  @code{c}
##  //2. Configure PCNT watchpoint event.
##  pcnt_set_event_value(PCNT_UNIT_0, PCNT_EVT_THRES_1, 5);   //set thres1 value
##  pcnt_event_enable(PCNT_UNIT_0, PCNT_EVT_THRES_1);         //enable thres1 event
##  @endcode
##
##  For more examples please refer to PCNT example code in IDF_PATH/examples
##
##  @}
##
