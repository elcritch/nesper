import nativesockets
import net
import selectors
import tables
import posix

import ../consts
import ../general

export net

const TAG = "socketrpc"

type 
  TcpServerInfo* = ref object 
    select*: Selector[int]
    server*: Socket
    clients*: ref Table[SocketHandle, Socket]
    writeHandler*: TcpServerHandler
    readHandler*: TcpServerHandler

  TcpServerHandler* = proc (srv: TcpServerInfo, selected: ReadyKey, client: Socket) {.nimcall.}


proc createServerInfo(server: Socket, selector: Selector[int]): TcpServerInfo = 
  result = new(TcpServerInfo)
  result.server = server
  result.select = selector
  result.clients = newTable[SocketHandle, Socket]()

proc processWrites(selected: ReadyKey, srv: TcpServerInfo) = 
  var sourceClient: Socket = newSocket(selected.fd.SocketHandle)
  if srv.writeHandler != nil:
    srv.writeHandler(srv, selected, sourceClient)

proc processReads(selected: ReadyKey, srv: TcpServerInfo) = 
  if selected.fd.SocketHandle == srv.server.getFd():
    var client: Socket = new(Socket)
    srv.server.accept(client)

    client.getFd().setBlocking(false)
    srv.select.registerHandle(client.getFd(), {Event.Read}, -1)
    srv.clients[client.getFd()] = client
    logi(TAG, "Server: client connected")

  elif srv.clients.hasKey(selected.fd.SocketHandle):
    var sourceClient: Socket = newSocket(selected.fd.SocketHandle)
    if srv.readHandler != nil:
      srv.readHandler(srv, selected, sourceClient)

  else:
    raise newException(OSError, "control server: error: unknown socket id: " & $selected.fd.int)


proc echoReadHandler*(srv: TcpServerInfo, result: ReadyKey, sourceClient: Socket) {.nimcall.} =
  var message = sourceClient.recvLine()

  if message == "":
    var client: Socket
    discard srv.clients.pop(sourceClient.getFd(), client)
    srv.select.unregister(sourceClient.getFd())
    logi(TAG, "Server: client disconnected: %s", $(sourceClient.getFd().getSockName()))

  else:
    logd TAG, "Server: received from client: %s", message

    for cfd, client in srv.clients:
      # if sourceClient.getFd() == cfd.getFd():
        # continue
      client.send(message & "\r\L")

proc startSocketServer*(port: Port, readHandler: TcpServerHandler, writeHandler: TcpServerHandler) =
  var server: Socket = newSocket()
  var select: Selector[int] = newSelector[int]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  server.bindAddr(port)
  server.listen()

  logi TAG, "Server: started. Listening to new connections on port: %s", $port

  var srv = createServerInfo(server, select)
  srv.readHandler = readHandler
  srv.writeHandler = writeHandler

  select.registerHandle(server.getFd(), {Event.Read}, -1)
  
  while true:
    var results: seq[ReadyKey] = select.select(-1)
  
    for result in results:
      if Event.Read in result.events:
          result.processReads(srv)
      if Event.Write in result.events:
          result.processWrites(srv)
  
  select.close()
  server.close()


when isMainModule:
    runTcpServer()