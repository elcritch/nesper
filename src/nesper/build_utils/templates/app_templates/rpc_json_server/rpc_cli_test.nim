

const RpcServerType* = "json"

import parseopt

include nesper/servers/rpc/rpc_cli_utils

var p = initOptParser()

var args = p.rpcOptions()

args.runRpc()
