# Package

version       = "0.1.0"
author        = "Author Name"
description   = "Nesper example"
license       = "none"
srcDir        = "src"

# Dependencies
requires "nim >= 1.4.0"
requires "nesper >= 0.5.0"
# includes nimble tasks for building Nim esp-idf projects
include nesper/build_utils/tasks
