
import os, strutils

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
  echo "\n================================ Nesper =======================================\n"

  var
    default_cache_dir = "." / srcDir / "nimcache"
    progfile = thisDir() / srcDir / "main.nim"

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
    elif paramStr(idx) == "idf":
      idf_idx = idx
    elif paramStr(idx).startsWith("--nimcache"):
      pre_idf_cache_set = true

  if srcDir != "main":
    if override_srcdir:
      echo "  Warning: esp-idf assumes source files will be located in ./main/ folder "
    else:
      echo "  Error: esp-idf assumes source files will be located in ./main/ folder "
      quit(1)

  # echo "idf params: " & $idf_args 
  let
    npathcmd = "nimble --silent path nesper"
    (nesperPath, rcode) = system.gorgeEx(npathcmd)
  if rcode != 0:
    raise newException( ValueError, "error running getting Nesper path using: `%#`" % [npathcmd])

  result = NimbleArgs(
    args: idf_args,
    cachedir: if pre_idf_cache_set: nimCacheDir() else: default_cache_dir,
    projdir: thisDir(),
    projsrc: srcDir,
    projname: projectName(),
    projfile: progfile,
    nesperpath: nesperPath,
    # forceupdatecache = "--forceUpdateCache" in idf_args
    debug: "--idf-debug" in idf_args,
    forceclean: "--clean" in idf_args,
    help: "--help" in idf_args or "-h" in idf_args
  )

  if result.debug: echo "[Got nimble args: ", $result, "]\n"

task idf_setup, "Setup a new esp-idf / nesper project structure":
  echo "setting up project:"
  let app_template_name = "esp32_networking"
  var nopts = parseNimbleArgs()

  echo "...create project source directory" 
  mkDir(nopts.projsrc)

  echo "...writing cmake lists" 
  let
    cmake_template = readFile(nopts.nesperpath / "nesper" / "build_utils" / "templates" / "CMakeLists.txt")
    template_files = listFiles(nopts.nesperpath / "nesper" / "build_utils" / "templates" / app_template_name )
    tmplt_args = [
      "NIMBLE_PROJ_NAME", nopts.projname,
      "NIMBLE_NIMCACHE", srcDir,
      ]

  writeFile("CMakeLists.txt", cmake_template % tmplt_args)

  for tmpltPth in template_files:
    let fileName = tmpltPth.extractFilename()
    echo "...copying template: ", fileName, " from: ", tmpltPth, " to: ", getCurrentDir()
    writeFile(nopts.projsrc / fileName, readFile(tmpltPth) % tmplt_args )


task idf_install_headers, "Install nim headers":
  let
    nopts = parseNimbleArgs()
    cachedir = nopts.cachedir

  if not fileExists(cachedir / "nimbase.h"):
    let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"

    echo("...copying nimbase file into the Nim cache directory ($#)" % [cachedir/"nimbase.h"])
    cpFile(nimbasepath, cachedir / "nimbase.h")
  else:
    echo("...nimbase.h already exists")

task idf_clean, "Clean nimcache":
  let
    nopts = parseNimbleArgs()
    cachedir = nopts.cachedir
  
  if dirExists(cachedir):
    echo "...removing nimcache"
    rmDir(cachedir)
  else:
    echo "...not removing nimcache, directory not found"
  

task idf_compile, "Compile Nim project for esp-idf program":
  # compile nim project
  var nopts = parseNimbleArgs() 

  echo "compiling:"
  let
    nimargs = @[
      "c",
      "--nomain",
      "--compileOnly",
      "--nimcache:" & nopts.cachedir.quoteShell(),
      "-d:NimAppMain" ]
    compiler_cmd = nimargs.join() & " " & nopts.projfile.quoteShell() 

  if nopts.debug:
    echo "idf compile: command: ", compiler_cmd  

  # selfExec("error")
  cd(nopts.projdir)
  selfExec(compiler_cmd)

task idf_build, "Build esp-idf project":
  echo "idf build task"
  # selfExec("error")
  # selfExec("help")


### Actions to ensure correct steps occur before/after certain tasks ###

after idf_compile:
  echo "after compile!!!"
  idfInstallHeadersTask()

before idf_build:
  echo "before build!!!"
  idfCompileTask()
