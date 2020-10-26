import nativesockets, net, selectors, tables, posix

import ../../general
import ../tcpsocket

import router
import json
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

proc rpcMsgPackWriteHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackReadHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =

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
      sourceClient.send(move rmsg)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)


proc startRpcSocketServer*(port: Port; router: var RpcRouter) =
  logi(TAG, "starting mpack rpc server: buffer: %s", $router.buffer)

  startSocketServer[RpcRouter](
    port,
    readHandler=rpcMsgPackReadHandler,
    writeHandler=rpcMsgPackWriteHandler,
    data=router)

