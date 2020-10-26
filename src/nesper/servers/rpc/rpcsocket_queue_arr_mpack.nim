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
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"

var queue_data: seq[JsonNode]

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
      var ridx = 0
      var rcall = msgpack2json.toJsonNode(msg)
      queue_data[ridx] = move(rcall)
      rcall = JsonNode()
      
      discard xQueueSend(qh.inQueue, addr(ridx), TickType_t(1000)) 

      var pidx: int
      while xQueueReceive(qh.outQueue, addr(pidx), 0) == 0: 
        continue

      var res: JsonNode = queue_data[1]
      # logi(TAG,"exec rpc handler got:pidx: %s", repr(pidx))
      # logi(TAG,"exec rpc handler got:res: %s", $(res))

      var rmsg: string = msgpack2json.fromJsonNode(res)
      sourceClient.send(move rmsg)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)


proc handleTaskRpc*(qh: ptr RpcQueueHandle) =
  logd(TAG,"exec rpc task wait: ")
  var ridx: int
  if xQueueReceive(qh.inQueue, addr(ridx), portMAX_DELAY) != 0: 
    logi(TAG,"exec rpc task got: %s", repr(ridx))

    var rcall = move queue_data[0]
    queue_data[0] = JsonNode()
    # logi(TAG,"exec rpc task got: %s", repr(rcall))

    var res: JsonNode = qh.router.route(rcall)

    # logi(TAG,"exec rpc task send: %s", repr(addr(res).pointer))
    queue_data[1] = move res
    res = JsonNode()
    
    var pidx = 1
    discard xQueueSend(qh.outQueue, addr(pidx), TickType_t(1_000)) 

    logi(TAG,"exec rpc task sent: ")
    # wasMoved(res)

# Execute RPC Server #
proc execRpcSocketTask*(arg: pointer) {.exportc, cdecl.} =
  var qh: ptr RpcQueueHandle = cast[ptr RpcQueueHandle](arg)

  while true:
    try:
      timeBlockDebug("rpcTask"):
        handleTaskRpc(qh)
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
  qh.inQueue = xQueueCreate(1, sizeof(int))
  qh.outQueue = xQueueCreate(1, sizeof(int))
  queue_data = newSeq[JsonNode](2)

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

