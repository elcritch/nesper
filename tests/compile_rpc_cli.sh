#!/bin/sh

# nim c -d:TcpJsonRpcServer rpc_cli.nim 
nim c rpc_cli.nim 

./rpc_cli --ip:127.0.0.1 --port:5555 -c:10 '{"method": "sum", "params": [[7,2,4,5,6]]}'

./rpc_cli --ip:127.0.0.1 --port:5555 -c:10 '{"method": "quit", "params": []}'

