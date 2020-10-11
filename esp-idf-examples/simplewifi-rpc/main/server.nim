import nesper/general
# import nesper/servers/rpc/socketrpc

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

when defined(TcpMpackRpcServer):
  import nesper/servers/rpc/rpcsocket_mpack

when defined(TcpJsonRpcServer):
  import nesper/servers/rpc/rpcsocket_json

when defined(TcpJsonRpcServer) or defined(TcpMpackRpcServer):
  # Setup RPC Server #
  proc run_rpc_server*() =

    var rt = createRpcRouter(MaxRpcReceiveBuffer)

    rpc(rt, "hello") do(input: string) -> string:
      result = "Hello " & input

    rpc(rt, "add") do(a: int, b: int) -> int:
      result = a + b

    rpc(rt, "addAll") do(vals: seq[int]) -> int:
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

