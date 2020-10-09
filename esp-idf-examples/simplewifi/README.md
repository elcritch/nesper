# Nim ESP32 - Simple Wifi

Simple example in Nim with wifi on ESP32 on FreeRTOS & LwIP.

## Building

- checkout this repo and move to this directory `esp-idf-examples/simplewifi/` 
- set `WIFI_SSID` and `WIFI_PASSWORD` environmental variables
- prepare Nim code
- build idf project 
- connect esp32 to pc
- flash with idf.py
- monitory with idf.py
- run http request on `curl 192.168.1.XX:8181`

## Example on a ESP32-CAM board

```shell
git clone https://github.com/elcritch/nesper
cd esp-idf-examples/simplewifi/
export WIFI_SSID="[SSID]"
export WIFI_PASSWORD="[PASSWORD]"
nim prepare ./main/wifi_example_main.nim
idf.py reconfigure
idf.py build
```

This will build the project. Next use idf.py to flash and monitor:

```shell
idf.py build
idf.py -p [port] flash
idf.py -p [port] monitor
```
