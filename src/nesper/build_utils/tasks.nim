
import os, strutils

# var 
  # default_cache_dir = "." / srcDir / "nimcache"
  # progname = "main.nim"

const
  idf_options = [
    ("setup", "setup new project for compiling with esp-idf"),
    ("compile", "compile nim code for esp-idf project"),
    ("build", "compile and then build esp-idf project"),
    ("clean", "clean esp-idf project and nim code"),
  ]

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

proc idfSetupNimCache(nopts: NimbleArgs) =
  # setup nim project with proper CMakeLists.txt and other files for an esp-idf project
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

proc idfCompileProject*(nopts: NimbleArgs) =
  echo "compiling:"
  # compile nim project

  let
    nimargs = @[
      "c",
      "--nomain",
      "--compileOnly",
      "--nimcache:" & nopts.cachedir.quoteShell(),
      "-d:NimAppMain" ]
    compiler_args = nimargs & @[nopts.projfile.quoteShell()] 
    compiler_cmd = selfExe() & " " & compiler_args.join(" ")

  # [nopts.cachedir, nopts.projfile, nopts.args[1 ..< nopts.args.len()].join(" "), wifidefs]
  echo "args: ", compiler_args  
  echo "cmd: ", compiler_cmd  

  let (outstr, outres) = gorgeEx(compiler_cmd)
  echo "compile res: ", outres
  echo "compile output: ", outstr

proc idfBuildProject*(nopts: NimbleArgs) =
  # build idf project
  echo("building esp-idf project: " )
  exec("idf.py reconfigure")
  exec("idf.py build")

proc printHelp() =
  echo ""
  echo "No command found. The follow help describes the various available commands.\n"
  echo "Nesper IDF Nimble Commands: "
  for idx, (name, desc) in idf_options:
    echo "   ", name, "\t=>\t", desc

proc parseNimbleArgs(): NimbleArgs =
  echo "================================ Nesper ======================================="
  echo ""

  echo("\n\n=== Welcome to the Nimble ESP-IDF helper task! ===\n")

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

  if result.help or result.args.len == 0:
    printHelp()
    onExit()

  if result.debug: echo "[Got nimble args: ", $result, "]\n"

proc idfSetupProject(nopts: var NimbleArgs) =
  echo "setting up project:"
  let app_template_name = "esp32_networking"

  nopts.forceclean = true
  nopts.idfSetupNimCache()

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
    echo "...copying template: ", fileName, " from: ", tmpltPth
    writeFile(srcDir / fileName, readFile(tmpltPth) % tmplt_args )

task idf, "IDF Build Task":

  var
    nopts = parseNimbleArgs() 

  case nopts.args[0]:
  of "setup":
    nopts.idfSetupProject()

  of "compile":
    nopts.idfCompileProject()

  of "build":
    nopts.idfSetupNimCache()

  of "clean":
    echo "cleaning:"

  else:
    echo "help:"
    printHelp()

task idf_compile, "IDF Compile Task":
  echo "idf compile task"
  # selfExec("error")
  selfExec("help")

task idf_build, "IDF Build Task":
  echo "idf build task"
  # selfExec("error")
  selfExec("help")


after idf_compile:
  echo "after compile!!!"

before idf_build:
  echo "before build!!!"
  `idf_compile Task`()
