
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${COMPONENT_DIR}/nimcache/compile_main.sh )

# execute_process(COMMAND nim dump 2>&1 | grep 'lib$' | sort | tail -n1 | head -n1 OUTPUT_VARIABLE NIMLIB)
execute_process(COMMAND nim printlib OUTPUT_VARIABLE NIMLIB)

execute_process(
  COMMAND nim printlib
  COMMAND nim c --nimCache:${COMPONENT_DIR}/nimcache/ --noMain --genScript --compileOnly ${COMPONENT_DIR}/main.nim
  WORKING_DIRECTORY ${COMPONENT_DIR}
  COMMAND_ECHO STDOUT
)

file(GLOB nim_sources ${COMPONENT_DIR}/nimcache/*.c )

message("NIMLIB::: " ${NIMLIB} )
list(APPEND SRCS ${nim_sources})

idf_component_register(SRCS "ethernet_example_main.c" ${nim_sources}
  INCLUDE_DIRS ""
)

idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)

target_compile_options(${COMPONENT_LIB} PRIVATE -I${NIMLIB} )
