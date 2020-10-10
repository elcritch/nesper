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
  ControlServerInfo* = ref object 
    storage*: NvsObject
    select*: Selector[int]
    server*: Socket
    clients*: ref Table[SocketHandle, Socket]
    tcpMessages*: seq[string]

  ServerInfo* = ref object 
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

proc handleReads(srv: var ControlServerInfo, selected: ReadyKey) = 
  if selected.fd.SocketHandle == srv.server.getFd():
    var client: Socket = new(Socket)
    srv.server.accept(client)

    client.getFd().setBlocking(false)
    srv.select.registerHandle(client.getFd(), {Event.Read}, -1)
    srv.clients[client.getFd()] = client
    echo("Server: client connected: ", $client.getFd().int)

  elif srv.clients.hasKey(selected.fd.SocketHandle):
    # echo("server: received socket: ", selected.fd)
    var sourceFd = selected.fd
    var sourceClient: Socket = srv.clients[sourceFd.SocketHandle]

    try:
      var msg: string = newString(BUFF_SZ)
      var count = sourceClient.recv(msg, BUFF_SZ)

      if count == 0:
        var client: Socket
        discard srv.clients.pop(sourceFd.SocketHandle, client)
        srv.select.unregister(sourceFd)
        discard posix.close(sourceFd.cint)
        echo("control server: client disconnected: ", " fd: ", $sourceFd)
      elif count < 0:
        srv.clients.del(sourceFd.SocketHandle)
        srv.select.unregister(sourceFd)

        discard posix.close(sourceFd.cint)
        echo("control server: client read error: ", $(sourceFd))
      else:
        msg.setLen(count)
        srv.tcpMessages.insert(msg, 0)
        # echo("server: received from client: `", msg, "`")
    except TimeoutError:
      echo("control server: error: socket timeout: ", $sourceClient.getFd().int)

  else:
    echo("control server: error: unknown socket id: ", $selected.fd.int)



proc startRpcSocketServer*(port: Port) =
  var server: Socket = newSocket()
  var select: Selector[int] = newSelector[int]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  server.bindAddr(port)
  server.listen()

  logi TAG, "Server: started. Listening to new connections on port 5555..."

  var srv = createServerInfo(server, select)

  select.registerHandle(server.getFd(), {Event.Read}, -1)
  
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