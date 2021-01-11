
import nesper/esp/esp_timer

proc example_cb*(arg: pointer) {.cdecl.} = 
  echo "Done!"

var x = "hello"

var timer_handle = esp_timer_create_args_t(
  callback: example_cb,
  arg: x.cstring,
  dispatch_method: ESP_TIMER_TASK,
  name: "timer1")

var
  timer1: esp_timer_handle_t

discard esp_timer_create(addr timer_handle, addr timer1)

discard esp_timer_start_periodic(timer1, 1000.uint64)

