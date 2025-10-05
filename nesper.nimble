# Package

version       = "0.9.1"
author        = "Jaremy Creechley"
description   = "Nim wrappers for ESP-IDF (ESP32)"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies
requires "nim >= 1.4.0"
requires "msgpack4nim >= 0.3.1"
requires "stew >= 0.1.0"
requires "bytesequtils"

feature "examples":
  requires "https://github.com/elcritch/fastrpc >= 0.5.1"