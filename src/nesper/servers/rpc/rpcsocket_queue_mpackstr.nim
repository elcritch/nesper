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

  DataBuffer = object
    data: cstring
    size: int

proc rpcMsgPackQueueWriteHandler*(srv: TcpServerInfo[RpcQueueHandle],
          key: ReadyKey, sourceClient: Socket, qh: RpcQueueHandle) =
  raise newException(OSError, "the request to the OS failed")

proc c_malloc*(n: csize_t): pointer {.importc: "malloc".}
proc c_free*(p: pointer) {.importc: "free".}

proc rpcMsgPackQueueReadHandler*(srv: TcpServerInfo[RpcQueueHandle],
          key: ReadyKey, sourceClient: Socket, qh: RpcQueueHandle) =

  try:
    var msg = sourceClient.recv(qh.router.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      var ibuff = DataBuffer(data: msg.cstring, size: len(msg))
      # var pmsg: ptr DataBuffer = addr(ibuff)
      logi(TAG,"exec rpc handler tosend:addr: %s ", repr(addr(ibuff).pointer))
      logi(TAG,"exec rpc handler tosend:sz: %s ", $(ibuff.size))
      logi(TAG,"exec rpc handler tosend:cdata: %s ", repr(ibuff.data.pointer))
      discard xQueueSend(qh.inQueue, addr(ibuff), TickType_t(1000)) 

      logi(TAG,"exec rpc handler waiting... ")
      delayMillis(10_000)
      logi(TAG,"exec rpc handler receiving... ")

      # var res: cstring
      var pbuff: DataBuffer
      while xQueueReceive(qh.outQueue, addr(pbuff), 0) == 0: 
        logi(TAG,"exec rpc handler wait: %s ", repr(pbuff))
        continue

      logi(TAG,"exec rpc handler got:addr: %s ", repr(addr(pbuff).pointer))
      logi(TAG,"exec rpc handler got:sz: %s ", $(pbuff.size))
      logi(TAG,"exec rpc handler got:cdata: %s ", repr(pbuff.data.pointer))
      # logi(TAG,"exec rpc handler got:ptr %s  ", repr(pbuff.pointer))
      # if pbuff == nil:
        # raise newException(ValueError, "bad data ptr in rpc queue!")

      # var buff: DataBuffer = pbuff[]
      discard sourceClient.send(pbuff.data, pbuff.size)

      logd(TAG,"exec rpc handler sending ")
      # c_free(res)


  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)

proc printNodeAddrs*(node: var JsonNode) =
  # for (k, v) in rcall:
  case node.kind: 
  of JObject:
    logi(TAG,"printNode:node:ptr: %s ", repr(addr(node).pointer))
    for (k, c) in node.mpairs():
      printNodeAddrs(c)
  of JArray:
    logi(TAG,"printNode:node:ptr: %s ", repr(addr(node).pointer))
    for c in node.mitems():
      printNodeAddrs(c)
  of JString, JInt, JFloat, JBool, JNull:
    logi(TAG,"printNode:node:ptr: %s ", repr(addr(node).pointer))


proc handleTask*(qh: ptr RpcQueueHandle) =
  logd(TAG,"exec rpc task wait: ")
  var pmsg = DataBuffer()

  if xQueueReceive(qh.inQueue, addr(pmsg), portMAX_DELAY) != 0: 
    # if pmsg == nil:
      # raise newException(ValueError, "bad data ptr in rpc queue!")

    var msg: string = newString(pmsg.size)
    copyMem(msg.cstring, pmsg.data, pmsg.size)

    logi(TAG,"exec rpc task got rcall:addr: %s ", repr(addr(pmsg).pointer))
    logi(TAG,"exec rpc task got rcall:buff: %s ", repr(pmsg.data.pointer))
    logi(TAG,"exec rpc task got rcall:sz: %s ", $(pmsg.size))

    # var rcall = msgpack2json.toJsonNode(msg)
    var rcall = parseJson(msg)
    logi(TAG,"exec rpc task got rcall:jnode:ptr %s ", repr(addr(rcall).pointer) )
    logi(TAG,"exec rpc task got rcall:jnode: %s ", repr(rcall) )
    printNodeAddrs(rcall)

    var res: JsonNode = qh.router.route(rcall)
    logi(TAG,"exec rpc task result: %s", $(res))

    # var rmsg: string = fromJsonNode(res)
    var rmsg: string = $(res)

    let sz = len(rmsg) + 1
    var crmsg: cstring = cast[cstring](c_malloc(csize_t(sz)))
    copyMem(crmsg, rmsg.cstring(), len(rmsg))
    crmsg[sz-1] = '\0'

    var buff = DataBuffer(data: crmsg, size: sz-1)
    logi(TAG,"exec rpc task send:addr: %s ", repr(addr(buff).pointer))
    logi(TAG,"exec rpc task send:sz: %s ", $(buff.size))
    logi(TAG,"exec rpc task send:cdata: %s ", repr(buff.data.pointer))

    # var pbuff: ptr DataBuffer = addr(buff)
    # logi(TAG,"exec rpc task sent:ptr %s", repr(pbuff.pointer))

    discard xQueueSend(qh.outQueue, addr(buff), TickType_t(100_000)) 
    for i in 0..<3:
      logi(TAG,"exec rpc task sent ............... ")
      delayMillis(1_000)


# Execute RPC Server #
proc execRpcSocketTask*(arg: pointer) {.exportc, cdecl.} =
  var qh: ptr RpcQueueHandle = cast[ptr RpcQueueHandle](arg)

  while true:
    try:
      handleTask(qh)
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
  qh.inQueue = xQueueCreate(1, sizeof(DataBuffer))
  qh.outQueue = xQueueCreate(1, sizeof(DataBuffer))

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

