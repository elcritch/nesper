#!/bin/bash
pushd ../
docker run --rm -v $PWD:/project --device=/dev/ttyUSB0 -w /project -it esp_nim
popd