
import asynchttpserver, asyncdispatch, net
var count = 0
proc cb*(req: Request) {.async.} =
    inc count
    echo "req #", count
    await req.respond(Http200, "Hello World from nim on ESP32")

proc run_http_server*() {.exportc.} =
    echo "starting http server on port 8181"
    var server = newAsyncHttpServer()

    waitFor server.serve(Port(8181), cb)

when isMainModule:
    echo "running server"
    run_http_server()

