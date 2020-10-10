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
      var rcall = parseJson(msg)

      var res: JsonNode = rt.route( rcall )
      var rmsg: string = $res

      logd(TAG, "sending to client: %s", $(sourceClient.getFd().int))
      discard sourceClient.send(addr rmsg[0], rmsg.len)
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