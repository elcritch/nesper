# Nim ESP32 - Simple Wifi

Simple example in Nim with wifi on ESP32 on FreeRTOS & LwIP.

## Building

- checkout this repo and move to the `simplewifi` directory
- move to `nim` directory and compile nim parts
- configure wifi SSID and password with idf.py
- build project with idf.py
- connect esp32 to pc
- run flash with idf.py
- run monitor with idf.py

## Example on a ESP32-CAM board

```shell
git clone https://github.com/elcritch/esp32_nim_net_example
cd simplewifi
nim prepare ./src/server.nim
idf.py menuconfig
```
a config menu appear, go to `Wifi Example Configuration` and set ssid and password.
Remember to save.

```shell
idf.py build
idf.py -p [port] flash
idf.py -p [port] monitor
```
