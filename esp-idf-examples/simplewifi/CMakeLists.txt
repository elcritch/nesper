# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.5)

# (Not part of the boilerplate)


set(EXTRA_COMPONENT_DIRS $ENV{IDF_PATH}/examples/common_components/protocol_examples_common)
# set(EXTRA_COMPONENT_DIRS src)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(simple-nim-wifi)

idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=unused-label APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=parentheses APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=implicit-function-declaration APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=maybe-uninitialized APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=nonnull APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-error=address APPEND)
idf_build_set_property(C_COMPILE_OPTIONS -Wno-unused-but-set-variable APPEND)