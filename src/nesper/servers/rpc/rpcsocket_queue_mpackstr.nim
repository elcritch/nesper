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
    var msg = sourceClient.recv(qh.router.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      var pmsg: ptr string = addr(msg)
      discard xQueueSend(qh.inQueue, addr(pmsg), TickType_t(1000)) 

      var res: cstring
      while xQueueReceive(qh.outQueue, addr(res), 0) == 0: 
        continue

      # var rmsg = res[]
      discard sourceClient.send(res.pointer, len(res))
      deallocShared(res)


  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)

# Execute RPC Server #
proc execRpcSocketTask*(arg: pointer) {.exportc, cdecl.} =
  var qh: ptr RpcQueueHandle = cast[ptr RpcQueueHandle](arg)

  while true:
    try:
      logd(TAG,"exec rpc task wait: ")
      var pmsg: ptr string

      if xQueueReceive(qh.inQueue, addr(pmsg), portMAX_DELAY) != 0: 
        if pmsg == nil:
          raise newException(ValueError, "bad data ptr in rpc queue!")

        var msg = pmsg[]
        var rcall = msgpack2json.toJsonNode(msg)
        var res: JsonNode = qh.router.route(rcall)
  
        var rmsg: string = fromJsonNode(res)
        var crmsg: cstring = cast[cstring](allocShared0(len(rmsg)))
        copyMem(crmsg, rmsg.cstring(), len(rmsg))
        # var pcrmsg = addr(crmsg)
        # logi(TAG,"exec rpc task send: %s", repr(crmsg.pointer))

        discard xQueueSend(qh.outQueue, addr(crmsg), TickType_t(1_000)) 

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

