# nesper

Nim wrappers for ESP-IDF (ESP32). This library builds on the new FreeRTOS/LwIP API support in Nim. 

## Status

This is a Work in Progress (tm). I'm using it for a few work projects as I really dislike programming C/C++, despite C's elegance. When you just want a hash table in C it's a pain. C++ is about 5 different languages now and I have to idea how to use half of them anymore. Rust doesn't work on half the thins I want to program. MicroPython? ... No. 

TLDR; Real reason? It's kinda fun in a sometimes tricky field. 

## Library

The library is currently a collection of random ESP-IDF libraries that I import using `c2nim` as needed. Sometimes there's a bit extra wrapping to provide a nicer Nim API. 

Supported ESP-IDF libraries: 

- [x] Nim stdandard library support for most basic POSIX network api's!
- [x] Most of the basic `FreeRTOS.h` header 
- [x] NVS Flash
- [x] UART 
- [ ] SPI 
- [ ] I2C 

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

1. Install Nim 1.4+ (currently only the `devel` branch works) with `asdf` or `choosenim`.
2. nimble install https://github.com/elcritch/nesper
3. Copy or create a Nim program to generate C code for esp-idf (see examples)
4. Configure esp-idf to import Nim generated C code (see examples)
5. Import Nesper API's into Nim code using `import nesper/xyz` as desired
6. Or just use Nim network api's directly like in the `simplewifi` example 


## Example on a ESP32-CAM board

Copy one the example wifi:

```shell
git clone https://github.com/elcritch/nesper
cp -Rv nesper/tests/esp-idf-examples/simplewifi/ mysimplewifi/
cd mysimplewifi/
nim prepare ./src/server.nim
idf.py reconfigure # sometimes required if new Nim C files are generated
idf.py build
```

```shell
idf.py build
idf.py -p [port] flash
idf.py -p [port] monitor
```

## Why Nim?

Nim is a flexible language which compiles to a variety of backend "host" languages, including C and C++. Like many hosted languages, it has excellent facilities to interact with the host language natively. In the embedded world this means full compatability with pre-existing libraries and toolchains, which are often complex and difficult to interface with from an "external language" like Rust or even C++. They often also require oddball compilers, ruling out LLVM based lanugages for many projects (including the ESP32 which defaults to a variant of GCC).  

Nim has a few nice features for embedded work: 

- High level language and semantics
- Flexible garbage collector including options for manual memory management
- Ability to do low level bit-fiddling including pointer manipulations
- Relatively complete standard library, including JSON, MessagePack, Time, crypto libraries
- Wrappers around native socket based API's like LwIP's emulated `select`, simplifying networking
- Efficient compiler that eliminates un-needed code (e.g. json support using a few extra kB's)
- Fast compilation, generated C compiles fast with few included headers
- One of the simplest FFI's around to import and/or wrap C/C++ libraries
- Options for deterministic exception handling using a C goto based method
- Object-oriented like programming that's not based on vtables 
- Async support in standard library
- Real hygenic language macros!
- Real types with generics!
- Re-use normal native-C debuggers, meaning any embedded debuggers should work too!
- Very flexible and hackable standard library!!

There are a few cons of Nim: 

- Lack of documentation for many parts of the standard library
- Understanding the differences between stack/heap based objects is a bit tricky
- Compiler options are often incompatible and can require some experimentation
- Small community (e.g. lack of some libraries)
- You likely won't get to use it at XYZ Megacorp 
- It will require some pioneering!

## Nim ARC/ORC - Embeeded friendly Garbage Collector

Nesper capitalizes on the new ARC garbage collector (GC) for Nim which has a few benefits over other GC's for embedded usage. Primarily, the ARC garbage collector uses a non-locking reference counting which significantly reduces the reference counting overhead. Locking is slow! ARC also does not rely on scanning the stack. This means you allocate large objects or arrays on the stack without worrying about GC collector efficiency. ARC is integrated in Nim and includes the ability to do C++ style move semantics which can greatly improve memory efficiency. The Nim compiler automatically tries to optimize moves, but the user can provide hints to help.   

ORC is the ARC garbage collect but with a cycle detection. It's fast and efficient and enables `async` and lambda function style programming without worrying about cycles. However, if you program your data structures without cycles you can use ARC which will be faster. 

