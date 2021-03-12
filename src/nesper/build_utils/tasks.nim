
import os, strutils, sequtils

type
  NimbleArgs = object
    projdir: string
    projname: string
    projsrc: string
    projfile: string
    nesperpath: string
    args: seq[string]
    cachedir: string
    debug: bool
    forceclean: bool
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
    idf_args: seq[string] = @[]

  for idx in 0..paramCount():
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

  result = NimbleArgs(
    args: idf_args,
    cachedir: if pre_idf_cache_set: nimCacheDir() else: default_cache_dir,
    projdir: thisDir(),
    projsrc: projsrc,
    projname: projectName(),
    projfile: progfile,
    nesperpath: nesperPath,
    # forceupdatecache = "--forceUpdateCache" in idf_args
    debug: "--esp-debug" in idf_args,
    forceclean: "--clean" in idf_args,
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
  let
    nimargs = @[
      "c",
      "--nomain",
      "--compileOnly",
      "--nimcache:" & nopts.cachedir.quoteShell(),
      "-d:NimAppMain" ]
    compiler_cmd = nimargs.join(" ") & " " & nopts.projfile.quoteShell() 

  if nopts.debug:
    echo "idf compile: command: ", compiler_cmd  

  # selfExec("error")
  cd(nopts.projdir)
  selfExec(compiler_cmd)

task esp_build, "Build esp-idf project":
  echo "\n[Nesper ESP] Building ESP-IDF project:"

  exec("idf.py reconfigure")
  exec("idf.py build")
  # selfExec("error")
  # selfExec("help")


### Actions to ensure correct steps occur before/after certain tasks ###

after esp_compile:
  espInstallHeadersTask()

before esp_build:
  espCompileTask()
