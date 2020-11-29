
ESP_IDF_VERSION ?= ESP_IDF_V4_0 
# ESP_IDF_VERSION ?= ESP_IDF_V4_1

default: mpack_rpc_queue_server

json_rpc_server:
	nim prepare main/wifi_example_main.nim -d:$(ESP_IDF_VERSION) -d:TcpMpackRpcServer -d:release && idf.py reconfigure 

mpack_rpc_server:
	nim prepare main/wifi_example_main.nim -d:$(ESP_IDF_VERSION) -d:TcpMpackRpcServer -d:release && idf.py reconfigure 

mpack_rpc_queue_server:
	nim prepare main/wifi_example_main.nim -d:$(ESP_IDF_VERSION) -d:TcpMpackRpcQueueServer -d:release && idf.py reconfigure 

tcp_echo_server:
	nim prepare main/wifi_example_main.nim -d:$(ESP_IDF_VERSION) -d:TcpEchoServer -d:release && idf.py reconfigure 

build: 
	idf.py build

clean:
	rm -Rf main/nimcache/

fullclean: clean
	rm -Rf build/
	# idf.py fullclean


