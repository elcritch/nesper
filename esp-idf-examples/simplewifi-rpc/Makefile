
build: 
	idf.py build

json_rpc_server:
	nim prepare main/wifi_example_main.nim -d:TcpMpackRpcServer -d:release && idf.py reconfigure 

mpack_rpc_server:
	nim prepare main/wifi_example_main.nim -d:TcpMpackRpcServer -d:release && idf.py reconfigure 

mpack_rpc_queue_server:
	nim prepare main/wifi_example_main.nim -d:TcpMpackRpcQueueServer -d:release && idf.py reconfigure 

tcp_echo_server:
	nim prepare main/wifi_example_main.nim -d:TcpEchoServer -d:release && idf.py reconfigure 

clean:
	rm -Rf main/nimcache/

