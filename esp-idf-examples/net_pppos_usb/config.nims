switch("define", "ESP_IDF_VERSION=5.5")
switch("define", "esp32s3") # or other variants

switch("define", "RUN_NCM")

include nesper/build_utils/builds
