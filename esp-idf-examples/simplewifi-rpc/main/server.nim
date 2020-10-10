
# import nesper/servers/rpc/socketrpc
import nesper/servers/rpc/rpcsocket

var count = 0

when defined(TcpMsgpackRpcServer):
  type
    MyObject = object
      id: int
      name: string

  # Setup RPC Server #
  # var rt = RpcRouter(procs: initTable[string, RpcProc](), max_buffer: 4096)
  proc run_rpc_server*() =

    var rt = createRpcRouter(4096)

    rt.rpc("hello") do(input: string) -> string:
      result = "Hello " & input

    rt.rpc("add") do(a: int, b: int) -> int:
      result = a + b

    rt.rpc("addAll") do(vals: seq[int]) -> int:
      result = 0
      for x in vals:
        result += x

    echo "starting rpc server on port 5555"
    echo "starting rpc server buffer len: " & $(rt.max_buffer)
    startRpcSocketServer(Port(5555), router=rt)


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
    # startRpcSocketServer(Port(5555))

