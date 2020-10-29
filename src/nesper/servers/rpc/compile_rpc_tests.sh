#!/bin/sh

rm -Rf rpcsocket_json_cache

nim c --cincludes:../../../../tests/c_headers/mock --nimCache:rpcsocket_json_cache/ --gc:arc  --debugger:native --threads:on --tls_emulation:off --verbosity:2 -d:debug rpcsocket_json.nim 

