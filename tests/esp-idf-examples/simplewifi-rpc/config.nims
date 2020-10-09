import os

task prepare, "Compile to C code":
  mkDir("./main/nimcache")
  let nimbasepath = selfExe().splitFile.dir.parentDir / "lib" / "nimbase.h"
  let nimcachepath = "main" / "nimcache"
  cpFile(nimbasepath, nimcachepath / "nimbase.h")
  let file = paramStr(2)
  exec("nim c --os:freertos --cpu:esp --nomain --nimcache:" & nimcachepath & " --compileonly " & file)
