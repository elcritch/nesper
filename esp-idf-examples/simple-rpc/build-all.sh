#!/bin/sh

set -e

echo ========= full clean ========= 
make fullclean

echo ========= json_rpc_server build ========= 
make json_rpc_server build

echo ========= mpack_rpc_server build ========= 
make mpack_rpc_server build

echo m========= pack_rpc_queue_server build ========= 
make mpack_rpc_queue_server build

echo ========= tcp_echo_server build ========= 
make tcp_echo_server build

