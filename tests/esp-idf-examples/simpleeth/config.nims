import os
import strutils
import options

task printlib, "Printout Nim library":
  switch("hints", "off")
  let nimbasepath = selfExe().splitFile.dir.parentDir / "lib"
  echo(nimbasepath)

task copylib, "Copy nimbase.h to nimcache/":
  let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"
  cpFile(nimbasepath, "nimcache" / "nimbase.h")

