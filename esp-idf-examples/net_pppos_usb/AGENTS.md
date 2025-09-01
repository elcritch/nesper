# Repository Guidelines

## Project Structure & Module Organization
- main/: Nim sources and component config. Entrypoint: main/main.nim. Generated C lives in main/nimcache/.
- deps/: Vendored Nim dependencies (nesper, unittest2, etc.). Managed by Nimble/Atlas.
- build/: ESP‑IDF CMake/Ninja outputs and flash args. Not for commits.
- CMakeLists.txt: Top‑level ESP‑IDF project file.
- config.nims, nim.cfg: Nim/nesper build configuration and include paths.
- sdkconfig, sdkconfig.defaults, partitions.csv: ESP‑IDF configuration and partition table.

## Build, Test, and Development Commands
- nim espBuild: Compile Nim and build the ESP‑IDF project (preferred dev loop).
- nim espCompile: Compile Nim to C into main/nimcache/ (no ESP‑IDF build).
- idf.py set-target esp32s3: Ensure target matches config.nims.
- idf.py -p /dev/ttyUSB0 flash monitor: Flash and open serial monitor (adjust port).
- idf.py build: Rebuild from generated C when Nim hasn’t changed.
- Clean: idf.py fullclean && rm -rf main/nimcache

Environment: export IDF_PATH and source "$IDF_PATH/export.sh" before building.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; keep lines concise.
- Nim style: camelCase procs, PascalCase types, UPPER_SNAKE constants. Exported symbols end with *.
- Modules: lower_snake filenames (e.g., ppp_client.nim).
- Formatting: nimpretty --indent:2 main/*.nim
- Use nesper APIs where possible; isolate raw ESP‑IDF calls behind small Nim wrappers.

## Testing Guidelines
- Current repo has no tests. Add Nim tests under tests/ using unittest2 (deps/unittest2).
- Naming: tests/test_*.nim (e.g., tests/test_ppp.nim).
- Run: nim c -r tests/test_ppp.nim. Consider a nimble test task for CI later.

## Commit & Pull Request Guidelines
- Commits: short, imperative summaries (e.g., "ppp: add link setup").
- PRs: include purpose, build/flash steps, linked issues, and serial logs/screenshots for hardware changes.
- Scope: keep changes focused; avoid committing build/ outputs or local sdkconfig changes unless intentional.

## Security & Configuration Tips
- Do not commit credentials or secrets in sdkconfig or sources.
- Match target to hardware (esp32s3 by default in config.nims); update if using another SoC.
- Document required pins/peripherals in PRs when relevant.
