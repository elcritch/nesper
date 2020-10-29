import json, tables, strutils, macros, options
import net, os
import times
import stats
import sequtils

import nesper/servers/rpc/router

when not defined(TcpJsonRpcServer):
  import msgpack4nim
  import msgpack4nim/msgpack2json

import parseopt

# var p = initOptParser("-ab -e:5 --foo --bar=20 file.txt")
var p = initOptParser()

var showstats = false
var count = 1
var delay = 0
var jsonArg = ""
var ipAddr = ""
var port = Port(5555)
var prettyPrint = false

for kind, key, val in p.getopt():
  case kind
  of cmdArgument:
    jsonArg = key
  of cmdLongOption, cmdShortOption:
    case key
    of "count", "c":
      count = parseInt(val)
    of "ip", "i":
      ipAddr = val
    of "port", "p":
      port = Port(parseInt(val))
    of "stats", "s":
      showstats  = true
    of "delay", "d":
      delay = parseInt(val)
    of "pretty", "q":
      prettyPrint = parseBool(val)
  of cmdEnd: assert(false) # cannot happen

if ipAddr == "":
  # no filename has been given, so we show the help
  raise newException(ValueError, "missing ip address")
  
var totalTime = 0'i64
var totalCalls = 0'i64

template timeBlock(n: string, blk: untyped): untyped =
  let t0 = getTime()
  blk

  let td = getTime() - t0
  echo "[took: ", $(td.inMicroseconds().float() / 1e3), " millis]"
  totalCalls.inc()
  totalTime = totalTime + td.inMicroseconds()
  allTimes.add(td.inMicroseconds())
  

var callDefault = %* { "jsonrpc": "2.0", "id": 1, "method": "add", "params": [1, 2] }

var call: JsonNode

if jsonArg == "":
  call = callDefault
else:
  call = %* { "jsonrpc": "2.0", "id": 1 }

  let m = parseJson(jsonArg)

  for (f,v) in m.pairs():
    call[f] = v

let client: Socket = newSocket(buffered=false)
client.connect(ipAddr, port)
echo("[connected to server]")
echo("[call: ", $call, "]")


var id: int = 1
var allTimes = newSeqOfCap[int64](count)
for i in 0..<count:

  call["id"] = %* id
  inc(id)

  let mcall = 
    when defined(TcpJsonRpcServer):
      $call
    else:
      call.fromJsonNode()

  timeBlock("call"):
    client.send( mcall )

    when not defined(TcpJsonRpcServer):
      var msgLenBytes = client.recv(4, timeout = -1)
      var msgLen: int32 = 0
      echo("[socket data:lenstr: " & repr(msgLenBytes) & "]")
      for i in countdown(3,0):
        msgLen = (msgLen shl 8) or int32(msgLenBytes[i])

      var msg = ""
      while msg.len() < msgLen:
        let mb = client.recv(4*1024, timeout = -1)
        echo("[read bytes: " & $mb.len() & "]")
        msg.add mb
    else:
      var msg = client.recv(4096, timeout = -1)


  echo("[read bytes: " & $msg.len() & "]")
  # echo("[socket data: " & repr(msg) & "]")

  var mnode: JsonNode = 
    when defined(TcpJsonRpcServer):
      msg.parseJson()
    else:
      msg.toJsonNode()

  if prettyPrint:
    echo(pretty(mnode))
  else:
    echo($(mnode))

  when not defined(TcpJsonRpcServer):
    if mnode["result"].kind == JString:
      var res: string = mnode["result"].getStr()
      try:
        var rnode = res.toJsonNode()
        echo("mpack result: " & $rnode)
      except:
        discard "ok"

  if delay > 0:
    os.sleep(delay)


client.close()

echo("\n")

if showstats: 
  echo("[total time: " & $(totalTime.float() / 1e3) & " millis]")
  echo("[total count: " & $(totalCalls) & " No]")
  echo("[avg time: " & $(float(totalTime.float()/1e3)/(1.0 * float(totalCalls))) & " millis]")

  var ss: RunningStat ## Must be "var"
  ss.push(allTimes.mapIt(float(it)/1000.0))

  echo("[mean time: " & $(ss.mean()) & " millis]")
  echo("[max time: " & $(allTimes.max().float()/1_000.0) & " millis]")
  echo("[variance time: " & $(ss.variance()) & " millis]")
  echo("[standardDeviation time: " & $(ss.standardDeviation()) & " millis]")
