# nesper

Nim wrappers for ESP-IDF (ESP32). This library builds on the new FreeRTOS/LwIP API support in Nim. 

## Updates 

**Version 0.2.0**
- Wrote compilation tests for several important modules 
- My internal esp32 project has been switched over to using Nesper
- It's possible to write a full Nim only esp32 app
- There are now Nim wrappers for esp_wifi, tcpip_adapter, event_groups, tasks, and more esp-idf modules
- More Nim friendly API's have been added for NVS, SPI (untested), I2C (untested), wifi, & events


**Version 0.1.0**
- Initial framework layout

## Status

TLDR; Real reason? It's a bit of fun in a sometimes tricky field. 

This is a Work in Progress (tm). I'm using it for a few work projects as I generally dislike programming C/C++ (despite C's elegance in the small). When you just want a hash table in C it's tedious and error prone. C++ is about 5 different languages and I have to idea how to use half of them anymore. Rust doesn't work on half of the boards I want to program. MicroPython? ... Nope - I need speed and efficiency. 

## Library

The library is currently a collection of random ESP-IDF libraries that I import using `c2nim` as needed. Sometimes there's a bit extra wrapping to provide a nicer Nim API. 

Caveat: these features are tested as they're used for my use case. However, both Nim and the esp-idf seem designed well enough that they mostly "just work". PR's are welcome! 

Supported ESP-IDF libraries: 

- [x] Nim stdandard library support for most basic POSIX network api's!
- [x] Most of the basic `FreeRTOS.h` header 
- [x] NVS Flash
- [x] UART 
- [x] SPI
- [x] I2C 

Things I'd like to get to:

- [ ] Nim standard library wrapping of FreeRTOS semaphore's, mutexes, etc
- [ ] Nim support for `xqueue` and other "thread safe" data structures
- [ ] Nim standard library support for FreeRTOS tasks using thread api's

Things I'm not planning on (PR's welcome!)

- [ ] I2S 
- [ ] PWM 
- [ ] LCDs 
- [ ] Built-in ADC 

## General Usage

1. Install Nim 1.4+ (currently only the `devel` branch works) with `asdf` or `choosenim`
2. nimble install https://github.com/elcritch/nesper
3. Nesper wrapper API names generally match the C names directly, usually in snake case
  + FreeRTOS functions usually are camel case and start with an `x`, e.g. `xTaskDelay`
  + These api's are found under `nesper/esp/*` or `nesper/esp/net/*`, e.g. `nesper/esp/nvs`
4. Nesper Nim friendly api, usually in camel case
  + These api's are found under `nesper/*`, e.g. `nesper/nvs`


## Example Async server on a ESP32-CAM (or other Esp32 Wifi board)

Copy one the example wifi:

```shell
git clone https://github.com/elcritch/nesper
cd nesper/esp-idf-examples/simplewifi/ 
export WIFI_SSID=[ssid]
export WIFI_PASSWORD=[password]
nim prepare ./main/wifi_example_main.nim 
idf.py reconfigure # sometimes required if new Nim C files are generated
```

Then do the standard idf build and flash steps:

```shell
idf.py build
idf.py -p [port] flash
idf.py -p [port] monitor
```

## Why Nim for Embedded?

Nim is a flexible language which compiles to a variety of backend "host" languages, including C and C++. Like many hosted languages, it has excellent facilities to interact with the host language natively. In the embedded world this means full compatability with pre-existing libraries and toolchains, which are often complex and difficult to interface with from an "external language" like Rust or even C++. They often also require oddball compilers, ruling out LLVM based lanugages for many projects (including the ESP32 which defaults to a variant of GCC).  

Nim has a few nice features for embedded work: 

Language:
- High level language and semantics with low level bit fiddling and pointers
- Flexible garbage collector or manual memory management
    + ARC GC allows using native-C debuggers, meaning any embedded debuggers should work too!
    + ARG GC doesn't use locks, and utilizies move semantics -- it's fast
- Simple FFI's around to import and/or wrap C/C++ libraries
- Async/Event support
- Real hygenic language macros, and collections with generics!
- Very flexible and hackable standard library!

Libraries: 
- Simplified network wrappers around native sockets (i.e. use `select` w/o a PhD)
- Sane standard library, including JSON, datetime, crypto, ...
    + Efficient compiler that eliminates un-needed code (i.e. json support using a few extra kB's)
    + Package library manager

Compiler:
- Fast compilation, generated C compiles fast
- Deterministic exception handling using a non-malloc friendly goto technique
- Object-oriented like programming that's not based on vtables 

There are a few cons of Nim: 

- Lack of documentation for many parts of the standard library
- Understanding the differences between stack/heap based objects is a bit tricky
- Compiler options are often incompatible and can require some experimentation
- Small community (e.g. lack of some libraries)
- You likely won't get to use it at XYZ Megacorp 
- It will require some pioneering!
