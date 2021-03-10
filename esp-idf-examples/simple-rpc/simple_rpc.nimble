# Package

version       = "0.1.0"
author        = "Author Name"
description   = "Nesper example"
license       = "none"
srcDir        = "src"

# Dependencies
requires "nim >= 1.4.0"
requires "nesper >= 0.5.0"

# nesperVersion = "ESP_IDF_V4_0"
# import nesper/build_tasks

# nim prepare main/main.nim --nimblePath:main/nimble/pkgs -d:ESP_IDF_V4_0  -d:TcpEchoServer  && idf.py reconfigure 

include nesper/build_tasks
