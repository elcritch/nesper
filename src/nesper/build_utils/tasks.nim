
import os, strutils, sequtils

type
  NimbleArgs = object
    projdir: string
    projname: string
    projsrc: string
    projfile: string
    nesperpath: string
    args: seq[string]
    child_args: seq[string]
    cachedir: string
    esp_idf_version: string
    wifi_args: string
    debug: bool
    forceclean: bool
    distclean: bool
    help: bool

proc parseNimbleArgs(): NimbleArgs =
  var
    projsrc = if srcDir == "": "." / "main" else: srcDir
    default_cache_dir = "." / projsrc / "nimcache"
    progfile = thisDir() / projsrc / "main.nim"

  if bin.len() >= 1:
    progfile = bin[0]

  var
    idf_idx = -1
    pre_idf_cache_set = false
    override_srcdir = false
    post_idf_args = false
    idf_args: seq[string] = @[]
    child_args: seq[string] = @[]


  for idx in 0..paramCount():
    if post_idf_args:
      child_args.add(paramStr(idx))
      continue
    elif paramStr(idx) == "--":
      post_idf_args = true
      continue

    # setup to find all commands after "esp" commands
    if idf_idx > 0:
      idf_args.add(paramStr(idx))
    elif paramStr(idx).startsWith("esp"):
      idf_idx = idx
    elif paramStr(idx).startsWith("--nimcache"):
      pre_idf_cache_set = true

  if not projsrc.endsWith("main"):
    if override_srcdir:
      echo "  Warning: esp-idf assumes source files will be located in ./main/ folder "
    else:
      echo "  Error: esp-idf assumes source files will be located in ./main/ folder "
      echo "  got source directory: ", projsrc
      quit(1)

  let
    npathcmd = "nimble --silent path nesper"
    (nesperPath, rcode) = system.gorgeEx(npathcmd)
  if rcode != 0:
    raise newException( ValueError, "error running getting Nesper path using: `%#`" % [npathcmd])

  # Try setting wifi password
  let wifi_ssid = getEnv("ESP_WIFI_SSID")
  let wifi_pass = getEnv("ESP_WIFI_PASS")

  let wifidefs =
    if wifi_ssid != "" and wifi_pass != "":
      echo "...found env variables for wifi credentials"
      "-d:WIFI_SSID=$1 -d:WIFI_PASS=$2 " % [wifi_ssid.quoteShell(), wifi_pass.quoteShell()]
    else:
      ""

  result = NimbleArgs(
    args: idf_args,
    child_args: child_args,
    cachedir: if pre_idf_cache_set: nimCacheDir() else: default_cache_dir,
    projdir: thisDir(),
    projsrc: projsrc,
    projname: projectName(),
    projfile: progfile,
    nesperpath: nesperPath,
    # forceupdatecache = "--forceUpdateCache" in idf_args
    esp_idf_version: "ESP_IDF_V4_0", # FIXME
    wifi_args: wifidefs,
    debug: "--esp-debug" in idf_args,
    forceclean: "--clean" in idf_args,
    distclean: "--dist-clean" in idf_args,
    help: "--help" in idf_args or "-h" in idf_args
  )

  if result.debug: echo "[Got nimble args: ", $result, "]\n"

task esp_setup, "Setup a new esp-idf / nesper project structure":
  echo "\n[Nesper ESP] setting up project:"
  let app_template_name = "esp32_networking"
  var nopts = parseNimbleArgs()

  echo "...create project source directory" 
  mkDir(nopts.projsrc)

  echo "...writing cmake lists" 
  let
    cmake_template = readFile(nopts.nesperpath / "nesper" / "build_utils" / "templates" / "CMakeLists.txt")
    template_files = listFiles(nopts.nesperpath / "nesper" / "build_utils" / "templates" / app_template_name )
  var
    tmplt_args = @[
      "NIMBLE_PROJ_NAME", nopts.projname,
      "NIMBLE_NIMCACHE", nopts.cachedir,
      ]

  writeFile("CMakeLists.txt", cmake_template % tmplt_args)

  tmplt_args.insert(["NIMBLE_NIMCACHE", nopts.cachedir.relativePath(nopts.projsrc) ], 0)

  for tmpltPth in template_files:
    let fileName = tmpltPth.extractFilename()
    echo "...copying template: ", fileName, " from: ", tmpltPth, " to: ", getCurrentDir()
    writeFile(nopts.projsrc / fileName, readFile(tmpltPth) % tmplt_args )


task esp_install_headers, "Install nim headers":
  echo "\n[Nesper ESP] Installing nim headers:"
  let
    nopts = parseNimbleArgs()
    cachedir = nopts.cachedir

  if not fileExists(cachedir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cachedir/"nimbase.h"])
    cpFile(nimbasepath, cachedir / "nimbase.h")
  else:
    echo("...nimbase.h already exists")

task esp_clean, "Clean nimcache":
  echo "\n[Nesper ESP] Cleaning nimcache:"
  let
    nopts = parseNimbleArgs()
    cachedir = nopts.cachedir
  
  if dirExists(cachedir):
    echo "...removing nimcache"
    rmDir(cachedir)
  else:
    echo "...not removing nimcache, directory not found"
  

task esp_compile, "Compile Nim project for esp-idf program":
  # compile nim project
  var nopts = parseNimbleArgs() 

  echo "\n[Nesper ESP] Compiling:"

  if nopts.forceclean or nopts.distclean:
    echo "...cleaning nim cache"
    rmDir(nopts.cachedir)

  if nopts.distclean:
    echo "...cleaning esp-idf build cache"
    rmDir(nopts.projdir / "build")

  let
    nimargs = @[
      "c",
      "--nomain",
      "--compileOnly",
      "--nimcache:" & nopts.cachedir.quoteShell(),
      "-d:NimAppMain",
      "-d:" & nopts.esp_idf_version ].join(" ") 
    childargs = nopts.child_args.mapIt(it.quoteShell()).join(" ")
    wifidefs = nopts.wifi_args
    compiler_cmd = nimargs & " " & wifidefs & " " & childargs & " " & nopts.projfile.quoteShell() 
  
  echo "compiler_cmd: ", compiler_cmd
  echo "compiler_childargs: ", nopts.child_args

  if nopts.debug:
    echo "idf compile: command: ", compiler_cmd  

  # selfExec("error")
  cd(nopts.projdir)
  selfExec(compiler_cmd)

task esp_build, "Build esp-idf project":
  echo "\n[Nesper ESP] Building ESP-IDF project:"

  if findExe("idf.py") == "":
    echo "\nError: idf.py not found. Please run the esp-idf export commands: `. $IDF_PATH/export.sh` and try again.\n"
    quit(2)

  exec("idf.py reconfigure")
  exec("idf.py build")


### Actions to ensure correct steps occur before/after certain tasks ###

after esp_compile:
  espInstallHeadersTask()

before esp_build:
  espCompileTask()
  espInstallHeadersTask()
