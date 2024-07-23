
# ESP-IDF Components library Wrappers

Some basic wrappers for [esp-idf-lib](https://github.com/UncleRus/esp-idf-lib).

Take a look. Just add it to your CmakeLists.txt file: 

```cmake
cmake_minimum_required(VERSION 3.11)
include(FetchContent)
FetchContent_Declare(
  espidflib
  GIT_REPOSITORY https://github.com/UncleRus/esp-idf-lib.git
)
FetchContent_MakeAvailable(espidflib)

...

set(EXTRA_COMPONENT_DIRS ${espidflib_SOURCE_DIR}/components $ENV{IDF_PATH}/examples/common_components/protocol_examples_common)


```

