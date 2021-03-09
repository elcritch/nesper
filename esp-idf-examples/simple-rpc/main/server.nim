import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
import json

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

## Note:
## Nim uses `when` compile time constructs
## these are like ifdef's in C and don't really have an equivalent in Python
## setting the flags can be done in the Makefile `simplewifi-rpc  Makefile
## for example, to compile the example to use JSON, pass `-d:TcpJsonRpcServer` to Nim
## the makefile has several example already defined for convenience
## 
when defined(TcpJsonRpcServer):
  import nesper/servers/rpc/rpcsocket_json
when defined(TcpMpackRpcQueueServer):
  import ota_rpc_example
  import nesper/servers/rpc/rpcsocket_queue_mpack
elif not defined(TcpEchoServer): # This is the default 'msgpack' version -- set like this for nimsuggest
  import ota_rpc_example
  import nesper/servers/rpc/rpcsocket_mpack
elif defined(TcpEchoServer):
  import nesper/servers/tcpsocket
else:
  {.fatal: "Compile this program with an rpc strategy!".}


when defined(TcpEchoServer):
  proc run_rpc_server*() =
    echo "starting server on port 5555"
    var msg = "echo: "
    startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data=msg)

else:

  # Setup RPC Server #
  proc run_rpc_server*() =

    # Setup an RPC router
    var rpcRouter: RpcRouter 
    var rt = createRpcRouter(MaxRpcReceiveBuffer)

    rpc(rt, "hello") do(input: string) -> string:
      # example: ./rpc_cli --ip:$IP -c:1 '{"method": "hello", "params": ["world"]}'
      result = "Hello " & input

    rpc(rt, "add") do(a: int, b: int) -> int:
      # example: ./rpc_cli --ip:$IP -c:1 '{"method": "add", "params": [1, 2]}'
      result = a + b

    rpc(rt, "addAll") do(vals: seq[int]) -> int:
      # example: ./rpc_cli --ip:$IP -c:1 '{"method": "add", "params": [1, 2, 3, 4, 5]}'
      echo("run_rpc_server: done: " & repr(addr(vals)))
      result = 0
      for x in vals:
        result += x

    # this adds methods for Over-The-Air updates using RPC! 
    # note, this isn't secured by default
    rpcRouter.addOTAMethods()

    echo "starting rpc server on port 5555"
    logi(TAG,"starting rpc server buffer size: %s", $(rt.buffer))

    when defined(TcpMpackRpcQueueServer):
      # Starts a separate task on CPU_1 (e.g. the "App CPU")
      # This makes it reallly easy to add dedicated tasks to run on CPU_1
      startRpcQueueSocketServer(Port(5555), router=rt) 
    else:
      # Starts RPC handler on the current task 
      # Default for JSON, MsgPack, and TCP Echo
      startRpcSocketServer(Port(5555), router=rt)



