import nesper/consts
import nesper/general
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
import nesper/servers/rpc/rpcsocket_json


# Setup RPC Server #
proc run_server*() =

  # Setup an RPC router
  var rpcRouter: RpcRouter 
  var rt = createRpcRouter(MaxRpcReceiveBuffer)

  rpc(rt, "hello") do(input: string) -> string:
    # example: ./rpc_cli --ip:$$IP -c:1 '{"method": "hello", "params": ["world"]}'
    result = "Hello " & input

  rpc(rt, "add") do(a: int, b: int) -> int:
    # example: ./rpc_cli --ip:$$IP -c:1 '{"method": "add", "params": [1, 2]}'
    result = a + b

  rpc(rt, "addAll") do(vals: seq[int]) -> int:
    # example: ./rpc_cli --ip:$$IP -c:1 '{"method": "add", "params": [1, 2, 3, 4, 5]}'
    echo("run_rpc_server: done: " & repr(addr(vals)))
    result = 0
    for x in vals:
      result += x

  echo "starting rpc server on port 5555"
  logi(TAG,"starting rpc server buffer size: %s", $$(rt.buffer))

  startRpcSocketServer(Port(5555), router=rt)



