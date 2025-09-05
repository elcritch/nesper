switch("define", "ESP_IDF_VERSION=5.5")
switch("define", "esp32s3") # or other variants
switch("define", "nimNetSocketExtras")
switch("define", "nimIoselectorEventfd")

switch("define", "McuUtilsLoggingLevel:lvlTrace")

patchFile("stdlib", "ioselectors_select", "main/ioselectors_select.nim")

switch("define", "WIFI_SSID=" & getEnv("WIFI_SSID"))
switch("define", "WIFI_PASSWORD=" & getEnv("WIFI_PASSWORD"))


include nesper/build_utils/builds
