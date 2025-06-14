# AGENTS Instructions for dry-wit repository

This repository primarily contains Bash code under the `src` directory. The
files follow a consistent format which should be respected when modifying or
adding new scripts.

## Coding style

- All scripts in `src/` are Bash scripts.
- Functions must be declared using `function name() {` syntax.
- **Indentation**: Use two spaces for each indentation level. No hard tabs.
- Each `.dw` module begins with metadata comments:
  - `# mod: <module>`
  - `# api: public|private`
  - `# txt: <description>`
- Document functions with comment blocks before the definition using the same
  style (`# fun:`, `# api:`, `# txt:`, `# opt:` and `# use:` lines).
- **File footer**: Most source files end with the following Vim modeline. Keep
  this line as the last line in all `.dw` and `.sh` files:
  ```bash
  # vim: syntax=sh ts=2 sw=2 sts=4 sr noet
  ```
- **Module headers**: Modules start with comment headers describing the module
  and each function. Follow the existing pattern using `# mod:`, `# api:`,
  `# txt:`, `# fun:` and `# opt:` annotations.
- **Function declarations**: Declare functions using the form:
  ```bash
  function name() {
    # body indented two spaces
  }
  ```
- Use `TRUE` (0) and `FALSE` (1) constants and store command results in the
  `RESULT` variable, unless an error is detected. In that case, don't use `RESULT`,
  and use `ERROR` to give details about the error.
- **Trailing newline**: Ensure every file ends with a newline character.

These guidelines apply to all code within the `src` directory and its
subdirectories.

## Testing
- Run `bash test/test-all.sh` before committing changes to ensure all tests pass.
