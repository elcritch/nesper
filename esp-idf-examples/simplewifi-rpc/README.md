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
