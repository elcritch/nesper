
ESP_IDF_VERSION ?= ESP_IDF_V4_0 
# ESP_IDF_VERSION ?= ESP_IDF_V4_1

NIMBLE := main/nimble
# Configure any dependencies
NIM_DEPENDA := msgpack4nim 
NIMLIB := $(shell nim dump file.json 2>&1 | grep lib | sort | head -n1 )
NIMCACHE := main/nimcache
NIMFLAGS ?= 

$(NIMBLE):
	nimble install -y --nimbleDir:"$(NIMBLE)" msgpack4nim stew

default: mpack_rpc_queue_server

json_rpc_server: clean
	nim prepare main/wifi_example_main.nim --nimblePath:$(NIMBLE)/pkgs -d:$(ESP_IDF_VERSION) -d:TcpJsonRpcServer $(NIMFLAGS) && idf.py reconfigure 
	nim c --nimblePath:$(NIMBLE)/pkgs -d:TcpJsonRpcServer -o:rpc_cli rpc_cli_test.nim 

mpack_rpc_server: clean
	nim prepare main/wifi_example_main.nim --nimblePath:$(NIMBLE)/pkgs -d:$(ESP_IDF_VERSION) -d:TcpMpackRpcServer $(NIMFLAGS) && idf.py reconfigure 
	nim c --nimblePath:$(NIMBLE)/pkgs -d:TcpMpackRpcServer -o:rpc_cli rpc_cli_test.nim 

mpack_rpc_queue_server: clean
	nim prepare main/wifi_example_main.nim --nimblePath:$(NIMBLE)/pkgs -d:$(ESP_IDF_VERSION) -d:TcpMpackRpcQueueServer $(NIMFLAGS) && idf.py reconfigure 
	nim c --nimblePath:$(NIMBLE)/pkgs -d:TcpMpackRpcQueueServer -o:rpc_cli rpc_cli_test.nim 

tcp_echo_server: clean
	nim prepare main/wifi_example_main.nim --nimblePath:$(NIMBLE)/pkgs -d:$(ESP_IDF_VERSION) -d:TcpEchoServer $(NIMFLAGS) && idf.py reconfigure 
	nim c --nimblePath:$(NIMBLE)/pkgs -d:TcpEchoServer -o:rpc_clirpc_cli_test.nim 

build: 
	idf.py build


clean: $(NIMBLE)
	rm -Rf main/nimcache/

fullclean: clean
	rm -Rf build/
	rm -Rf main/nimble/
	# idf.py fullclean

.PHONY: clean build
