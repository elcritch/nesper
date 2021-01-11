
import nesper/timers

proc example_cb*(arg: pointer) {.cdecl.} = 
  echo "Done!"

var x = "hello"

var timer1 = createTimer(
  callback= example_cb,
  arg= x.cstring,
  dispatch_method= ESP_TIMER_TASK,
  name= "timer1")

discard esp_timer_start_periodic(timer1, 1000.uint64)

