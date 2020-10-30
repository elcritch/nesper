import nativesockets, net, selectors, tables, posix

import ../../general
import ../tcpsocket

import router
import json
import msgpack4nim/msgpack2json

export tcpsocket, router

const TAG = "socketrpc"
const MsgChunk {.intdefine.} = 1400

proc sendChunks*(sourceClient: Socket, rmsg: string) =
  let rN = rmsg.len()
  logd(TAG,"rpc handler send client: %d bytes", rN)
  var i = 0
  while i < rN:
    var j = min(i + MsgChunk, rN) 
    logd(TAG,"rpc handler sending: i: %s j: %s ", $i, $j)
    var sl = rmsg[i..<j]
    sourceClient.send(move sl)
    i = j

proc sendLength*(sourceClient: Socket, rmsg: string) =
  var rmsgN: int = rmsg.len()
  var rmsgSz = newString(4)
  for i in 0..3:
    rmsgSz[i] = char(rmsgN and 0xFF)
    rmsgN = rmsgN shr 8

  sourceClient.send(move rmsgSz)

proc rpcMsgPackWriteHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackReadHandler*(srv: TcpServerInfo[RpcRouter], result: ReadyKey, sourceClient: Socket, rt: RpcRouter) =

  try:
    logd(TAG, "rpc server handler: router: %x", rt.buffer)

    var msg = sourceClient.recv(rt.buffer, -1)

    if msg.len() == 0:
      raise newException(TcpClientDisconnected, "")
    else:
      echo("mpack: len: ", $msg.len())
      var rcall = msgpack2json.toJsonNode(move msg)

      var res: JsonNode = rt.route(rcall)
      echo("res: ", $res)
      var rmsg: string = msgpack2json.fromJsonNode(res)

      if res["result"].getStr() == "quit":
        echo("quitting: " )
        raise newException(OSError, "quit")

      echo("sending to client: ", $(sourceClient.getFd().int))
      sourceClient.sendLength(rmsg)
      sourceClient.sendChunks(rmsg)

  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)


proc startRpcSocketServer*(port: Port; router: var RpcRouter) =
  logi(TAG, "starting mpack rpc server: buffer: %s", $router.buffer)

  startSocketServer[RpcRouter](
    port,
    readHandler=rpcMsgPackReadHandler,
    writeHandler=rpcMsgPackWriteHandler,
    data=router)



when isMainModule:

  const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

  var rt = createRpcRouter(MaxRpcReceiveBuffer)

  rpc(rt, "hello") do(input: string) -> string:
    result = "Hello " & input

  rpc(rt, "add") do(a: int, b: int) -> int:
    result = a + b

  rpc(rt, "quit") do() -> string:
    return "quit"

  rpc(rt, "sum") do(args: seq[int]) -> int:
    result = 0
    for v in args:
      result += v

  try:
    startRpcSocketServer(Port(5555), rt)
  except:
    logi(TAG, "exiting")
