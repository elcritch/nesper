import nesper/general
# import nesper/servers/rpc/socketrpc

const TAG = "server"

when defined(TcpMsgpackRpcServer):
  import nesper/servers/rpc/rpcsocket_mpack

  # Setup RPC Server #
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
    logi(TAG,"starting rpc server buffer ptr: %x", $(rt.buffer.cstring()))
    startRpcSocketServer(Port(5555), router=rt)

when defined(TcpJsonRpcServer):
  import nesper/servers/rpc/rpcsocket_json

  # Setup RPC Server #
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
    echo "starting rpc server buffer ptr: " & $(rt.max_buffer)
    startRpcSocketServer(Port(5555), router=rt)


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")
    # startRpcSocketServer(Port(5555))

