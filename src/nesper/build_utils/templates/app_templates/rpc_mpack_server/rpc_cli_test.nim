const RpcServerType* = "mpack"

import parseopt
import msgpack4nim
import msgpack4nim/msgpack2json

include nesper/servers/rpc/rpc_cli_utils

var p = initOptParser()

var args = p.rpcOptions()

args.runRpc()
