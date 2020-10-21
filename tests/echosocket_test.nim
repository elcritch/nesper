import json
import net, os

import msgpack4nim/msgpack2json


# ## Test Call 1 ##
# echo "\n## Call 1 ##"
# var call1 = %* {
#   "jsonrpc": "2.0", "id": 1,
#   "method": "hello", "params": ["world"],
# }

## Test Call 2 ##
echo "\n## Call 2 ##"
var call2 = %* { "jsonrpc": "2.0", "id": 1, "method": "add", "params": [1, 2] }

let client: Socket = newSocket(buffered=false)
client.connect("192.168.1.15", Port(5555))
echo("connected to server")
os.sleep(500)

let mcall2 = call2.fromJsonNode()
echo("mcall2: " & repr(mcall2))
client.send( mcall2 & "\n")

# var msg: string = newString(4096)
# var count = client.recv(msg, 4095)
var msg = client.recv(4095, timeout = -1)
echo("read: " & $msg.len())
echo("read: " & repr(msg))

client.close()
