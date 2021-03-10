
import os, strutils

var 
  default_cache_dir = "." / srcDir / "nimcache"

proc setupNimCache(cachedir: string, forceUpdateCache=false) =

  if forceUpdateCache:
    echo("...deleting cachedir")
    rmDir(cachedir)

  if not cachedir.dirExists():
    mkDir(cachedir)
  else:
    echo("...cachedir already exists")

  if not fileExists(cachedir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cachedir/"nimbase.h"])
    cpFile(nimbasepath, cachedir / "nimbase.h")
  else:
    echo("...nimbase.h already exists")


  # let params = commandLineParams()
  # let file = params[1]
  # let rest = params[2..high(params)].join(" ")
  
  # let wifi_ssid = getEnv("WIFI_SSID")
  # let wifi_pass = getEnv("WIFI_PASSWORD")

  # let wifidefs =
  #   if wifi_ssid != "" and wifi_pass != "":
  #     "-d:WIFI_SSID=$1 -d:WIFI_PASSWORD=$2 " % [wifi_ssid, wifi_pass]
  #   else:
  #     ""

  # let
  #   cmd = "nim c --os:freertos --cpu:esp --nomain --nimcache:$1 --compileOnly -d:NimAppMain $4 $3 $2 " %
  #             [nimcachepath, file, rest, wifidefs]

  # echo("cmd: " & cmd)
  # exec(cmd)

task idf, "IDF Build Task":
  echo("Hello ESP-IDF!")

  var
    idf_idx = -1
    pre_idf_cache_set = false
    idf_args: seq[string] = @[]

  for idx in 0..paramCount():
    if idf_idx > 0:
      idf_args.add(paramStr(idx))
    elif paramStr(idx) == "idf":
      idf_idx = idx
    elif paramStr(idx).startsWith("--nimcache"):
      pre_idf_cache_set = true

  echo "idf params: " & $idf_args 

  let
    cachedir = if pre_idf_cache_set: nimCacheDir() else: default_cache_dir
    projdir = thisDir()
    # forceupdatecache = "--forceUpdateCache" in idf_args
    forceclean = "--clean" in idf_args
  
  case idf_args[0]:
  of "compile":
    echo "compiling..."
    cachedir.setupNimCache(forceUpdateCache=forceclean)
  of "build":
    echo "building..."
    cachedir.setupNimCache(forceUpdateCache=forceclean)
  of "clean":
    echo "cleaning..."


  # setCommand




