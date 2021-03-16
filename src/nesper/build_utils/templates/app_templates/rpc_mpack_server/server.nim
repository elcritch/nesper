import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
import json

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

import nesper/servers/rpc/rpcsocket_mpack

# Setup RPC Server #
proc run_rpc_server*() =

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

  # this adds methods for Over-The-Air updates using RPC! 
  # note, this isn't secured by default
  rpcRouter.addOTAMethods()

  echo "starting rpc server on port 5555"
  logi(TAG,"starting rpc server buffer size: %s", $$(rt.buffer))

  # Starts RPC handler on the current task 
  # Default for JSON, MsgPack, and TCP Echo
  startRpcSocketServer(Port(5555), router=rt)



