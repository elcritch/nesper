import json, tables, strutils, macros, options
import net, os
import times
import stats
import sequtils


when not defined(TcpJsonRpcServer):
  import msgpack4nim/msgpack2json

import parseopt

# var p = initOptParser("-ab -e:5 --foo --bar=20 file.txt")
var p = initOptParser()

var count = 1
var jsonArg = ""
var ipAddr = ""
var port = Port(5555)

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
client.connect(ipAddr, Port(5555))
echo("[connected to server]")
echo("[call: ", $call, "]")

when defined(TcpJsonRpcServer):
  let mcall = $call
else:
  let mcall = call.fromJsonNode()


var allTimes = newSeqOfCap[int64](count)
for i in 0..<count:

  timeBlock("call"):
    client.send( mcall )
    var msg = client.recv(16*1024, timeout = -1)

  echo("[read bytes: " & $msg.len() & "]")
  when defined(TcpJsonRpcServer):
    echo($msg)
  else:
    echo($(msg.toJsonNode()))


client.close()

echo("\n")
echo("[total time: " & $(totalTime.float() / 1e3) & " millis]")
echo("[total count: " & $(totalCalls) & " No]")
echo("[avg time: " & $(float(totalTime.float()/1e3)/(1.0 * float(totalCalls))) & " millis]")

var ss: RunningStat ## Must be "var"
ss.push(allTimes.mapIt(float(it)/1000.0))

echo("[mean time: " & $(ss.mean()) & " millis]")
echo("[variance time: " & $(ss.variance()) & " millis]")
