import nesper
import nesper/consts
import nesper/general
import nesper/events
import nesper/tasks

const APP_EVENT*: string = "APP_EVENT"

type 
  app_events_t* {.size: sizeof(cint).} = enum 
    TEST = 0,
    ADD_ALL

proc add_all*(arg: pointer;
              event_base: esp_event_base_t;
              event_id: int32;
              event_data: pointer
            ) {.cdecl.} =
  echo("app: `add_all` event")
  # var pdata: ptr seq[int] = cast[ptr seq[int]](event_data)
  # var data: seq[int] = pdata[]

proc run_app*(arg: pointer) {.cdecl.} =
  echo("run_app: running!")

  let
    ret = esp_event_handler_register(
              event_base = APP_EVENT,
              event_id = ADD_ALL.cint,
              event_handler = add_all,
              event_handler_arg = nil)

  if ret != ESP_OK:
    raise newException(ValueError, "unable to register")

  while true:
