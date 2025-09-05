switch("define", "ESP_IDF_VERSION=5.5")
switch("define", "esp32s3") # or other variants
switch("define", "nimNetSocketExtras")
switch("define", "nimIoselectorEventfd")

switch("define", "FastRpcServer")

switch("define", "McuUtilsLoggingLevel:lvlTrace")

patchFile("stdlib", "ioselectors_select", "main/ioselectors_select.nim")

switch("define", "EXAMPLE_ESP_WIFI_SSID=" & getEnv("WIFI_SSID"))
switch("define", "EXAMPLE_ESP_WIFI_PASS=" & getEnv("WIFI_PASSWORD"))


include nesper/build_utils/builds
