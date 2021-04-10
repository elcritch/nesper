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
  UdpClientDisconnected* = object of OSError
  UdpClientError* = object of OSError

  UdpServerInfo*[T] = ref object 
    select*: Selector[T]
    server*: Socket
    clients*: ref Table[(string, Port), Millis]
    writeHandler*: UdpServerHandler[T]
    readHandler*: UdpServerHandler[T]

  UdpServerHandler*[T] = proc (srv: UdpServerInfo[T], selected: ReadyKey, client: Socket, data: T) {.nimcall.}


proc createServerInfo[T](server: Socket, selector: Selector[T]): UdpServerInfo[T] = 
  result = new(UdpServerInfo[T])
  result.server = server
  result.select = selector
  result.clients = newTable[(string, Port), Millis]()

proc processWrites[T](selected: ReadyKey, srv: UdpServerInfo[T], data: T) = 
  # untested...
  var sourceClient: Socket = newSocket(SocketHandle(selected.fd))
  let data = getData(srv.select, selected.fd)
  if srv.writeHandler != nil:
    srv.writeHandler(srv, selected, sourceClient, data)

const cfgMaxPacket = 100

proc echoReadHandler*(srv: UdpServerInfo[string], result: ReadyKey, sourceClient: Socket, data: string) =
  # simple echo handler
  var
    message = ""
    srcAddress = ""
    srcPort = Port(0)

  discard sourceClient.recvFrom(message, cfgMaxPacket, srcAddress, srcPort)

  logi(TAG, "received from client: %s:%s", $srcAddress, $srcPort)

  if not srv.clients.hasKey( (srcAddress, srcPort) ):
    srv.clients[ (srcAddress, srcPort) ] = millis()

  logi(TAG, "received from client: %s", message)

  for client, ts in srv.clients:
    var (clientIp, clientPort) = client
    # if sourceClient.getFd() == cfd.getFd():
      # continue
    srv.server.sendTo(clientIp, clientPort, data & message & "\r\n")

proc startUdpSocketServer*[T](port: Port, readHandler: UdpServerHandler[T], writeHandler: UdpServerHandler[T], data: var T) =
  echo "start udp socket: ", $port
  var server: Socket = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
  echo "socket"
  var select: Selector[T] = newSelector[T]()

  server.setSockOpt(OptReuseAddr, true)
  server.getFd().setBlocking(false)
  # server.bindAddr(port, "127.0.0.1")
  server.bindAddr(port)
  # server.listen()

  logi TAG, "Server: started. Listening to new connections on port: %s", $port

  var srv = createServerInfo[T](server, select)
  srv.readHandler = readHandler
  srv.writeHandler = writeHandler

  select.registerHandle(server.getFd(), {Event.Read}, data)
  
  while true:
    var results: seq[ReadyKey] = select.select(-1)
  
    for result in results:
      echo "udp results"
      if Event.Read in result.events:
          echo "udp read results"
          var selected: ReadyKey = result
          # result.processReads(srv, data)
          srv.readHandler(srv, selected, server, data)
      if Event.Write in result.events:
          result.processWrites(srv, data)
      # taskYIELD()
    # delayMillis(1)
    vTaskDelay(1.TickType_t)

  
  select.close()
  server.close()

when isMainModule:
  startUdpSocketServer[string](Port(5555), readHandler=echoReadHandler, writeHandler=nil, data="echo: ")