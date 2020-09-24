
NIM_CPU := arm
NIMBLE := _nimble
NIMLIB := $(shell nim dump file.json 2>&1 | grep lib | sort | head -n1 )
NIMCACHE := _nimcache

all: nim

		# -d:traceArc \
		# -d:use_malloc
		#--gc:refc \



nim: clean
	nim c \
		--gc:arc \
		-d:debug \
		-d:useMalloc \
		--os:freertos \
		--no_main \
		--cpu:$(NIM_CPU) \
		--nim_cache:"$(NIMCACHE)" \
		--nimble_path:"$(NIMBLE)/pkgs" \
		--compile_only \
		--gen_script \
		example_server.nim

	cp -v $(NIMLIB)/nimbase.h  $(NIMCACHE)/nimbase.h

		# -d:debug \

test-local: clean
	nim c \
		--nim_cache:"$(NIMCACHE)" \
		--nimble_path:"$(NIMBLE)/pkgs" \
		example_server.nim

	cp -v $(NIMLIB)/nimbase.h  $(NIMCACHE)/nimbase.h

clean:
	rm -Rf $(NIMCACHE)
