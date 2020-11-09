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

const TAG = "socketrpc"

type 
  TcpClientDisconnected* = object of OSError
  TcpClientError* = object of OSError

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
      # if sourceClient.getFd() == cfd.getFd():
        # continue
      client.send(data & message & "\r\L")

proc startSocketServer*[T](port: Port, readHandler: TcpServerHandler[T], writeHandler: TcpServerHandler[T], data: var T) =
  var server: Socket = newSocket()
  var select: Selector[T] = newSelector[T]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  server.bindAddr(port)
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