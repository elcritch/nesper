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
              event_data: ptr seq[int]
            ) {.cdecl.} =
  echo("app: `add_all` event: " & repr(event_data))
  # var data: seq[int] = cast[ptr seq[int]](event_data)[]
  var data: seq[int] = event_data[]
  echo("app: `add_all` data: " & $data)
  # echo("app: `add_all` event[]: " & repr(cast[ptr pointer](event_data)))
  echo("")

  # apploop.eventPost(APP_EVENT, app_add_all, addr(vals), sizeof(vals), 10000)

  # var pdata: ptr seq[int] = cast[ptr seq[int]](event_data)
  # echo("app: `add_all` event: ptr: " & repr(pdata))
  # var data: seq[int] = pdata[]
  # echo("app: `add_all` event: data: " & $(data))

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

  echo("run_app: running! Loop handle: " & repr(loop.pointer) & " ptr: " & $repr(loop))
  loop.eventRegisterWith(APP_EVENT, app_add_all, add_all)

  return loop
