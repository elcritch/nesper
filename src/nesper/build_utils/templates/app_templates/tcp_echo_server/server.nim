import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
import json

const TAG = "server"
const MaxRpcReceiveBuffer {.intdefine.}: int = 4096

import nesper/servers/tcpsocket

proc run_rpc_server*() =
  echo "starting server on port 5555"
  var msg = "echo: "
  startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data=msg)

