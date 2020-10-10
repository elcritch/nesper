
# import nesper/servers/rpc/socketrpc
import nesper/servers/tcpsocket

var count = 0

type
  MyObject = object
    id: int
    name: string

# Setup RPC Server #
# var rt1 = newRpcRouter()

proc run_rpc_server*() =
    echo "starting rpc server on port 5555"
    startSocketServer(Port(5555))
    # startRpcSocketServer(Port(5555))

when isMainModule:
    echo "running server"
    run_rpc_server()

