import nativesockets
import net
import selectors
import tables
import posix

import ../consts
import ../general
import ../tasks
import ../timers

export net, selectors, tables, posix

export consts, general, timers

const
  TAG = "socketrpc"
  MsgChunk {.intdefine.} = 1400

type 
  TcpClientDisconnected* = object of OSError
  TcpClientError* = object of OSError

template sendWrap*(socket: Socket, data: untyped) =
  # Checks for disconnect errors when sending
  # This makes it easy to handle dirty disconnects
  try:
    socket.send(data)
  except OSError as err:
    if err.errorCode == ENOTCONN:
      var etcp = newException(TcpClientDisconnected, "")
      etcp.errorCode = err.errorCode
      raise etcp
    else:
      raise err


proc sendChunks*(sourceClient: Socket, rmsg: string) =
  let rN = rmsg.len()
  # logd(TAG,"rpc handler send client: %d bytes", rN)
  var i = 0
  while i < rN:
    var j = min(i + MsgChunk, rN) 
    # logd(TAG,"rpc handler sending: i: %s j: %s ", $i, $j)
    var sl = rmsg[i..<j]
    sourceClient.sendWrap(move sl)
    i = j

proc sendLength*(sourceClient: Socket, rmsg: string) =
  var rmsgN: int = rmsg.len()
  var rmsgSz = newString(4)
  for i in 0..3:
    rmsgSz[i] = char(rmsgN and 0xFF)
    rmsgN = rmsgN shr 8

  sourceClient.sendWrap(move rmsgSz)

type 

  TcpServerInfo*[T] = ref object 
    select*: Selector[T]
    server*: Socket
    clients*: ref Table[SocketHandle, Socket]
    writeHandler*: TcpServerHandler[T]
    readHandler*: TcpServerHandler[T]

  TcpServerHandler*[T] = proc (srv: TcpServerInfo[T], selected: ReadyKey, client: Socket, data: T) {.nimcall.}


proc createServerInfo[T](server: Socket, selector: Selector[T]): TcpServerInfo[T] = 
  result = new(TcpServerInfo[T])
  result.server = server
  result.select = selector
  result.clients = newTable[SocketHandle, Socket]()

proc processWrites[T](selected: ReadyKey, srv: TcpServerInfo[T], data: T) = 
  var sourceClient: Socket = newSocket(SocketHandle(selected.fd))
  let data = getData(srv.select, selected.fd)
  if srv.writeHandler != nil:
    srv.writeHandler(srv, selected, sourceClient, data)

proc processReads[T](selected: ReadyKey, srv: TcpServerInfo[T], data: T) = 
  if SocketHandle(selected.fd) == srv.server.getFd():
    var client: Socket = new(Socket)
    srv.server.accept(client)

    client.getFd().setBlocking(false)
    srv.select.registerHandle(client.getFd(), {Event.Read}, data)
    srv.clients[client.getFd()] = client

    let id: int = client.getFd().int
    logd(TAG, "client connected: %d", id)

  elif srv.clients.hasKey(SocketHandle(selected.fd)):
    let sourceClient: Socket = newSocket(SocketHandle(selected.fd))
    let sourceFd = selected.fd
    let data = getData(srv.select, sourceFd)

    try:
      if srv.readHandler != nil:
        srv.readHandler(srv, selected, sourceClient, data)

    except TcpClientDisconnected as err:
      var client: Socket
      discard srv.clients.pop(sourceFd.SocketHandle, client)
      srv.select.unregister(sourceFd)
      discard posix.close(sourceFd.cint)
      logd(TAG, "client disconnected: fd: %s", $sourceFd)

    except TcpClientError as err:
      srv.clients.del(sourceFd.SocketHandle)
      srv.select.unregister(sourceFd)

      discard posix.close(sourceFd.cint)
      logd(TAG, "client read error: %s", $(sourceFd))

  else:
    raise newException(OSError, "unknown socket id: " & $selected.fd.int)


proc echoReadHandler*(srv: TcpServerInfo[string], result: ReadyKey, sourceClient: Socket, data: string) =
  var message = sourceClient.recvLine()

  if message == "":
    raise newException(TcpClientDisconnected, "")

  else:
    logd(TAG, "received from client: %s", message)

    for cfd, client in srv.clients:
      client.sendWrap(data & message & "\r\L")

proc startSocketServer*[T](port: Port, address: string = "", readHandler: TcpServerHandler[T], writeHandler: TcpServerHandler[T], data: var T) =
  var server: Socket = newSocket()
  var select: Selector[T] = newSelector[T]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  server.bindAddr(port, address=address)
  server.listen()

  logi TAG, "Server: started. Listening to new connections on port: %s", $port

  var srv = createServerInfo[T](server, select)
  srv.readHandler = readHandler
  srv.writeHandler = writeHandler

  select.registerHandle(server.getFd(), {Event.Read}, data)
  
  while true:
    var results: seq[ReadyKey] = select.select(-1)
  
    for result in results:
      if Event.Read in result.events:
          result.processReads(srv, data)
      if Event.Write in result.events:
          result.processWrites(srv, data)
      # taskYIELD()
    # delayMillis(1)
    vTaskDelay(1.TickType_t)

  
  select.close()
  server.close()

when isMainModule:
  startSocketServer(Port(5555), readHandler=echoReadHandler, writeHandler=nil)