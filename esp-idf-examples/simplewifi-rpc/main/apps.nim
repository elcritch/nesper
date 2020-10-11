import nesper
import nesper/consts
import nesper/general
import nesper/events
import nesper/tasks

const APP_EVENT*: string = "APP_EVENT"

type 
  app_events_t* {.size: sizeof(cint).} = enum 
    app_test = 0,
    app_add_all

proc add_all*(arg: pointer;
              event_base: esp_event_base_t;
              event_id: int32;
              event_data: pointer
            ) {.cdecl.} =
  echo("app: `add_all` event")
  # var pdata: ptr seq[int] = cast[ptr seq[int]](event_data)
  # var data: seq[int] = pdata[]

proc setup_app_task_loop*(): esp_event_loop_handle_t =
  var loop: esp_event_loop_handle_t
  var loop_args =
        esp_event_loop_args_t(
          queue_size: 10,
          task_name: "app loop",
          task_priority: 1,
          task_stack_size: 4096,
          task_core_id: 1)

  let ret = esp_event_loop_create(addr(loop_args), addr(loop))
  if ret != ESP_OK:
    raise newEspError[EventError]("register: " & $esp_err_to_name(ret), ret)

  echo("run_app: running!")
  loop.eventRegisterWith(APP_EVENT, app_add_all, add_all)

