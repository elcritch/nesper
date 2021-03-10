
import os, strutils

var 
  default_cache_dir = "." / srcDir / "nimcache"

type
  NimbleArgs = object
    projdir: string
    projname: string
    nesperpath: string
    args: seq[string]
    cachedir: string
    debug: bool
    forceclean: bool
    help: bool

proc idfSetupNimCache(nopts: NimbleArgs) =
  let
    cachedir = nopts.cachedir

  if nopts.forceclean:
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


proc idfCompileProject*(cachedir: string, forceUpdateCache=false) =
  discard "todo"

proc idfBuildProject*(cachedir: string, forceUpdateCache=false) =
  discard "todo"
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

proc parseNimbleArgs(): NimbleArgs =
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

  # echo "idf params: " & $idf_args 
  let
    npathcmd = "nimble --silent path nesper"
    (nesperPath, rcode) = system.gorgeEx(npathcmd)
  if rcode != 0:
    raise newException( ValueError, "error running getting Nesper path using: `%#`" % [npathcmd])

  return NimbleArgs(
    args: idf_args,
    cachedir: if pre_idf_cache_set: nimCacheDir() else: default_cache_dir,
    projdir: thisDir(),
    projname: projectName(),
    nesperpath: nesperPath,
    # forceupdatecache = "--forceUpdateCache" in idf_args
    debug: "--idf-debug" in idf_args,
    forceclean: "--clean" in idf_args,
    help: "--help" in idf_args or "-h" in idf_args
    )
  
const
  idf_options = [
    ("setup", "setup new project for compiling with esp-idf"),
    ("compile", "compile nim code for esp-idf project"),
    ("build", "compile and then build esp-idf project"),
    ("clean", "clean esp-idf project and nim code"),
  ]

proc idfSetupProject(nopts: var NimbleArgs) =
  echo "setting up project:"

  nopts.forceclean = true
  nopts.idfSetupNimCache()

  echo "...writing cmake lists" 
  let
    cmake_template = readFile(nopts.nesperpath / "nesper/build_utils/templates/CMakeLists.txt")

  writeFile("CMakeLists.txt", cmake_template % [nopts.projname])

proc printHelp() =
  echo ""
  echo "No command found. The follow help describes the various available commands.\n"
  echo "Nesper IDF Nimble Commands: "
  for idx, (name, desc) in idf_options:
    echo "   ", name, "\t=>\t", desc

task idf, "IDF Build Task":

  var
    nopts = parseNimbleArgs() 

  echo("\n\n=== Welcome to the Nimble ESP-IDF helper task! ===\n")

  if nopts.help or nopts.args.len == 0:
    printHelp()
    return

  if nopts.debug:
    echo "[Got nimble args: ", $nopts, "]\n"

  case nopts.args[0]:
  of "setup": nopts.idfSetupProject()
  of "compile":
    echo "compiling:"
    nopts.idfSetupNimCache()

  of "build":
    echo "building:"
    nopts.idfSetupNimCache()

  of "clean":
    echo "cleaning:"

  else:
    echo "help:"
    printHelp()






