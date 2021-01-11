
import asynchttpserver, asyncdispatch, net

var count = 0

proc cb*(req: Request) {.async.} =
    inc count
    echo "req #", count
    await req.respond(Http200, "Hello World from nim on ESP32\n")
    # GC_fullCollect()

proc run_http_server*() {.exportc.} =
    echo "starting http server on port 8181"
    var server = newAsyncHttpServer()

    waitFor server.serve(Port(8181), cb)

import nesper/esp/esp_timer

proc example_cb*(arg: pointer) {.cdecl.} = 
  echo "Done!"

proc timer_test*(arg: pointer) {.cdecl.} = 
    var x = "hello"

    var timer_handle = esp_timer_create_args_t(
    callback: example_cb,
    arg: x.cstring,
    dispatch_method: ESP_TIMER_TASK,
    name: "timer1")

    var timer1: esp_timer_handle_t

    discard esp_timer_create(addr timer_handle, addr timer1)
    discard esp_timer_start_periodic(timer1, 1000.uint64)


when isMainModule:
    echo "running server"
    run_http_server()
    timer_test()

