import nesper/consts
import nesper/general
import nesper/events
import apps
import volatile
import strutils
import json

import nesper/servers/tcpsocket

proc run_server*() =
  echo "starting server on port 5555"
  var msg = "echo: "
  startSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data=msg)

