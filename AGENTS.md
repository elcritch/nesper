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

## ESP‑IDF Header Wrapping
- Enums with conditional members/values: wrap as `distinct cint` types and import members as `let` constants with `{.importc, header: hdr.}`. Examples: `i2c_port_t`, `i2c_mode_t`, `ledc_mode_t`, `ledc_intr_type_t`, `ledc_duty_direction_t`, and clock source selections. This avoids baking SoC/IDF‑specific numeric values.
- Stable, contiguous enums: use Nim `enum` with `{.size: sizeof(cint).}` when definitions don’t vary across SoCs. Examples: `i2c_rw_t`, `i2c_trans_mode_t`, `i2c_ack_type_t`, `i2c_slave_stretch_cause_t`, `ledc_timer_t`, `ledc_channel_t`, `ledc_timer_bit_t`, `ledc_fade_mode_t`.
- Typedef passthroughs to varying backends: prefer `distinct cint`/`cint` plus imported constants for items like `i2c_clock_source_t`, `ledc_clk_cfg_t`, `ledc_clk_src_t`. Use `{.importc, header: hdr.}` and, if needed to break cycles, alias via an `importc` type (e.g., `= soc_periph_*`), or a plain `cint` placeholder with separately imported constants.
- Structs: import C structs as `{.importc, bycopy.}` Nim `object`s with matching fields and integer widths (e.g., `i2c_hal_clk_config_t`).
- Sentinels and macros: `*_MAX` or alias members may be imported as `let` with `distinct cint` types and can be omitted if unstable across targets. Favor names over values; let ESP‑IDF supply the numeric mapping.
- Header binding: set `const hdr = "<hal/<name>.h>"` and annotate all imports with `header: hdr` to bind directly to ESP‑IDF headers.

Reference patterns:
- `tests/c_headers/hal/i2c_types.h` → `src/nesper/esp/hal/i2c_types.nim`: ports/modes as `distinct cint` + `let`; stable I2C enums as Nim enums; clock source typedef mapped via `cint` + imported constants.
- `tests/c_headers/hal/ledc_types.h` → `src/nesper/esp/hal/ledc_types.nim`: modes/interrupts/duty‑dir/clock sources as `distinct cint` + `let`; timers/channels/bit‑width/fade mode as Nim enums.
