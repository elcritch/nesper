# Nim ESP32 - Simple Wifi

Simple example in Nim with wifi on ESP32 on FreeRTOS & LwIP.

## Building Example

Install and configure [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html). Currently v4.1 is the default supported version for Nesper currently. 

Then:

```shell
git clone https://github.com/elcritch/nesper
cd esp-idf-examples/simplewifi/
. $ESP_IDF_DIR/export.sh # source esp-idf
```

Build Nim project:
```sh
export WIFI_SSID="[SSID]"
export WIFI_PASSWORD="[PASSWORD]"
make json_rpc_server build
```

This compiles the Nim code and updates the ESP-IDF project files. This example contains several variants which can be built by changing the make target like: `make tcp_echo_server build` then following the rest of the steps. The current options are: 

```sh
make json_rpc_server build
make mpack_rpc_server build
make mpack_rpc_queue_server build
make tcp_echo_server build
```

The above will all compile the nim project and then run `idf.py build` for you. 

Once the project is built you can use `idf.py` tools for flashing and monitoring:

```shell
idf.py -p [port] flash
idf.py -p [port] monitor

# or together:
idf.py -p [port] flash monitor
```

## Testing Example 

The RPC methods use raw sockets and `selectors` library from Nim's stdlib. This allows the ESP32 code to efficiently check sockets for new messages. The makefile now builds a variant of `rpc_cli` that should work with the chosen method (e.g. mpack or json).

Run it like: 

```sh
./rpc_cli --ip:$IP --count:1 '{"method": "add", "params": [1,2]}' 
```

## Notes on the RPC protocol

The `rpc_cli` should give an example of the RPC protocol used for the message pack RPC versions. It's roughly based on JSON-RPC, however, using raw socket require a bit more work. Sending RPC messages are sent "raw", e.g. just the message. This limits RPC calls to 1400 bytes and could be fixed in the future. 

For receiving the RPC responses, a very simple protocol is used based on the Erlang "ports" protocol. A 4-byte signed integer with the size of the RPC result is sent first, in network byte order. The RPC client must read these 4 bytes, then read the number of bytes sent. The `rpc_cli` provides an example of how to do this in Nim. This enables returning message that are larger than 1400 bytes. Ideally, this will be done for the incoming RPC message as well. 

For simplificity, the JSON version of the rpc server currently returns a "raw" response and are limited to 1400 bytes on both sending and receiving RPC messages.

The 'echo' server likewise only sends raw data. You can use `netcat` to test the echo server. 
