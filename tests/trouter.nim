import json, tables, strutils, macros, options

import nesper/servers/rpc/router

type
  MyObject = object
    id: int
    name: string

# Setup RPC Server #
var rt1 = createRpcRouter(4096)

rt1.rpc("hello") do(input: string) -> string:
  result = "Hello " & input

rt1.rpc("add") do(a: int, b: int) -> int:
  result = a + b


## Test Call 1 ##
echo "\n## Call 1 ##"
var call1 = %* {
  "jsonrpc": "2.0", "id": 1,
  "method": "hello", "params": ["world"],
}
var res1 = rt1.route( call1 )
echo "Result 1: "
echo res1
assert res1["result"].getStr() == "Hello world"

## Test Call 2 ##
echo "\n## Call 2 ##"
var call2 = %* { "jsonrpc": "2.0", "id": 1, "method": "add", "params": [1, 2], }

echo "arg call2: " & $call2
var res2 = rt1.route( call2 )
echo "Result 2: "
echo res2
assert res2["result"].getInt() == 3


## Test Call 3: incorrect arguments ##
echo "\n## Call 3 ##"
let err_res = %* {
  "jsonrpc": "2.0",
  "id": 1,
  "error": { 
    "code": -32000,
    "id": 1,
    "message": "\"add raised an exception\"",
    "data": "Parameter [a] expected JInt but got JString"
  }
}

var call3 = %* {
  "jsonrpc": "2.0", "id": 1,
  "method": "add", "params": ["abc", "def"],
}
var res3 = rt1.route( call3 )
echo "Result 3: "
echo res3
assert res3 == err_res
