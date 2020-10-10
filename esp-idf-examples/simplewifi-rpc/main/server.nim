
# import nesper/servers/rpc/socketrpc
import nesper/servers/tcpsocket

var count = 0

type
  MyObject = object
    id: int
    name: string

# Setup RPC Server #
# var rt1 = newRpcRouter()

when defined(TcpMsgpackRpcServer):
  proc run_rpc_server*() =
      echo "starting rpc server on port 5555"
      startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
      # startRpcSocketServer(Port(5555))


when defined(TcpEchoServer):
  proc run_rpc_server*() =
      echo "starting rpc server on port 5555"
      startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
      # startRpcSocketServer(Port(5555))

when isMainModule:
    echo "running server"
    run_rpc_server()

