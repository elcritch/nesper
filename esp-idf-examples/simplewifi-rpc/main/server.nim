import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
# import nesper/servers/rpc/socketrpc

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

when defined(TcpJsonRpcServer):
  import nesper/servers/rpc/rpcsocket_json
  # when defined(TcpMpackRpcServer):
elif not defined(TcpEchoServer):
  import nesper/servers/rpc/rpcsocket_mpack


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
    # startRpcSocketServer(Port(5555))

else:

  var apploop*: esp_event_loop_handle_t

  # Setup RPC Server #
  proc run_rpc_server*() =
    apploop = setup_app_task_loop()

    echo("run_rpc_server: apploop handle: ptr: " & $repr(apploop))

    # Setup an app task apploop
    # note: not sure if this is the best place for it or not?
    var rt = createRpcRouter(MaxRpcReceiveBuffer)

    rpc(rt, "hello") do(input: string) -> string:
      result = "Hello " & input

    rpc(rt, "add") do(a: int, b: int) -> int:
      result = a + b

    rpc(rt, "addAll") do(args: seq[int]) -> int:

      var vals = args
      var pvals = addr(vals)
      echo("")
      echo("run_rpc_server: addAll: apploop handle: " & $(toHex(cast[uint32](apploop))))
      echo("run_rpc_server: addAll: apploop handle: ptr: " & $repr(apploop))
      echo("run_rpc_server: addAll: item: pointer: " & repr(addr(vals).pointer))
      echo("run_rpc_server: addAll: item: ptr: " & repr(unsafeAddr(vals).pointer))
      echo("run_rpc_server: addAll: item: ptr: " & repr(sizeof(vals)))

      # apploop.eventPost(APP_EVENT, app_add_all, apploop, sizeof(pointer), 10000)
      # apploop.eventPost(APP_EVENT, app_add_all, addr(apploop), sizeof(pointer), 10000)
      # apploop.eventPost(APP_EVENT, app_add_all, addr(vals), sizeof(pointer), 10000)
      apploop.eventPost(APP_EVENT, app_add_all, addr(vals), sizeof(vals), 10000)

      echo("run_rpc_server: done: " & repr(addr(vals)))

      result = 0
      for x in vals:
        result += x

    echo "starting rpc server on port 5555"
    logi(TAG,"starting rpc server buffer size: %s", $(rt.buffer))
    startRpcSocketServer(Port(5555), router=rt)


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
    # startRpcSocketServer(Port(5555))

