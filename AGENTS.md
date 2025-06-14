# Contribution Guidelines

## Code Style
- All scripts in `src/` are Bash scripts.
- Functions must be declared using `function name() {` syntax.
- Indent using **two spaces** only, never tabs. `.editorconfig` enforces this.
- Each `.dw` module begins with metadata comments:
  - `# mod: <module>`
  - `# api: public|private`
  - `# txt: <description>`
- Document functions with comment blocks before the definition using the same
  style (`# fun:`, `# api:`, `# txt:`, `# opt:` and `# use:` lines).
- End every `.dw` and `.sh` file with `# vim: syntax=sh ts=2 sw=2 sts=4 sr noet`.
- Use `TRUE` (0) and `FALSE` (1) constants and store command results in the
  `RESULT` variable.

## Testing
- Run `bash test/test-all.sh` before committing changes to ensure all tests pass.

