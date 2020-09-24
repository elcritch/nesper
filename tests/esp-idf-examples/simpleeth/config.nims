import os
import strutils

task printlib, "Printout Nim library":
  switch("hints", "off")
  let nimbasepath = selfExe().splitFile.dir.parentDir / "lib"
  echo(nimbasepath)


