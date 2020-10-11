import consts
import general

import esp/net/tcpip_adapter
import esp/net/esp_wifi_types
import esp/esp_event
import esp/event_groups

export tcpip_adapter
export esp_wifi_types
export esp_event
export event_groups

type
  EventError* = object of OSError
    code*: esp_err_t

template eventRegister*[EVT](
            evt_id: EVT;
            evt_handler: esp_event_handler_t;
            evt_handler_arg: pointer = nil,
        ) =
    ## Register event with the default event loop. Understand WIFI & IP Events

    let evt_base = 
        when typeof(EVT) is wifi_event_t:
            WIFI_EVENT
        elif typeof(EVT) is ip_event_t:
            IP_EVENT
        else:
            UNKNOWN_TYPE_EVENT_TYPE

    let ret = 
            esp_event_handler_register(
                event_base = evt_base,
                event_id = cint(evt_id),
                event_handler = evt_handler,
                event_handler_arg = evt_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventRegister*[EVT](
            event_loop: esp_event_loop_handle_t;
            event_base: esp_event_base_t;
            event_id: EVT;
            event_handler: esp_event_handler_t;
            event_handler_arg: pointer = nil
        ) =
    ## Register event for an event base on the default loop.

    let ret = esp_event_handler_register_with(
        event_loop,
        event_base,
        event_id.cint,
        event_handler,
        event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventRegisterWith*[EVT](
            event_loop: esp_event_loop_handle_t;
            event_base: esp_event_base_t;
            event_id: EVT;
            event_handler: esp_event_handler_t;
            event_handler_arg: pointer = nil
        ) =
    ## Register event with a given event loop.

    let ret = esp_event_handler_register_with(event_loop, event_base, event_id.cint, event_handler, event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventUnregister*[EVT](
            evt_id: EVT;
            evt_handler: esp_event_handler_t;
        ) =
    ## Unregister event with the default event loop. Understand WIFI & IP Events

    let evt_base = 
        when typeof(EVT) is wifi_event_t:
            WIFI_EVENT
        elif typeof(EVT) is ip_event_t:
            IP_EVENT
        else:
            UNKNOWN_TYPE_EVENT_TYPE

    let ret = esp_event_handler_unregister(
        event_base = evt_base,
        event_id = cint(evt_id),
        event_handler = evt_handler)

    if ret != ESP_OK:
      raise newEspError[EventError]("unregister: " & $esp_err_to_name(ret), ret)

template eventUnregister*(
            evt_base: esp_event_base_t,
            evt_id: ip_event_t;
            evt_handler: esp_event_handler_t;
        ) =
    ## Unregister event for an event base on the default loop.

    let ret = esp_event_handler_unregister(
        event_base = evt_base,
        event_base = IP_EVENT,
        event_id = cint(evt_id),
        event_handler = evt_handler)

    if ret != ESP_OK:
      raise newEspError[EventError]("unregister: " & $esp_err_to_name(ret), ret)
