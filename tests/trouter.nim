import json, tables, strutils, macros, options

import nesper/utils/router

type
    MyObject = object
        id: int
        name: string

# Setup RPC Server #
var rt1 = newRpcRouter()

rt1.rpc("hello") do(input: string) -> string:
    result = "Hello " & input

rt1.rpc("add") do(a: int, b: int) -> int:
    result = a + b


## Test Call 1 ##
var call1 = %* {
    "jsonrpc": "2.0", "id": 1,
    "method": "hello", "params": ["world"],
}
var res1 = rt1.route( call1 )
echo "\nResult 1: "
echo res1

## Test Call 2 ##
var call2 = %* {
    "jsonrpc": "2.0", "id": 1,
    "method": "add", "params": [1, 2],
}
var res2 = rt1.route( call2 )
echo "\nResult 2: "
echo res2

## Test Call 3: incorrect arguments ##
var call3 = %* {
    "jsonrpc": "2.0", "id": 1,
    "method": "add", "params": ["abc", "def"],
}
var res3 = rt1.route( call3 )
echo "\nResult 3: "
echo res3
