# AGENTS Instructions for dry-wit repository

This repository primarily contains Bash code under the `src` directory. The
files follow a consistent format which should be respected when modifying or
adding new scripts.

## Coding style

- **Indentation**: Use two spaces for each indentation level. No hard tabs.
  This matches `.editorconfig` which defines `indent_style = space` and
  `indent_size = 2` for `*.{dw,sh}` files.
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
- **Trailing newline**: Ensure every file ends with a newline character.

These guidelines apply to all code within the `src` directory and its
subdirectories.
