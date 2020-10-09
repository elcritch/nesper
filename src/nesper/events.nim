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

proc eventRegister*(
            event_id: wifi_event_t;
            event_handler: esp_event_handler_t;
            event_handler_arg: pointer
        ) {.inline.} =

    let ret = esp_event_handler_register(
        event_base = WIFI_EVENT,
        event_id = event_id.cint,
        event_handler = event_handler,
        event_handler_arg = event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

proc eventRegister*(
            event_id: ip_event_t;
            event_handler: esp_event_handler_t;
            event_handler_arg: pointer
        ) {.inline.} =

    let ret = esp_event_handler_register(
        event_base = IP_EVENT,
        event_id = event_id.cint,
        event_handler = event_handler,
        event_handler_arg = event_handler_arg)

    if ret != ESP_OK:
      raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

proc eventUnregister*(
            event_id: wifi_event_t;
            event_handler: esp_event_handler_t;
        ) {.inline.} =

    let ret = esp_event_handler_unregister(
        event_base = WIFI_EVENT,
        event_id = event_id.cint,
        event_handler = event_handler)

    if ret != ESP_OK:
      raise newEspError[EventError]("unregister: " & $esp_err_to_name(ret), ret)

proc eventUnregister*(
            event_id: ip_event_t;
            event_handler: esp_event_handler_t;
        ) {.inline.} =

    let ret = esp_event_handler_unregister(
        event_base = IP_EVENT,
        event_id = event_id.cint,
        event_handler = event_handler)

    if ret != ESP_OK:
      raise newEspError[EventError]("unregister: " & $esp_err_to_name(ret), ret)
