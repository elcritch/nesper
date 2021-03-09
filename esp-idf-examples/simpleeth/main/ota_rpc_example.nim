import json, tables, strutils, macros, options
import net, os, streams
import times
import stats

import msgpack4nim/msgpack2json
import parseopt

import std/sha1

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


var firmware_binary = ""
var ipAddr = ""
var forceUpload = false
var port = Port(5555)
var prettyPrint = false

for kind, key, val in p.getopt():
  case kind
  of cmdArgument:
    firmware_binary = key
  of cmdLongOption, cmdShortOption:
    case key
    of "ip", "i":
      ipAddr = val
    of "force", "f":
      forceUpload = parseBool(val)
    of "port", "p":
      port = Port(parseInt(val))
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
  

var
  id: int = 0

const RPC_TIMEOUT = 30_000

proc execRpc(client: Socket, i: var int, call: JsonNode, quiet=false): JsonNode = 
  {.cast(gcsafe).}:
    call["id"] = %* id
    call["jsonrpc"] = %* "2.0"
    inc(id)

    let mcall = 
      when defined(TcpJsonRpcServer):
        $call
      else:
        call.fromJsonNode()

    timeBlock("call"):
      client.send( mcall )
      var msgLenBytes = client.recv(4)
      var msgLen: int32 = 0

      if msgLenBytes.len() == 0: return
      for i in countdown(3,0):
        msgLen = (msgLen shl 8) or int32(msgLenBytes[i])

      var msg = ""
      while msg.len() < msgLen:
        let mb = client.recv(4*1024)
        msg.add mb

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

    mnode

const BUFF_SZ* = 1024

# proc sha1_hash*(val: string, hash: string) =
    # let sh = $secureHash(val)
    # if sh != hash:
      # raise newException(ValueError, "incorrect hash")

proc runFirmwareRpc(fw_strm: Stream) = 
  {.cast(gcsafe).}:

    var client: Socket = newSocket(buffered=false)
    client.connect(ipAddr, port)
    echo(yellow, "[connected to server ip addr: ", ipAddr,"]")

    echo blue, "Uploaded Firmware header..."
    let
      hdr_chunk = fw_strm.readStr(BUFF_SZ)
      hdr_sh1 = $secureHash(hdr_chunk)
      hdr_chunk_call: JsonNode = %* {"method": "firmware-begin", "params": [hdr_chunk, hdr_sh1]}
    
    echo blue, "hdr chunk call: len: ", $hdr_chunk.len(), " sha1: ", $hdr_chunk_call["params"][1]
    let
      hdr_res_node: JsonNode = client.execRpc(id, hdr_chunk_call)

    echo blue, "WARNING: chunk_len: " & " result: " & $hdr_res_node

    let res = to(hdr_res_node["result"], seq[string])
    if res[0] != "ok":
      if forceUpload:
        echo yellow, "Warning: trying to upload incorrect firmware version: " & $res[1]
      else:
        raise newException(ValueError, "trying to upload incorrect firmware version: " & $res[1])

    while not fw_strm.atEnd():
      let chunk = fw_strm.readStr(BUFF_SZ)
      let chunk_sh1 = $secureHash(chunk)

      echo blue, "Uploading bytes: " & $(chunk.len())
      # This only works with MsgPack as written since the strings are raw binary -- you'd need base64 encoding to use JSON
      let
        chunk_res_node = client.execRpc(id, %* {"method": "firmware-chunk", "params": [chunk, chunk_sh1, id]}, quiet=true)
        chunk_res = to(chunk_res_node["result"], int)
      
      echo yellow, "Uploaded bytes: " & $chunk_res

    let
      fnl_res_node = client.execRpc(id, %* {"method": "firmware-finish", "params": ["0"]})
      fnl_res = to(fnl_res_node, int)

    echo yellow, "Uploaded total bytes: " & $fnl_res

    echo red, "Rebooting..." & $fnl_res
    try:
      discard client.execRpc(id, %* {"method": "espReboot", "params": []}, quiet=false)
    except:
      discard "expect timeout..."

    client.close()

    sleep(15_000)

    client = newSocket(buffered=false)
    client.connect(ipAddr, port)
    echo(yellow, "[connected to server ip addr: ", ipAddr,"]")

    echo blue, "Uploaded Firmware header..."
    let
      finalizer_res: JsonNode = client.execRpc(id, %* {"method": "firmware-verify", "params": []})

    echo("finalized: ", $finalizer_res)

    echo("\n")


echo "Checking Firmware file: " & firmware_binary 

if not firmware_binary.endsWith(".bin"):
  echo "Firmware file doesn't end with `.bin`"
  quit(1)

if not firmware_binary.fileExists():
  echo "Firmware file doesn't exist!"

var fw_strm = newFileStream(firmware_binary, fmRead)

runFirmwareRpc(fw_strm)
