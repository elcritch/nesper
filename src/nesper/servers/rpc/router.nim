import json, tables, strutils, macros, options
import sequtils

import marshal

export marshal
## Code copied from: status-im/nim-json-rpc is licensed under the Apache License 2.0

type
  JsonRpcCall* = object
    jsonrpc*: string
    `method`*: string
    params*: JsonNode
    id*: int

type
  RpcJsonError* = enum
    rjeInvalidJson, rjeVersionError, rjeNoMethod, rjeNoId, rjeNoParams, rjeNoJObject
  RpcJsonErrorContainer* = tuple[err: RpcJsonError, msg: string]

  # Procedure signature accepted as an RPC call by server
  RpcProc* = proc(input: JsonNode): JsonNode {.gcsafe.}

  RpcProcError* = object of ValueError
    code*: int
    data*: JsonNode

  RpcBindError* = object of ValueError
  RpcAddressUnresolvableError* = object of ValueError

  RpcRouter* = ref object
    procs*: Table[string, RpcProc]
    buffer*: int

proc wrapResponse*(rpcCall: JsonRpcCall, ret: JsonNode): JsonNode = 
  result = %* {"jsonrpc": "2.0", "result": ret, "id": rpcCall.id}

proc wrapError*(rpcCall: JsonRpcCall, code: int, message: string): JsonNode = 
  result = %* {
    "jsonrpc": "2.0",
    "error": { "code": code, "message": message, },
    "id": rpcCall.id
  }

proc rpcParseError*(): JsonNode = 
  result = %* {
    "jsonrpc": "2.0",
    "error": { "code": -32700, "message": "Parse error" },
    "id": nil
  }

proc rpcInvalidRequest*(detail: string): JsonNode = 
  result = %* {
    "jsonrpc": "2.0",
    "error": { "code": -32600, "message": "Invalid request", "detail": detail },
    "id": nil
  }

proc rpcInvalidRequest*(id: int, detail: string): JsonNode = 
  result = %* {
    "jsonrpc": "2.0",
    "error": { "code": -32600, "message": "Invalid request", "detail": detail },
    "id": id
  }


const
  methodField = "method"
  paramsField = "params"
  jsonRpcField = "jsonrpc"
  idField = "id"
  messageTerminator = "\c\l"

  JSON_PARSE_ERROR* = -32700
  INVALID_REQUEST* = -32600
  METHOD_NOT_FOUND* = -32601
  INVALID_PARAMS* = -32602
  INTERNAL_ERROR* = -32603
  SERVER_ERROR* = -32000

  defaultMaxRequestLength* = 1024 * 128
  jsonErrorMessages*: array[RpcJsonError, (int, string)] =
    [
      (JSON_PARSE_ERROR, "Invalid JSON"),
      (INVALID_REQUEST, "JSON 2.0 required"),
      (INVALID_REQUEST, "No method requested"),
      (INVALID_REQUEST, "No id specified"),
      (INVALID_PARAMS, "No parameters specified"),
      (INVALID_PARAMS, "Invalid request object")
    ]

proc createRpcRouter*(max_buffer: int): RpcRouter =
  result = new(RpcRouter)
  result.procs = initTable[string, RpcProc]()
  result.buffer = max_buffer
  echo "createRpcRouter: " & $(result.buffer)

proc register*(router: var RpcRouter, path: string, call: RpcProc) =
  router.procs[path] = call

proc clear*(router: var RpcRouter) = router.procs.clear

proc hasMethod*(router: RpcRouter, methodName: string): bool = router.procs.hasKey(methodName)

func isEmpty(node: JsonNode): bool = node.isNil or node.kind == JNull

# Json reply wrappers

proc wrapReply*(id: JsonNode, value: JsonNode): JsonNode =
  return %* {"jsonrpc":"2.0", "id": id, "result": value}

proc wrapReplyError*(id: JsonNode, error: JsonNode): JsonNode =
  return %* {"jsonrpc":"2.0", "id": id, "error": error}

proc wrapError*(code: int, msg: string, id: JsonNode,
                data: JsonNode = newJNull(), err: ref Exception = nil): JsonNode {.gcsafe.} =
  # Create standardised error json
  result = %* { "code": code,"id": id,"message": escapeJson(msg),"data":data }
  if err != nil:
    result["stacktrace"] = %* err.getStackTraceEntries().mapIt($it)
  echo "Error generated: ", "result: ", result, " id: ", id

template wrapException(body: untyped) =
  try:
    body
  except: 
    let msg = getCurrentExceptionMsg()
    echo("control server: invalid input: error: ", msg)
    let resp = rpcInvalidRequest(msg)
    return resp


proc route*(router: RpcRouter, node: JsonNode): JsonNode {.gcsafe.} =
  ## Assumes correct setup of node
  let
    methodName = node[methodField].str
    id = node[idField]
    rpcProc = router.procs.getOrDefault(methodName)

  if rpcProc.isNil:
    let
      methodNotFound = %(methodName & " is not a registered RPC method.")
      error = wrapError(METHOD_NOT_FOUND, "Method not found", id, methodNotFound)
    result = wrapReplyError(id, error)
  else:
    try:
      let jParams = node[paramsField]
      let res = rpcProc(jParams)
      result = wrapReply(id, res)
    except CatchableError as err:
      # echo "Error occurred within RPC", " methodName: ", methodName, "errorMessage = ", err.msg
      let error = wrapError(SERVER_ERROR, methodName & " raised an exception",
                            id, % err.msg, err)
      result = wrapReplyError(id, error)

proc makeProcName(s: string): string =
  result = ""
  for c in s:
    if c.isAlphaNumeric: result.add c

proc hasReturnType(params: NimNode): bool =
  if params != nil and params.len > 0 and params[0] != nil and
     params[0].kind != nnkEmpty:
    result = true

macro rpc*(server: RpcRouter, path: string, body: untyped): untyped =
  ## Define a remote procedure call.
  ## Input and return parameters are defined using the ``do`` notation.
  ## For example:
  ## .. code-block:: nim
  ##    myServer.rpc("path") do(param1: int, param2: float) -> string:
  ##      result = $param1 & " " & $param2
  ##    ```
  ## Input parameters are automatically marshalled from json to Nim types,
  ## and output parameters are automatically marshalled to json for transport.
  result = newStmtList()
  let
    parameters = body.findChild(it.kind == nnkFormalParams)
    # all remote calls have a single parameter: `params: JsonNode`
    paramsIdent = newIdentNode"params"
    # procs are generated from the stripped path
    pathStr = $path
    # strip non alphanumeric
    procNameStr = pathStr.makeProcName
    # public rpc proc
    procName = newIdentNode(procNameStr)
    # when parameters present: proc that contains our rpc body
    doMain = newIdentNode(procNameStr & "DoMain")
    # async result
    # res = newIdentNode("result")
    # errJson = newIdentNode("errJson")
  var
    setup = jsonToNim(parameters, paramsIdent)
    procBody = if body.kind == nnkStmtList: body else: body.body

  let ReturnType = if parameters.hasReturnType: parameters[0]
                   else: ident "JsonNode"

  # delegate async proc allows return and setting of result as native type
  result.add quote do:
    proc `doMain`(`paramsIdent`: JsonNode): `ReturnType` =
      {.cast(gcsafe).}:
        `setup`
        `procBody`

  if ReturnType == ident"JsonNode":
    # `JsonNode` results don't need conversion
    result.add quote do:
      proc `procName`(`paramsIdent`: JsonNode): JsonNode {.gcsafe.} =
        return `doMain`(`paramsIdent`)
  else:
    result.add quote do:
      proc `procName`(`paramsIdent`: JsonNode): JsonNode {.gcsafe.} =
        return %* `doMain`(`paramsIdent`)


  result.add quote do:
    `server`.register(`path`, `procName`)

  when defined(nimDumpRpcs):
    echo "\n", pathStr, ": ", result.repr
