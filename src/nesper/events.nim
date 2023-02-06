import consts
import general

when defined(ESP_IDF_V4_0):
    import esp/net/tcpip_adapter
    # export tcpip_adapter
else:
    import esp/net/esp_netif
    export esp_netif

import esp/net/esp_eth_com
import esp/net/esp_wifi_types
import esp/esp_event
import esp/event_groups

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
        elif typeof(EVT) is eth_event_t:
            ETH_EVENT
        else:
            {.fatal: "Uknown event type, don't know how to unregister automatically".}

    let ret = 
            esp_event_handler_register(
                event_base = evt_base,
                event_id = cint(evt_id),
                event_handler = evt_handler,
                event_handler_arg = evt_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventRegister*[EVT](
            event_base: esp_event_base_t;
            event_id: EVT;
            event_handler: esp_event_handler_t;
            event_handler_arg: pointer = nil
        ) =
    ## Register event for an event base on the default loop.
    let ret = esp_event_handler_register(
        event_base,
        event_id.cint,
        event_handler,
        event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventRegisterWith*[EVT, TP](
            event_loop: esp_event_loop_handle_t;
            event_base: esp_event_base_t;
            event_id: EVT;
            event_handler: TP;
            event_handler_arg: pointer = nil
        ) =
    ## Register event with a given event loop.
    let ret = esp_event_handler_register_with(
                event_loop,
                event_base, cint(event_id),
                cast[esp_event_handler_t](event_handler), event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

template eventPost*[EVT](
            evt_loop: esp_event_loop_handle_t;
            evt_base: esp_event_base_t;
            evt_id: EVT;
            evt_data: pointer,
            evt_data_size: int;
            ticks_to_wait: TickType_t = 1000
        ) =
    ## Register event with a given event loop.
    let ret = esp_event_post_to(evt_loop, evt_base, cint(evt_id), evt_data, csize_t(evt_data_size), ticks_to_wait)

    if ret != ESP_OK:
      raise newEspError[EventError]("post: " & $esp_err_to_name(ret), ret)

template eventPostSendPtr*[EVT, DT](
            evt_loop: esp_event_loop_handle_t;
            evt_base: esp_event_base_t;
            evt_id: EVT;
            evt_data: pointer,
            evt_data_size: int;
            ticks_to_wait: TickType_t = 1000
        ) =
    ## Register event with a given event loop.
    var evt_data_ptr: pointer = evt_data

    let ret = esp_event_post_to(evt_loop, evt_base, cint(evt_id), addr(evt_data_ptr), csize_t(evt_data_size), ticks_to_wait)

    if ret != ESP_OK:
      raise newEspError[EventError]("post: " & $esp_err_to_name(ret), ret)

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
        elif typeof(EVT) is eth_event_t:
            ETH_EVENT
        else:
            {.fatal: "Uknown event type, don't know how to unregister automatically".}

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
