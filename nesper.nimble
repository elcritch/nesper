# Package

version       = "0.7.7"
author        = "Jaremy Creechley"
description   = "Nim wrappers for ESP-IDF (ESP32)"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies
requires "nim >= 1.4.0"
requires "msgpack4nim >= 0.3.1"
requires "stew >= 0.1.0"
requires "bytesequtils"

# Tasks
import os, strutils

const NFLAGS="--verbosity:0 -d:ESP_IDF_VERSION=" &
              getEnv("ESP_IDF_VERSION", "4.4") &
              " --cincludes:" & (getCurrentDir() / "tests" / "c_headers" / "mock")

proc header(msg: string) =
  echo "\n\n", msg, "\n"

proc testExec(extras, file: string, flags=NFLAGS) =
  let cmd = "nim c $1 $2 $3" % [flags, extras, file]
  echo("")
  echo("Testing: " & $file)
  echo "running: ", cmd
  exec(cmd)

proc general_tests() =
  # Regular tests
  header "=== Regular Tests ==="
  for dtest in listFiles("tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec("--compileOnly:on --os:freertos", dtest)

proc driver_tests() =
  # Driver tests
  header "=== Driver Tests ==="
  for dtest in listFiles("tests/driver/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("\nTesting: " & $dtest)
      testExec("--compileOnly:on --os:freertos", dtest)

proc storage_tests() =
  # Storage tests
  header "=== Storage Tests ==="
  for dtest in listFiles("tests/storage/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec("--compileOnly:on --os:freertos", dtest)

proc exec_tests() =
  # Exec tests
  header "=== Exec Tests ==="
  for dtest in listFiles("tests/exec_tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec(" -r ", dtest)

task test, "Runs the test suite":
  general_tests()
  driver_tests()
  storage_tests()
  exec_tests()

task test_general, "Runs the test suite":
  general_tests()
task test_drivers, "Runs the test suite":
  driver_tests()
task test_storage, "Runs the test suite":
  storage_tests()
task test_execs, "Runs the test suite":
  exec_tests()

  # exec "nim c -r tests/trouter.nim"


