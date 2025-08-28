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
