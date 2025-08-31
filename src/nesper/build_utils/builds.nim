
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
  espCompileTask()
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

task espSetup, "setup the esp-idf project":
  let idfPath = getEnv("IDF_PATH")
  if idfPath == "":
    echo "Error: IDF_PATH not set"
    echo "Run `. $IDF_PATH/export.sh` and try again"
    quit(1)

  let cmakeLists = readFile(idfPath / "examples" / "get-started" / "hello_world" / "CMakeLists.txt")
  let currentDirName = getCurrentDir().splitFile.name
  let mainCMakeLists = cmakeLists.replace("hello_world", currentDirName)
  writeFile("CMakeLists.txt", mainCMakeLists)

  mkdir("main")

  writeFile("main" / "CMakeLists.txt", dedent"""
  idf_component_register(SRC_DIRS "./nimcache"
                       INCLUDE_DIRS ""
                      )

  idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-label APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-discarded-qualifiers APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-ignored-qualifiers APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-maybe-uninitialized APPEND)
  idf_build_set_property(C_COMPILE_OPTIONS -Wno-incompatible-pointer-types APPEND)
  """)
