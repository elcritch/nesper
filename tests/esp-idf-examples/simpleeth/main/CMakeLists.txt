idf_component_register(SRCS "ethernet_example_main.c"
                    INCLUDE_DIRS "")

add_custom_command(
  COMMAND nim c --nimCache:${COMPONENT_DIR}/nimcache/ ${COMPONENT_DIR}/main.nim
  DEPENDS generate ${COMPONENT_DIR}/main.nim
  OUTPUT GeneratedNimIncludes 
  VERBATIM
)

set_source_files_properties(GeneratedNimIncludes properties symbolic true)
add_custom_target(nims DEPENDS ${COMPONENT_DIR}/nimcache/)
add_dependencies(${COMPONENT_LIB} nims)

set_property(DIRECTORY "${COMPONENT_DIR}" APPEND PROPERTY
     ADDITIONAL_MAKE_CLEAN_FILES ${COMPONENT_DIR}/nimcache/ )

idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)
