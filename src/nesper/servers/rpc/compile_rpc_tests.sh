#!/bin/sh

rm -Rf rpcsocket_json_cache

nim c --cincludes:../../../../tests/c_headers/mock --nimCache:rpcsocket_json_cache/ --gc:arc -d:useMalloc --debugger:native --threads:on --tls_emulation:off --verbosity:2 -d:release rpcsocket_json.nim 

