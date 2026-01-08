
# Tasks
import os, strutils

--nimcache:".nimcache/"

const NFLAGS=" --cincludes:" & (getCurrentDir() / "tests" / "c_headers" / "mock")

proc header(msg: string) =
  echo "\n\n", msg, "\n"

proc testExec(extras, file: string, flags=NFLAGS) =
  let cmd = "nim c $1 $2 $3" % [flags, extras, file]
  echo("")
  echo("Testing: " & $file)
  echo "running: ", cmd
  exec(cmd)

task test_driver, "Runs the test suite":
  # Driver tests
  header "=== Driver Tests ==="
  for dtest in listFiles("tests/driver/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      echo("\nTesting: " & $dtest)
      testExec("--compileOnly:on --os:freertos", dtest)

task test_storage, "Runs the test suite":
  # Storage tests
  header "=== Storage Tests ==="
  for dtest in listFiles("tests/storage/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec("--compileOnly:on --os:freertos", dtest)

task test_general, "Runs the test suite":
  # Regular tests
  header "=== Regular Tests ==="
  for dtest in listFiles("tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec("--compileOnly:on --os:freertos", dtest)

task test_execs, "Runs the test suite":
  # Exec tests
  header "=== Exec Tests ==="
  for dtest in listFiles("tests/exec_tests/"):
    if dtest.splitFile()[1].startsWith("t") and dtest.endsWith(".nim"):
      testExec(" -r ", dtest)

  # exec "nim c -r tests/trouter.nim"

task test, "Runs the test suite":
  test_generalTask()
  test_driverTask()
  test_storageTask()

task test_all, "Runs the test suite":
  test_generalTask()
  test_driverTask()
  test_storageTask()
  test_execsTask()

task test_uart_echo_qemu, "Build the UART echo example with QEMU":
  if findExe("idf.py") == "":
    echo "\nError: idf.py not found. Please run the esp-idf export commands: `. $IDF_PATH/export.sh` and try again.\n"
    quit(2)

  let exampleDir = getCurrentDir() / "esp-idf-examples" / "uart_echo"
  withDir exampleDir:
    exec("idf.py set-target esp32c3")
    exec("nim espBuild")
