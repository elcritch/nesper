
idf_component_register(SRC_DIRS "./nimcache"
                    INCLUDE_DIRS ""
                    REQUIRES lwip newlib nvs_flash app_update)

# set(C_COMPILE_OPTIONS "${C_COMPILE_OPTIONS} -Wno-error=unused-label")
# list(APPEND C_COMPILE_OPTIONS "-Wno-error=unused-label ")

idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-discarded-qualifiers APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-ignored-qualifiers APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)
