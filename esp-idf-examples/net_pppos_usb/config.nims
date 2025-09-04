switch("define", "ESP_IDF_VERSION=5.5")
switch("define", "esp32s3") # or other variants
switch("define", "nimNetSocketExtras")
# switch("define", "TcpEchoServer")
# switch("define", "UdpEchoServer")
switch("define", "FastRpcServer")

# switch("define", "RUN_NCM")

patchFile("stdlib", "cpuinfo", "main/cpuinfo.nim")

include nesper/build_utils/builds
