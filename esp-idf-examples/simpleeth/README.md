# Nim ESP32 - Hello Network

Example repo for using Nim with ESP32 on FreeRTOS & LwIP. 

An example using only wifi is available at [simplewifi](simplewifi/), check out 
[its README](simplewifi/README.md) for instruction in how to build that if your
board doesn't have an ethernet chip.


# Building

Install a devel version of the compiler.  
Then goto the `nim/` folder and do a `make`. This will generate Nim C output files using a local Makefile (not part of the ESP-IDF build system). 

Afterwards, do a `make menuconfig` in the main folder. You don't need to run a `make menuconfig` everytime after updating Nim, but only when Nim outputs a new Nim C file (e.g. you pull in a new Nim library, etc). This could be cleaned up in the future I'm sure. 

Once the generated Nim sources are registered with ESP-IDF's build system, then all you need to do is the standard `idf.py build` and upload steps. 

# Info

Here's the Nim Forum thread: https://forum.nim-lang.org/t/6345

The primary branch I'm using is here: https://github.com/elcritch/Nim/tree/devel-basic-freertos-network, it was already merged into
devel.

Beware, only ARC works as the other GC's need another memory backend. It's easy to add, but I removed it until the main FreeRTOS options are added in upstream. 

