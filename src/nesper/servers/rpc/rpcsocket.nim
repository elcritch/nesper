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
    logd(TAG, "rpc router: len:  %s", $rt.max_buffer)

    var msg: string = newString(rt.max_buffer)
    var count = sourceClient.recv(msg, rt.max_buffer)

    if count == 0:
      raise newException(TcpClientDisconnected, "")
    elif count < 0:
      raise newException(TcpClientError, "")
    else:
      msg.setLen(count)
      var rcall = msgpack2json.toJsonNode(msg)

      var res: JsonNode = rt.route( rcall )
      var rmsg: string = msgpack2json.fromJsonNode(res)
      # logi(TAG, "rpc result: %s", $res)
      # logi(TAG, "rpc result: %s", repr(rmsg))

      logd(TAG, "sending to client: %s", $(sourceClient.getFd().int))
      discard sourceClient.send(addr rmsg[0], rmsg.len)
      # logi(TAG, "sent to client: %s", $(sourceClient.getFd().int))

      # for cfd, client in srv.clients:
        # logi(TAG, "sent to client: %s", $(client.getFd().int))
        # discard client.send(addr rmsg[0], rmsg.len)
        # client.send("\r\n")
      # srv.tcpMessages.insert(msg, 0)
  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)



proc startRpcSocketServer*(port: Port; router: var RpcRouter) =
  logi(TAG, "starting rpc server: router: %s", $(router.max_buffer))
  logi(TAG, "starting rpc server: router: %x", addr(router.procs))

  startSocketServer[RpcRouter](
    Port(5555),
    readHandler=rpcMsgPackReadHandler,
    writeHandler=rpcMsgPackWriteHandler,
    data=router)



when isMainModule:
    runTcpServer()