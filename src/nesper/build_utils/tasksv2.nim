import std/[os, strutils, strformat]

const CCompilerParams = [
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-label APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-discarded-qualifiers APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-ignored-qualifiers APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)",
  "idf_build_set_property(C_COMPILE_OPTIONS -Wno-maybe-uninitialized APPEND)"
]

task espInstallHeaders, "install esp headers":
  let cachedir = "main"/"nimcache"
  if not fileExists(cachedir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cachedir/"nimbase.h"])
    cpFile(nimbasepath, cachedir / "nimbase.h")
  else:
    echo("...nimbase.h already exists")

task espCheckSetup, "check esp app":
  if not fileExists("main/main.nim"):
    echo "Error: main/main.nim not found"
    echo "       the recommended setup is to use `main/main.nim` as the entry point"
  else:
    echo "main/main.nim found"

  if not fileExists("CMakeLists.txt"):
    echo "Error: CMakeLists.txt not found"
    echo "       a top level CMakeLists.txt is required to build the project"
  else:
    echo "CMakeLists.txt found"
  
  if not fileExists("main/CMakeLists.txt"):
    echo "Error: main/CMakeLists.txt not found"
    echo "       a main/CMakeLists.txt is required to build the project"
  else:
    echo "main/CMakeLists.txt found; checking contents..."
    let  cmakelist = readFile("main/CMakeLists.txt")
    var missingParams = false
    for ccp in CCompilerParams:
      if ccp notin cmakelist:
        missingParams = true
    
    if missingParams:
      echo "Warning: some recommended compiler options are not set in `main/CMakeLists.txt`"
      echo "         this is recommended to build the project without warnings for Nim generated C code"
      echo "         the following options are recommended:"
      echo CCompilerParams.join("\n")


task espCompile, "compile esp app":
  exec "rm -Rf main/nimcache"
  exec "nim c main/main.nim"
  espInstallHeadersTask()

task espBuild, "build esp app using idf.py":
  espCompileTask()
  exec "idf.py build"

task espZipPackage, "package esp app":
  var projectName = ""
  for file in listFiles("."):
    let (dir, name, ext) = file.splitFile
    if ext == ".nimble":
      projectName = name
      break
  assert projectName != "", "project name not found!"

  echo "Using project name: ", projectName

  mkDir("build"/"artifacts")
  mkDir("build"/"artifacts"/"bootloader")
  mkDir("build"/"artifacts"/"partition_table")

  cpFile("build" / "flasher_args.json", "build" / "artifacts" / "flasher_args.json")
  cpFile("build" / &"{projectName}.bin", "build" / "artifacts" / &"{projectName}.bin")
  cpFile("build" / &"{projectName}.map", "build" / "artifacts" / &"{projectName}.map")
  cpFile("build" / &"{projectName}.elf", "build" / "artifacts" / &"{projectName}.elf")
  cpFile("build" / "bootloader" / "bootloader.bin", "build" / "artifacts" / "bootloader" / "bootloader.bin")
  cpFile("build" / "bootloader" / "bootloader.elf", "build" / "artifacts" / "bootloader" / "bootloader.elf")
  cpFile("build" / "bootloader" / "bootloader.map", "build" / "artifacts" / "bootloader" / "bootloader.map")
  cpFile("build" / "partition_table" / "partition-table.bin", "build" / "artifacts" / "partition_table" / "partition-table.bin")
  if fileExists("build" / "ota_data_initial.bin"):
    cpFile("build" / "ota_data_initial.bin", "build" / "artifacts" / "ota_data_initial.bin")

  exec "rm -Rf build/artifacts.zip"
  exec "zip -r build/artifacts.zip build/artifacts"
  mvFile("build" / "artifacts.zip", "artifacts.zip")
  echo "Done Copying files"

task espClean, "clean esp app":
  exec "rm -Rf main/nimcache"
  exec "rm -Rf build"

task espListUsb, "list possible usb ports":
  echo "Listing possible usb ports:\n"
  when defined(macosx):
    exec "ls -1 /dev/cu.*"
  elif defined(linux):
    exec "ls -1 /dev/tty.*"
  elif defined(windows):
    exec "wmic path win32_pnpevent where EventType = 2 | findstr /i \"USB\" | findstr /i /v \"ROOT\\"
  else:
    echo "Unsupported platform -- you're on your own!"
  echo "\n"

task espHelp, "show help":
  echo "ESP NimScript Helper"
  echo "Usage: nimble esp <command>"
  echo "Commands:"
  echo "  flash <usb> - flash the esp app to the given usb port"
  echo "  build - build the esp app"
  echo "  monitor <usb> - monitor the esp app on the given usb port"
  echo "  zip - zip the esp app"
  echo "  clean - clean the esp app"

task esp, "esp commands app":
  let args = commandLineParams()
  assert args[0] == "esp"
  let cmdArg = args[1].toLowerAscii()

  case cmdArg:
    of "help":
      espHelpTask()
    of "flash":
      if args.len == 2:
        echo "Warning: no usb port provided, listing possible usb ports"
        espListUsbTask()
        quit(1)

      let usb = args[2].quoteShell()
      assert usb != "", "must provide a usb port"
      echo "using usb: ", usb
      let cmd = &"idf.py -p {usb} flash"
      echo "executing: ", cmd
      exec cmd
    of "build":
      espBuildTask()
    of "monitor":
      let usb = args[2].quoteShell()
      assert usb != "", "must provide a usb port"
      echo "using usb: ", usb
      exec &"idf.py -p {usb} monitor"
    of "zip", "zipartifacts":
      espZipPackageTask()
    of "listusb":
      espListUsbTask()
    of "clean":
      espCleanTask()
    else:
      echo "unknown esp-idf command: ", cmdArg
