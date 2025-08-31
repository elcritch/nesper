# Repository Guidelines

## Project Structure & Modules
- `src/nesper/*`: Core Nim wrappers and utilities for ESP‑IDF (e.g., `gpios.nim`, `i2cs.nim`, `wifi.nim`).
- `tests/`: Compile-time and execution tests. Subfolders: `driver/`, `storage/`, `exec_tests/`.
- `esp-idf-examples/`: Reference projects showing full ESP‑IDF builds (e.g., `simplewifi`).
- Root files: `nesper.nimble`, `config.nims`, `nim.cfg`, `Makefile`.

## Build, Test, and Dev Commands
- `atlas install`: Install the deps.
- `nim test`: Run the full test suite (compiles FreeRTOS targets and runs exec tests).
- Focused suites (Atlas tasks defined in `config.nims`):
  - `nim test_general`
  - `nim test_drivers`
  - `nim test_storage`
  - `nim test_execs`
- Quick compile of a file: `nim c --os:freertos tests/tgeneral.nim`.
- Examples: build inside `esp-idf-examples/<name>` per that folder’s README/Makefile.

## Coding Style & Naming
- Indentation: 2 spaces; no tabs.
- Follow Nim style: types `PascalCase`, procs `camelCase`, modules `snake_case`.
- Wrappers mirror ESP‑IDF C names in `snake_case`; Nim‑friendly APIs use `camelCase`.
- Run formatter before PRs: `nimpretty --indent:2 src/nesper/*.nim`.

## Testing Guidelines
- Framework: Atlas executes tasks from `config.nims`.
- Naming: test files start with `t` (e.g., `tests/tgpios.nim`).
- Coverage: not enforced; add tests for new modules and failure cases.
- Local run examples:
  - All tests: `nim test`
  - Single file compile-only: `nim c --compileOnly:on --os:freertos tests/tspis.nim`

## Commit & PR Guidelines
- Commits: short, imperative summaries (e.g., `add i2c_master`, `cleanup`).
- PRs must include: purpose/summary, key changes, test plan (`atlas test` output or steps), and any related issues.
- Keep changes scoped; update docs and examples when APIs change.

## Security & Configuration
- ESP‑IDF version is controlled via `ESP_IDF_VERSION` (defaults to `4.4`) and Nim defines in `config.nims`/`nim.cfg`.
- Ensure your ESP‑IDF toolchain is installed and on PATH before building examples.

## ESP‑IDF Wrapping (HAL & Drivers)
- Header binding: for HAL, set `const hdr = "<hal/<name>.h>"` and annotate imports with `header: hdr`. For drivers, use `{.push header: "<driver/<name>.h>".}` at the top of the module.
- Enums: if stable and contiguous across SoCs, use Nim `enum` with `{.size: sizeof(cint).}`. If members/values vary or are `#if`-guarded, define a `distinct cint` type and import each member as a `let` with `{.importc, header: hdr.}` (or module header).
- Typedef passthroughs: where C uses typedefs to SoC‑specific sources, use `distinct cint`/`cint` plus imported constants, or alias to the ESP‑IDF typedef via `importc` (e.g., `= soc_periph_*`). Treat `*_MAX` sentinels as imported constants if needed, avoiding hardcoded values.
- Structs: import C structs as `{.importc, bycopy.}` Nim `object`s with matching field types. Represent bitfields with inner objects using `bitsize`, and flatten anonymous unions while guarding alternatives with `when defined(...)`.
- Opaque handles: model `typedef struct X* handle_t` as a pointer to an imported incomplete Nim object to avoid include loops. For cycles, use a placeholder in the types module and the real struct in another module, bridged with converters that cast between the two. Example: `i2c_master_bus_config_tt` (placeholder) ↔ `i2c_master_bus_config_t` (real) with `converter toHandle*` both ways.
- Callbacks: map function pointer typedefs to Nim proc types with `{.cdecl.}` and import associated payload structs by copy.
- Macros/constants: convert `#define` to Nim `const` (e.g., `I2C_DEVICE_ADDRESS_NOT_USED = 0xffff`). Use `csize_t` for `size_t`, and `uint8/uint16/uint32` for fixed‑width integers.
- Procs: import driver/HAL functions verbatim with `{.cdecl, importc.}`, using `ptr` for out‑params/buffers and `csize_t` for sizes.

Reference patterns:
- HAL: `tests/c_headers/hal/i2c_types.h` → `src/nesper/esp/hal/i2c_types.nim` (ports/modes as `distinct cint` + `let`; stable enums as Nim enums; clock source typedef as `cint` + imported constants). `tests/c_headers/hal/ledc_types.h` → `src/nesper/esp/hal/ledc_types.nim` (modes/interrupts/duty‑dir/clock sources as `distinct cint` + `let`; timers/channels/bit‑width/fade mode as Nim enums).
- Drivers v5: `tests/c_headers/i2c_types.h` → `src/nesper/esp/driver_v5/i2c_types.nim` (stable enums; opaque handles via placeholder incomplete type; callback typedefs). `tests/c_headers/i2c_master.h` → `src/nesper/esp/driver_v5/i2c_master.nim` (full struct mapping, bitfields, anonymous union guard, `I2C_DEVICE_ADDRESS_NOT_USED` const, converters between placeholder and real config type; driver procs imported verbatim).
