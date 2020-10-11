import nativesockets
import net
import selectors
import tables
import posix

import ../../consts
import ../../general
import ../tcpsocket
import router
import json
import msgpack4nim
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

proc rpcMsgPackWriteHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackReadHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =

  try:
    logd(TAG, "rpc server handler: router: %x", rt.buffer)

    let msg = sourceClient.recv(rt.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      var rcall = msgpack2json.toJsonNode(msg)

      var res: JsonNode = rt.route( rcall )
      var rmsg: string = msgpack2json.fromJsonNode(res)

      logd(TAG, "sending to client: %s", $(sourceClient.getFd().int))
      discard sourceClient.send(addr rmsg[0], rmsg.len)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)


proc startRpcSocketServer*(port: Port; router: var RpcRouter) =
  logi(TAG, "starting rpc server: buffer: %s", $router.buffer)

  startSocketServer[RpcRouter](
    Port(5555),
    readHandler=rpcMsgPackReadHandler,
    writeHandler=rpcMsgPackWriteHandler,
    data=router)



when isMainModule:
    runTcpServer()