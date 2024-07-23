# Package

version       = "0.7.0"
author        = "Jaremy Creechley"
description   = "Nim wrappers for ESP-IDF (ESP32)"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies
requires "nim >= 1.4.0"
requires "msgpack4nim >= 0.3.1"
requires "stew >= 0.1.0"
requires "bytesequtils"

# requires "bytesequtils >= 1.1"
# requires "nimcrypto >= 1.0"


# Tasks
import os, strutils

proc general_tests() =
  # Regular tests
  for dtest in listFiles("tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("Testing: " & $dtest)
      exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos $1" % [dtest]

proc driver_tests() =
  # Driver tests
  for dtest in listFiles("tests/driver/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("Testing: " & $dtest)
      exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos $1" % [dtest]

proc storage_tests() =
  # Driver tests
  for dtest in listFiles("tests/storage/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("Testing: " & $dtest)
      exec "nim c --compileOnly:on --cincludes:c_headers/mock/ --os:freertos $1" % [dtest]

proc exec_tests() =
  # Exec tests
  for dtest in listFiles("tests/exec_tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("Testing: " & $dtest)
      exec "nim c -r --cincludes:$2/tests/c_headers/mock/ $1" % [dtest, getCurrentDir()]

task test, "Runs the test suite":
  general_tests()
  driver_tests()
  storage_tests()
  # exec_tests()

task test_general, "Runs the test suite":
  general_tests()
task test_drivers, "Runs the test suite":
  driver_tests()
task test_storage, "Runs the test suite":
  storage_tests()
task test_execs, "Runs the test suite":
  exec_tests()

  # exec "nim c -r tests/trouter.nim"


