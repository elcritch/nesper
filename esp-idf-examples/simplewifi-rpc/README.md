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

- json_rpc_server
- mpack_rpc_server
- mpack_rpc_queue_server
- tcp_echo_server

You can then compile the ESP-IDF build by one of: 

```sh
idf.py build
```

```sh
make build
```

This will build the project. Next use idf.py to flash and monitor:

```shell
idf.py -p [port] flash
idf.py -p [port] monitor
```
