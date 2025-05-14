import std/[os, strutils]

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

task espMonitor, "monitor esp app":
  exec "idf.py monitor"

task espClean, "clean esp app":
  exec "rm -Rf main/nimcache"
  exec "rm -Rf build"

task esp, "esp commands app":
  let args = commandLineParams()
  echo "commandLineParams: ", commandLineParams()

  assert args[0] == "esp"

  if args[1] == "flash":
    let usb = args[2].quoteShell()
    assert usb != "", "must provide a usb port"
    echo "using usb: ", usb
    let cmd = "idf.py -p " & usb & " flash"
    echo "executing: ", cmd
    exec cmd
  elif args[1] == "build":
    espBuildTask()
  elif args[1] == "monitor":
    espMonitorTask()
  elif args[1] == "clean":
    espCleanTask()
  else:
    echo "unknown esp-idf command: ", args[1]
