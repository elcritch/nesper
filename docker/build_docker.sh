#!/bin/bash

docker image rm -f esp_nim
docker build -t esp_nim ./