import nativesockets
import net
import selectors
import tables
import posix

import ../../consts
import ../../general
import ../tcpsocket

export net

const TAG = "socketrpc"

proc handleWrites(result: ReadyKey, srv: ServerInfo) = 
  raise newException(OSError, "the request to the OS failed")

proc rpcMsgPackReadHandler*(srv: TcpServerInfo[string], result: ReadyKey, sourceClient: Socket, data: string) =
  var sourceFd = selected.fd
  var sourceClient: Socket = srv.clients[sourceFd.SocketHandle]

  try:
    var msg: string = newString(BUFF_SZ)
    var count = sourceClient.recv(msg, BUFF_SZ)

    if count == 0:
      raise newException(TcpClientDisconnected, "")
    elif count < 0:
      raise newException(TcpClientError, "")
    else:
      msg.setLen(count)
      srv.tcpMessages.insert(msg, 0)
      # echo("server: received from client: `", msg, "`")
  except TimeoutError:
    echo("control server: error: socket timeout: ", $sourceClient.getFd().int)



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