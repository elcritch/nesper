import nativesockets, net, selectors, tables, posix

include nesper

import ../../consts
import ../../general
import ../../queues
import ../../tasks
import ../../timers
import ../tcpsocket

import router
import json
import msgpack4nim
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

type 
  RpcQueueHandle = ref object
    router: RpcRouter
    inQueue: QueueHandle_t
    outQueue: QueueHandle_t

proc rpcMsgPackQueueWriteHandler*(srv: TcpServerInfo[RpcQueueHandle], result: ReadyKey, sourceClient: Socket, qh: RpcQueueHandle) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackQueueReadHandler*(srv: TcpServerInfo[RpcQueueHandle], result: ReadyKey, sourceClient: Socket, qh: RpcQueueHandle) =

  try:
    let msg = sourceClient.recv(qh.router.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      var rcall = msgpack2json.toJsonNode(msg)
      var prcall: ptr JsonNode = addr(rcall)
      
      discard xQueueSend(qh.inQueue, addr(prcall), TickType_t(1000)) 

      var res: ptr JsonNode
      while xQueueReceive(qh.outQueue, addr(res), 0) == 0: 
        continue

      var rmsg: string = msgpack2json.fromJsonNode(res[])
      sourceClient.send(move rmsg)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)

var rpcSocketId = 1

# Execute RPC Server #
proc execRpcSocketTask*(arg: pointer) {.exportc, cdecl.} =
  var qh: ptr RpcQueueHandle = cast[ptr RpcQueueHandle](arg)

  while true:
    try:
      timeBlockDebug("rpcTask"):
        logd(TAG,"exec rpc task wait: ")
        var prcall: ptr JsonNode
        if xQueueReceive(qh.inQueue, addr(prcall), portMAX_DELAY) != 0: 
          logd(TAG,"exec rpc task got: %s", repr(prcall.pointer))
          if prcall == nil:
            raise newException(ValueError, "bad data ptr in rpc queue!")

          var rcall: JsonNode = prcall[]
    
          var res: JsonNode = qh.router.route( rcall )
          var pres: ptr JsonNode = addr(res)
          GC_ref(res)
    
          inc(rpcSocketId)
          discard xQueueSend(qh.outQueue, addr(pres), TickType_t(1_000)) 

    except:
      let
        e = getCurrentException()
        msg = getCurrentExceptionMsg()
      echo "Got exception ", repr(e), " with message ", msg



proc startRpcQueueSocketServer*(port: Port, router: var RpcRouter;
                                task_stack_depth = 8128'u32, task_priority = UBaseType_t(1), task_core = BaseType_t(-1)) =
  logd(TAG, "starting mpack rpc server: buffer: %s", $router.buffer)
  var qh: RpcQueueHandle = new(RpcQueueHandle)

  qh.router = router
  qh.inQueue = xQueueCreate(1, sizeof(pointer))
  qh.outQueue = xQueueCreate(1, sizeof(pointer))

  var rpcTask: TaskHandle_t
  discard xTaskCreatePinnedToCore(
                  execRpcSocketTask,
                  pcName="rpcqtask",
                  usStackDepth=task_stack_depth,
                  pvParameters=addr(qh),
                  uxPriority=task_priority,
                  pvCreatedTask=addr(rpcTask),
                  xCoreID=task_core)

  startSocketServer[RpcQueueHandle](
    port,
    readHandler=rpcMsgPackQueueReadHandler,
    writeHandler=rpcMsgPackQueueWriteHandler,
    data=qh)

