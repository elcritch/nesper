import nativesockets
import net
import selectors
import tables
import posix

type 
  ServerInfo = ref object 
    select: Selector[int]
    server: Socket
    clients: ref Table[SocketHandle, Socket]

proc createServerInfo(server: Socket, selector: Selector[int]): ServerInfo = 
  result = new(ServerInfo)
  result.server = server
  result.select = selector
  result.clients = newTable[SocketHandle, Socket]()


proc handleWrites(result: ReadyKey, srv: ServerInfo) = 
  raise newException(OSError, "the request to the OS failed")

proc handleReads(selected: ReadyKey, srv: ServerInfo) = 
  if selected.fd.SocketHandle == srv.server.getFd():
    var client: Socket = new(Socket)
    srv.server.accept(client)

    client.getFd().setBlocking(false)
    srv.select.registerHandle(client.getFd(), {Event.Read}, -1)
    srv.clients[client.getFd()] = client
    stdout.writeLine("Server: client connected")

  else:
    var sourceClient: Socket = newSocket(selected.fd.SocketHandle)
    var message = sourceClient.recvLine()

    if message == "":

      var client: Socket
      discard srv.clients.pop(sourceClient.getFd(), client)
      srv.select.unregister(sourceClient.getFd())
      stdout.writeLine("Server: client disconnected: " & $(sourceClient.getLocalAddr()[0]))

    else:
      stdout.writeLine("Server: received from client: ", message)

      for cfd, client in srv.clients:
        # if sourceClient.getFd() == cfd.getFd() :
        #   continue
        client.send(message & "\r\L")

proc runTcpServer*() {.exportc.} =
  var server: Socket = newSocket()
  var select: Selector[int] = newSelector[int]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  server.bindAddr(Port(5555))
  server.listen()
  stdout.writeLine("Server: started. Listening to new connections on port 5555...")

  var srv = createServerInfo(server, select)

  select.registerHandle(server.getFd(), {Event.Read}, -1)
#   var clients: seq[Socket] = @[]
  
  while true:
    var results: seq[ReadyKey] = select.select(-1)
  
    for result in results:
      if Event.Read in result.events:
          result.handleReads(srv)
      if Event.Write in result.events:
          result.handleWrites(srv)
  
  select.close()
  server.close()


when isMainModule:
    runTcpServer()