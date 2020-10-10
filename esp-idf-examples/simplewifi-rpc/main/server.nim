
# import nesper/servers/rpc/socketrpc
import nesper/servers/rpc/rpcsocket

var count = 0

type
  MyObject = object
    id: int
    name: string

# Setup RPC Server #
var rt = newRpcRouter(4096)

rt.rpc("hello") do(input: string) -> string:
  result = "Hello " & input

rt.rpc("add") do(a: int, b: int) -> int:
  result = a + b

when defined(TcpMsgpackRpcServer):

  proc run_rpc_server*() =
      echo "starting rpc server on port 5555"
      startRpcSocketServer(Port(5555), router=rt)


when defined(TcpEchoServer):
  proc run_rpc_server*() =
      echo "starting echo server on port 5555"
      startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
      # startRpcSocketServer(Port(5555))

when isMainModule:
    echo "running server"
    run_rpc_server()

