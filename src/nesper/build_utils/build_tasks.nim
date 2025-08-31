
import std/[os, strutils]

var cacheDir* = "main" / "nimcache"

task espInstallHeaders, "Install nim headers":
  echo "\n[Nesper ESP] Installing nim headers:"

  if not fileExists(cacheDir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cacheDir / "nimbase.h"])
    cpFile(nimbasepath, "main/nimcache/nimbase.h")
  else:
    echo("...nimbase.h already exists")

task espCompile, "compile the Nim code":
  # Ensure a clean Nim cache to avoid duplicate stdlib objects
  echo("...cleaning Nim cache directory: " & cacheDir)
  rmDir(cacheDir)
  exec("nim c -d:debug main/main.nim")
  espInstallHeadersTask()

task espBuild, "Build esp-idf project":
  compileTask()
  echo "\n[Nesper ESP] Building ESP-IDF project:"

  if findExe("idf.py") == "":
    echo "\nError: idf.py not found. Please run the esp-idf export commands: `. $IDF_PATH/export.sh` and try again.\n"
    quit(2)

  exec("idf.py reconfigure")
  exec("idf.py build")

task espClean, "clean the Nim code":
  exec("idf.py clean")
  rmDir(cacheDir)
  mkDir(cacheDir)
