import os, strutils

task prepare, "Compile to C code":
  mkDir("./main/nimcache")
  let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"
  let nimcachepath = "main" / "nimcache"
  cpFile(nimbasepath, nimcachepath / "nimbase.h")
  let params = commandLineParams()
  let file = params[1]
  let rest = params[2..high(params)].join(" ")
  
  let wifi_ssid = getEnv("WIFI_SSID")
  let wifi_pass = getEnv("WIFI_PASS")

  let wifidefs =
    if wifi_ssid != "" and wifi_pass != "":
      "-d:WIFI_SSID=$1 -d:WIFI_PASSWORD=$2 " % [wifi_ssid, wifi_pass]
    else:
      ""

  let
    cmd = "nim c --os:freertos --cpu:esp --nomain --nimcache:$1 --compileOnly -d:NimAppMain $4 $3 $2 " %
              [nimcachepath, file, rest, wifidefs]

  echo("cmd: " & cmd)
  exec(cmd)
