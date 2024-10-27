import nativesockets, net, selectors, tables, posix

import ../../general
import ../../timers
import ../tcpsocket

import router
import json
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

proc rpcMsgPackWriteHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackReadHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  # TODO: improvement
  # The incoming RPC call needs to be less than 1400 or the network buffer size.
  # This could be improved, but is a bit finicky. In my usage, I only send small
  # RPC calls with possibly larger responses. 

  try:
    logd(TAG, "rpc server handler: router: %x", rt.buffer)

    var msg = sourceClient.recv(rt.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      var rcall = msgpack2json.toJsonNode(move msg)

      var res: JsonNode = rt.route(rcall)
      var rmsg: string = msgpack2json.fromJsonNode(move res)

      logd(TAG, "sending to client: %s", $(sourceClient.getFd().int))
      sourceClient.sendLength(rmsg)
      sourceClient.sendChunks(rmsg)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)


proc startRpcSocketServer*(port: Port; address="", router: var RpcRouter) =
  logi(TAG, "starting mpack rpc server: buffer: %s", $router.buffer)

  startSocketServer[RpcRouter](
    port,
    address=address,
    readHandler=rpcMsgPackReadHandler,
    writeHandler=rpcMsgPackWriteHandler,
    data=router)

