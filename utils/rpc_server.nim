
import nesper/servers/rpc/rpcsocket_json

proc setupRpc(rt: var RpcRouter) =
  rt.rpc("hello") do(input: string) -> string:
    # example: ./rpc_cli --ip:$IP -c:1 '{"method": "hello", "params": ["world"]}'
    result = "Hello " & input

  rt.rpc("add") do(a: int, b: int) -> int:
    # example: ./rpc_cli --ip:$IP -c:1 '{"method": "add", "params": [1, 2]}'
    result = a + b

var rt: RpcRouter = createRpcRouter(4096)
startRpcSocketServer(port=Port(5555), address="::", router=rt)
