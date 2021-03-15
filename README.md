# Nesper

Program the ESP32 using Nim! This library builds on the `esp-idf`. Nim now has support for FreeRTOS & LwIP. Combined with the new ARC garbage collector makes Nim an excellent language for programming the ESP32.  

See [Releases](https://github.com/elcritch/nesper/releases) for updates. 

## Status 

This is a Work in Progress (TM), however it's already being used in a shipping hardware project. However, it may still require understanding the underlying ESP-IDF SDK for various use cases. 

Note: It's recommended to use the ESP-IDF.py v4.0 branch (as of 2020-11-24). Branch v4.1 has multiple serious bugs in I2C. 

## Example Code 

This code shows a short example of setting up an http server to toggle a GPIO pin. It uses the default async HTTP server in Nim's standard library. It still requires the code to initialize the ESP32 and WiFi or ethernet.  

```nim
import asynchttpserver, asyncdispatch, net
import nesper, nesper/consts, nesper/general, nesper/gpios

const
  MY_PIN_A* = gpio_num_t(4)
  MY_PIN_B* = gpio_num_t(5)

var 
  level = false
  
proc config_pins() =
    MOTOR1_PIN.setLevel(true)

proc http_cb*(req: Request) {.async.} =
    level = not level 
    echo "toggle my pin to: #", $level
    MY_PIN_A.setLevel(level)
    await req.respond(Http200, "Toggle MY_PIN_A: " & $level)

proc run_http_server*() {.exportc.} =
    echo "Configure pins"
    {MY_PIN_A, MY_PIN_B}.configure(MODE_OUTPUT) 
    MY_PIN_A.setLevel(lastLevel)
    
    echo "Starting http server on port 8181"
    var server = newAsyncHttpServer()
    waitFor server.serve(Port(8181), http_cb)

```

## Why

TLDR; Real reason? It's a bit of fun in a sometimes tricky field. 

I generally dislike programming C/C++ (despite C's elegance in the small). When you just want a hash table in C it's tedious and error prone. C++ is about 5 different languages and I have to idea how to use half of them anymore. Rust doesn't work on half of the boards I want to program. MicroPython? ... Nope - I need speed and efficiency. 

## Library

The library is currently a collection of random ESP-IDF libraries that I import using `c2nim` as needed. Sometimes there's a bit extra wrapping to provide a nicer Nim API. 

Caveat: these features are tested as they're used for my use case. However, both Nim and the esp-idf seem designed well enough that they mostly "just work". PR's are welcome! 

Supported ESP-IDF drivers with Nim'ified interfaces: 

- [x] Nim stdandard library support for most basic POSIX network API's!
- [x] Most of the basic `FreeRTOS.h` header 
- [x] NVS Flash 
- [x] UART 
- [x] SPI (don't mix half-duplex & duplex devices)
- [x] I2C 

Other things:

- [x] Nim standard library wrapping of FreeRTOS semaphore's, mutexes, etc
   - include `pthread` in your CMakeLists.txt file and use Nim's POSIX lock API's
- [x] Nim support for `xqueue` and other "thread safe" data structures
   - Raw C Wrappers exist, see `[rpcsocket_queue_mpack.nim](https://github.com/elcritch/nesper/blob/master/src/nesper/servers/rpc/rpcsocket_queue_mpack.nim) for proper usage. Nim Channel's appear to work as well. 
- [x] Nim standard library support for FreeRTOS tasks using thread api's
   - include `pthread` in your CMakeLists.txt file and use Nim's POSIX Pthread API's

Things I'm not planning on (PR's welcome!)

- [ ] I2S 
- [ ] PWM 
- [ ] LCDs 
- [ ] Built-in ADC 

## General Usage

1. [Install ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html#get-started-get-esp-idf) (version 4.0 is recommended for now, set the `-d:ESP_IDF_V4_0`)
1. Install Nim 1.4+ with `asdf` or `choosenim`
2. Install Nesper (`nimble install https://github.com/elcritch/nesper` or for the devel branch `nimble install 'https://github.com/elcritch/nesper@#devel' `)
3. Create a new Nimble project `nimble init --git esp32_test` and change into the new project directory (e.g. `./esp32_test/`)
4. Edit the Nimble file in the project directory, e.g. `esp32_test/esp32_test.nimble`
   a. Add the line `requires "nesper >= 0.5"` after the `requires "nim >= 1.4.4"`
   b. Next, add the line `include nesper/build_utils/tasks`
5. Verify it works by running `nimble tasks` in your project -- it should print new Nimble tasks like `esp_setup`, `esp_compile`, etc
6. Run `nimble esp_setup` to setup the correct files for building an esp32/esp-idf project 
7. Run `nimble esp_compile` to compile your Nim code to C which the esp-idf project will use
8. Run `nimble esp_build` to build the esp-idf project

Once the project is setup:
1. Normal code recompile: `nimble esp_build`
2. Flash and monitor the esp32 board using: `idf.py -p </dev/ttyUSB0> flash monitor`

Notes:
1. Running `nimble esp_build` will both compile the Nim code and then build the esp-idf project
2. During development it's often handy just to run `nimble esp_compile` to check your Nim code works
3. Sometimes the Nim build cache gets out of sync, use `nimble esp_build --clean` to force a full Nim recompile
4. Sometimes the esp-idf build cache gets out of sync, use `nimble esp_build --dist-clean` to force a full Nim recompile


### Manual Setup 

This is the more manual setup approach: 

3. It's recommend to copy `nesper/esp-idf-examples/simplewifi` example project initially, to get the proper build steps. 
     - `git clone https://github.com/elcritch/nesper`
     - `cp -Rv nesper/esp-idf-examples/simplewifi/ ./nesper-simplewifi`
     - `cd ./nesper-simplewifi/`
     - `make build` (also `make esp_v40` or `make esp_v41` ) 
5. Nesper wrapper API names generally match the C names directly, usually in snake case
  + FreeRTOS functions usually are camel case and start with an `x`, e.g. `xTaskDelay`
  + These api's are found under `nesper/esp/*` or `nesper/esp/net/*`, e.g. `nesper/esp/nvs`
6. Nesper Nim friendly api, usually in camel case
  + These api's are found under `nesper/*`, e.g. `nesper/nvs`

## Example Async server on a ESP32-CAM (or other Esp32 Wifi board)

See [SimpleWifi Example](https://github.com/elcritch/nesper/blob/master/esp-idf-examples/simplewifi/README.md)

The async code really is simple Nim code:

```nim
import asynchttpserver, asyncdispatch, net

var count = 0

proc cb*(req: Request) {.async.} =
    inc count
    echo "req #", count
    await req.respond(Http200, "Hello World from nim on ESP32\n")
    # GC_fullCollect()

proc run_http_server*() {.exportc.} =
    echo "starting http server on port 8181"
    var server = newAsyncHttpServer()

    waitFor server.serve(Port(8181), cb)

when isMainModule:
    echo "running server"
    run_http_server()
```

## Nim-ified ESP32 APIs

### GPIOs 

```nim
import nesper, nesper/consts, nesper/general, nesper/gpios

const
  MOTOR1_PIN* = gpio_num_t(4)
  MOTOR2_PIN* = gpio_num_t(5)

proc config_pins() =
  # Inputs pins use Nim's set `{}` notation
  configure({MOTOR1_PIN, MOTOR2_PIN}, GPIO_MODE_INPUT)
  # or method call style:
  {MOTOR1_PIN, MOTOR2_PIN}.configure(MODE_INPUT)
  
  MOTOR1_PIN.setLevel(true)
  MOTOR2_PIN.setLevel(false) 
```

### SPIs

```nim
import nesper, nesper/consts, nesper/general, nesper/spis

proc cs_adc_pre(trans: ptr spi_transaction_t) {.cdecl.} = ... 
proc cs_unselect(trans: ptr spi_transaction_t) {.cdecl.} = ...

proc config_spis() = 
  # Setup SPI example using custom Chip select pins using pre/post callbacks 
  let
    std_hz = 1_000_000.cint()
    fast_hz = 8_000_000.cint()
    
  var BUS1 = HSPI.newSpiBus(
        mosi = gpio_num_t(32),
        sclk = gpio_num_t(33),
        miso = gpio_num_t(34),
        dma_channel=0,
        flags={MASTER})

  logi(TAG, "cfg_spi: bus1: %s", repr(BUS1))

  var ADC_SPI = BUS1.addDevice(commandlen = bits(8),
                               addresslen = bits(0),
                               mode = 0,
                               cs_io = gpio_num_t(-1),
                               clock_speed_hz = fast_hz, 
                               queue_size = 1,
                               pre_cb=cs_adc_pre,
                               post_cb=cs_unselect,
                               flags={HALFDUPLEX})
```

Later these can be used like: 

```nim

const 
  ADC_READ_MULTI_CMD =  0x80
  ADC_REG_CONFIG0 = 0x03

proc read_regs*(reg: byte, n: range[1..16]): SpiTrans =
  let read_cmd = reg or ADC_READ_MULTI_CMD # does bitwise or
  return ADC_SPI.readTrans(cmd=read_cmd, rxlength=bytes(n), )

proc adc_read_config*(): seq[byte] =
  var trn = read_regs(ADC_REG_CONFIG0, 2)
  trn.transmit() # preforms SPI transaction using transaction queue
  result = trn.getData()

```

See more in the test [SPI Test](https://github.com/elcritch/nesper/blob/master/tests/tspi.nim) or the read the wrapper (probably best docs for now): [spis.nim](https://github.com/elcritch/nesper/blob/master/src/nesper/spis.nim). 

## Wear levelling / Virtual FAT filesystem

```nim
import nesper, nesper/esp_vfs_fat

var
  base_path : cstring = "/spiflash"
  s_wl_handle : wl_handle_t = WL_INVALID_HANDLE

mount_config = esp_vfs_fat_mount_config_t(format_if_mount_failed: true,
                                          max_files: 10, allocation_unit_size: 4096)
err = esp_vfs_fat_spiflash_mount(base_path, "storage", mount_config.addr, s_wl_handle.addr)

if err != ESP_OK:
  echo "Failed to mount FATFS."
else:
  echo "FATFS mounted successfully!"

writeFile("/spiflash/hello.txt", "Hello world!")
echo readFile("/spiflash/hello.txt") # Hello world!
```

Notice: file extension of files on FAT filesystem is limited to maximum of 3 characters.

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
