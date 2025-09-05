switch("define", "ESP_IDF_VERSION=5.5")
switch("define", "esp32s3") # or other variants
switch("define", "nimNetSocketExtras")
switch("define", "nimIoselectorEventfd")
# switch("define", "TcpEchoServer")
# switch("define", "UdpEchoServer")
switch("define", "FastRpcServer")

switch("define", "McuUtilsLoggingLevel:lvlTrace")
# switch("define", "RUN_NCM")

patchFile("stdlib", "cpuinfo", "main/cpuinfo.nim")
patchFile("stdlib", "ioselectors_select", "main/ioselectors_select.nim")

switch("define", "WIFI_SSID", getEnv("WIFI_SSID"))
switch("define", "WIFI_PASSWORD", getEnv("WIFI_PASSWORD"))


include nesper/build_utils/builds
