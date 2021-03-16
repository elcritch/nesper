import json, tables, strutils, macros, options
import net, os, times, stats
import sequtils, locks

import parseopt

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

type
  RpcCli = object
    showstats: bool
    count: int
    delay: int
    jsonArg: string
    ipAddr: string
    port: Port
    prettyPrint: bool
    quiet: bool
    totalTime: int64
    totalCalls: int64
    id: int 
    allTimes: seq[int64]

proc rpcOptions*(p: var OptParser): RpcCli = 
  result = RpcCli()

  result.showstats = false
  result.count = 1
  result.delay = 0
  result.quiet = false
  result.jsonArg = ""
  result.ipAddr = ""
  result.port = Port(5555)
  result.prettyPrint = false
  result.id = 1

  for kind, key, val in p.getopt():
    case kind
    of cmdArgument:
      result.jsonArg = key
    of cmdLongOption, cmdShortOption:
      case key
      of "count", "c":
        result.count = parseInt(val)
      of "ip", "i":
        result.ipAddr = val
      of "port", "p":
        result.port = Port(parseInt(val))
      of "stats", "s":
        result.showstats  = true
      of "delay", "d":
        result.delay = parseInt(val)
      of "pretty", "q":
        result.prettyPrint = parseBool(val)
    of cmdEnd: assert(false) # cannot happen

  echo "args: ", $result

  if result.ipAddr == "":
    # no filename has been given, so we show the help
    raise newException(ValueError, "missing ip address")

  result.allTimes = newSeqOfCap[int64](result.count)

  # Check IP address
  try:
    discard parseIpAddress(result.ipAddr)
  except CatchableError as err:
    echo "invalid IP address, check the --ip:$IP argument"
    raise err
    
template timeBlock*(n: string, args: RpcCli, blk: untyped): untyped =
  let t0 = getTime()
  blk

  let td = getTime() - t0
  echo grey, "[took: ", $(td.inMicroseconds().float() / 1e3), " millis]"
  args.totalCalls.inc()
  args.totalTime = args.totalTime + td.inMicroseconds()
  args.allTimes.add(td.inMicroseconds())
  

when RpcServerType == "json":
  proc execRpc*(args: var RpcCli, client: Socket, i: int, call: JsonNode): JsonNode = 
    call["id"] = %* args.id
    inc(args.id)

    let mcall = 
        $call

    timeBlock("call", args):
      client.send( mcall )
      var msg = client.recv(4096, timeout = -1)

    # echo("[socket data: " & repr(msg) & "]")

    if not args.quiet:
      echo grey, "[read bytes: " & $msg.len() & "]"

    result = msg.parseJson()

    if not args.quiet:
      echo()
      if args.prettyPrint:
        echo(blue, pretty(result))
      else:
        echo(blue, $(result))

    if not args.quiet:
      echo green, "[rpc done at " & $now() & "]"
    if args.delay > 0:
      os.sleep(args.delay)

elif RpcServerType == "mpack":
  proc execRpc*(args: var RpcCli, client: Socket, i: int, call: JsonNode): JsonNode = 
    call["id"] = %* args.id
    inc(args.id)

    let mcall = 
        $call

    timeBlock("call", args):
      client.send( mcall )
      var msgLenBytes = client.recv(4, timeout = -1)
      var msgLen: int32 = 0
      if msgLenBytes.len() == 0: return
      for i in countdown(3,0):
        msgLen = (msgLen shl 8) or int32(msgLenBytes[i])

      var msg = ""
      while msg.len() < msgLen:
        let mb = client.recv(4*1024, timeout = -1)
        msg.add mb

    # echo("[socket data: " & repr(msg) & "]")
    if not args.quiet:
      echo grey, "[read bytes: " & $msg.len() & "]"

    result = msg.toJsonNode()

    if not args.quiet:
      echo()
      if args.prettyPrint:
        echo(blue, pretty(result))
      else:
        echo(blue, $(result))

    if not args.quiet:
      echo green, "[rpc done at " & $now() & "]"
    if args.delay > 0:
      os.sleep(args.delay)

proc runRpc*(args: var RpcCli) = 
  var call: JsonNode
  if args.jsonArg == "":
    call = %* { "jsonrpc": "2.0", "id": 1, "method": "add", "params": [1, 2] }
  else:
    call = %* { "jsonrpc": "2.0", "id": 1 }

  let m = parseJson(args.jsonArg)

  for (f,v) in m.pairs():
    call[f] = v

  let client: Socket = newSocket(buffered=false)
  client.connect(args.ipAddr, args.port)
  echo(yellow, "[connected to server ip addr: ", args.ipAddr,"]")
  echo(blue, "[call: ", $call, "]")

  for i in 1..args.count:
    discard args.execRpc(client, i, call)
  client.close()

  echo("\n")

  if args.showstats: 
    echo("[total time: " & $(args.totalTime.float() / 1e3) & " millis]", magenta)
    echo("[total count: " & $(args.totalCalls) & " No]", magenta)
    echo("[avg time: " & $(float(args.totalTime.float()/1e3)/(1.0 * float(args.totalCalls))) & " millis]", magenta)

    var ss: RunningStat ## Must be "var"
    ss.push(args.allTimes.mapIt(float(it)/1000.0))

    echo("[mean time: " & $(ss.mean()) & " millis]", magenta)
    echo("[max time: " & $(args.allTimes.max().float()/1_000.0) & " millis]", magenta)
    echo("[variance time: " & $(ss.variance()) & " millis]", magenta)
    echo("[standardDeviation time: " & $(ss.standardDeviation()) & " millis], magenta")


# runRpc()
  
