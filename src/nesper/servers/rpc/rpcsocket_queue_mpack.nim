import nativesockets, net, selectors, tables, posix

import ../../consts
import ../../general
import ../../queue_utils
import ../../tasks
import ../../timer_utils
import ../tcpsocket

import router
import json
import msgpack4nim
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

var rpcRouter: RpcRouter
var rpcInQueue: QueueHandle_t
var rpcOutQueue: QueueHandle_t

proc rpcMsgPackQueueWriteHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackQueueReadHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =

  try:
    logd(TAG, "rpc server handler: router: %x", rt.buffer)

    let msg = sourceClient.recv(rt.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      timeBlockDebug("rpcSocketDecode"):
        var rcall = msgpack2json.toJsonNode(msg)
      
      logd(TAG, "rpc socket sent result: %s", repr(rcall))
      GC_ref(rcall)
      discard xQueueSend(rpcInQueue, addr rcall, TickType_t(1000)) 

      var res: JsonNode
      while xQueueReceive(rpcOutQueue, addr(res), 0) == 0: 
        # logd(TAG, "rpc socket waiting for result")
        continue

      timeBlockDebug("rpcSocketEncode"):
        var rmsg: string = msgpack2json.fromJsonNode(res)
      logd(TAG, "sending to client: %s", $(sourceClient.getFd().int))
      discard sourceClient.send(addr(rmsg[0]), rmsg.len)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)

# Execute RPC Server #
proc execRpcSocketTask*(arg: pointer) {.exportc, cdecl.} =
  logi(TAG,"exec rpc task rpcInQueue: %s", repr(addr(rpcInQueue).pointer))
  logi(TAG,"exec rpc task rpcOutQueue: %s", repr(addr(rpcOutQueue).pointer))

  while true:
    try:
      timeBlockDebug("rpcTask"):
        logd(TAG,"exec rpc task wait: ")
        var rcall: JsonNode
        if xQueueReceive(rpcInQueue, addr(rcall), portMAX_DELAY) != 0: 
          logd(TAG,"exec rpc task got: %s", repr(addr(rcall).pointer))
    
          var res: JsonNode = rpcRouter.route( rcall )
    
          logd(TAG,"exec rpc task send: %s", $(res))
          GC_ref(res)
          discard xQueueSend(rpcOutQueue, addr(res), TickType_t(1_000)) 

    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "Got exception ", repr(e), " with message ", msg



proc startRpcQueueSocketServer*(port: Port; router: var RpcRouter) =
  logi(TAG, "starting mpack rpc server: buffer: %s", $router.buffer)
  rpcRouter = router
  rpcInQueue = xQueueCreate(1, sizeof(JsonNode))
  rpcOutQueue = xQueueCreate(1, sizeof(JsonNode))

  var rpcTask: TaskHandle_t
  discard xTaskCreatePinnedToCore(
                  execRpcSocketTask,
                  pcName="rpc task",
                  usStackDepth=8128,
                  pvParameters=addr(router),
                  uxPriority=1,
                  pvCreatedTask=addr(rpcTask),
                  xCoreID=1)

  startSocketServer[RpcRouter](
    Port(5555),
    readHandler=rpcMsgPackQueueReadHandler,
    writeHandler=rpcMsgPackQueueWriteHandler,
    data=router)



when isMainModule:
    runTcpServer()