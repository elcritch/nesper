import std/[os, strutils, strformat]

task espInstallHeaders, "install esp headers":
  let cachedir = "main"/"nimcache"
  if not fileExists(cachedir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cachedir/"nimbase.h"])
    cpFile(nimbasepath, cachedir / "nimbase.h")
  else:
    echo("...nimbase.h already exists")

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
  echo "Done Copying files"

task espClean, "clean esp app":
  exec "rm -Rf main/nimcache"
  exec "rm -Rf build"

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
    of "clean":
      espCleanTask()
    else:
      echo "unknown esp-idf command: ", cmdArg
