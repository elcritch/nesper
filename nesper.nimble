# Package

version       = "0.2.0"
author        = "Jaremy Creechley"
description   = "Nim wrappers for ESP-IDF (ESP32)"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies

requires "nim >= 1.2.0"


# Tasks
task test, "Runs the test suite":
  exec "nim c --os:freertos tests/tconsts.nim"
  exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos tests/tgeneral.nim"
  exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos tests/tnvs.nim"
  exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos tests/tspi.nim"
  exec "nim c -r tests/trouter.nim"

