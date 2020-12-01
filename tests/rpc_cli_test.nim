import json, tables, strutils, macros, options
import net, os
import times
import stats
import sequtils
import locks
import times

import nesper/servers/rpc/router

when not defined(TcpJsonRpcServer):
  import msgpack4nim
  import msgpack4nim/msgpack2json

import parseopt

# var p = initOptParser("-ab -e:5 --foo --bar=20 file.txt")
var p = initOptParser()

type
  CliColors = enum
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    grey

proc echo*(color: CliColors, text: varargs[string]) =
  case color:
  of black:
    stdout.write "\e[30m"
  of red:
    stdout.write "\e[31m"
  of green:
    stdout.write "\e[32m"
  of yellow:
    stdout.write "\e[33m"
  of grey:
    stdout.write "\e[90m"
  of blue:
    stdout.write "\e[34m"
  of magenta:
    stdout.write "\e[35m"
  of cyan:
    stdout.write "\e[36m"

  stdout.write text
  stdout.write "\e[0m\n"
  stdout.flushFile()


var showstats = false
var count = 1
var delay = 0
var jsonArg = ""
var ipAddr = ""
var port = Port(30720)
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

# Check IP address
try:
  discard parseIpAddress(ipAddr)
except CatchableError as err:
  echo "invalid IP address, check the --ip:$IP argument"
  raise err
  
var totalTime = 0'i64
var totalCalls = 0'i64

template timeBlock(n: string, blk: untyped): untyped =
  let t0 = getTime()
  blk

  let td = getTime() - t0
  echo grey, "[took: ", $(td.inMicroseconds().float() / 1e3), " millis]"
  totalCalls.inc()
  totalTime = totalTime + td.inMicroseconds()
  allTimes.add(td.inMicroseconds())
  


var
  id: int = 1
  allTimes = newSeqOfCap[int64](count)
  xmllock: Lock
  xmlWorker: Thread[void]


proc execRpc(client: Socket, i: int, call: JsonNode, quiet=false): JsonNode = 
  {.cast(gcsafe).}:
    call["id"] = %* id
    inc(id)

    let mcall = 
      when defined(TcpJsonRpcServer):
        $call
      else:
        call.fromJsonNode()

    timeBlock("call"):
      client.send( mcall )
      var msgLenBytes = client.recv(4, timeout = -1)
      var msgLen: int32 = 0
      # echo grey, "[socket data:lenstr: " & repr(msgLenBytes) & "]"
      if msgLenBytes.len() == 0: return
      for i in countdown(3,0):
        msgLen = (msgLen shl 8) or int32(msgLenBytes[i])

      var msg = ""
      while msg.len() < msgLen:
        let mb = client.recv(4*1024, timeout = -1)
        # echo("[read bytes: " & $mb.len() & "]")
        # if msg.len() == 0:
          # return
        msg.add mb

    # echo("[socket data: " & repr(msg) & "]")

    if not quiet:
      echo grey, "[read bytes: " & $msg.len() & "]"

    var mnode = 
      when defined(TcpJsonRpcServer):
        msg
      else:
        msg.toJsonNode()

    if not quiet:
      echo()
      if prettyPrint:
        echo(blue, pretty(mnode))
      else:
        echo(blue, $(mnode))

    if mnode.hasKey("result") and mnode["result"].kind == JString:
      var res: string = mnode["result"].getStr()
      try:
        var rnode = res.toJsonNode()
        # echo(grey, "mpack result: " & $rnode)
      except:
        discard "ok"

    if not quiet:
      echo green, "[rpc done at " & $now() & "]"
    if delay > 0:
      os.sleep(delay)

    mnode

proc runRpc() = 
  {.cast(gcsafe).}:
    var call: JsonNode
    if jsonArg == "":
      call = %* { "jsonrpc": "2.0", "id": 1, "method": "add", "params": [1, 2] }
    else:
      call = %* { "jsonrpc": "2.0", "id": 1 }

    let m = parseJson(jsonArg)

    for (f,v) in m.pairs():
      call[f] = v

    let client: Socket = newSocket(buffered=false)
    client.connect(ipAddr, port)
    echo(yellow, "[connected to server ip addr: ", ipAddr,"]")
    echo(blue, "[call: ", $call, "]")

    if port == Port(30720):
      let hn_res = client.execRpc(0, %* { "jsonrpc": "2.0", "id": 0, "method": "sensor-hostname", "params": []}, quiet=true)
      echo(yellow, "[server hostname: ", $hn_res["result"], "]")

    for i in 1..count:
      discard client.execRpc(i, call)
    client.close()

    echo("\n")


runRpc()
  
if showstats: 
  echo("[total time: " & $(totalTime.float() / 1e3) & " millis]", magenta)
  echo("[total count: " & $(totalCalls) & " No]", magenta)
  echo("[avg time: " & $(float(totalTime.float()/1e3)/(1.0 * float(totalCalls))) & " millis]", magenta)

  var ss: RunningStat ## Must be "var"
  ss.push(allTimes.mapIt(float(it)/1000.0))

  echo("[mean time: " & $(ss.mean()) & " millis]", magenta)
  echo("[max time: " & $(allTimes.max().float()/1_000.0) & " millis]", magenta)
  echo("[variance time: " & $(ss.variance()) & " millis]", magenta)
  echo("[standardDeviation time: " & $(ss.standardDeviation()) & " millis], magenta")

const pthreadh = "#define _GNU_SOURCE\n#include <pthread.h>"
proc pthread_cancel(a1: SysThread): cint {.importc: "pthread_cancel", header: pthreadh.}
