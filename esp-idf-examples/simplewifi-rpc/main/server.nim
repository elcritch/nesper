import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
import json
# import nesper/servers/rpc/socketrpc

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

when defined(TcpJsonRpcServer):
  import nesper/servers/rpc/rpcsocket_json
  # when defined(TcpMpackRpcServer):
when defined(TcpMpackRpcQueueServer):
  import nesper/servers/rpc/rpcsocket_queue_mpack
elif not defined(TcpEchoServer):
  import nesper/servers/rpc/rpcsocket_mpack


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
    # startRpcSocketServer(Port(5555))

else:

  # Setup RPC Server #
  proc run_rpc_server*() =

    var rpcRouter: RpcRouter 

    # Setup an app task apploop
    # note: not sure if this is the best place for it or not?
    var rt = createRpcRouter(MaxRpcReceiveBuffer)

    rpc(rt, "hello") do(input: string) -> string:
      result = "Hello " & input

    rpc(rt, "add") do(a: int, b: int) -> int:
      result = a + b

    rpc(rt, "addAll") do(vals: seq[int]) -> int:

      echo("run_rpc_server: done: " & repr(addr(vals)))
      result = 0
      for x in vals:
        result += x

    when not defined(TcpMpackRpcQueueServer):
      echo "starting rpc server on port 5555"
      logi(TAG,"starting rpc server buffer size: %s", $(rt.buffer))
      startRpcSocketServer(Port(5555), router=rt)
    else:

      startRpcQueueSocketServer(Port(5555), router=rt) 



