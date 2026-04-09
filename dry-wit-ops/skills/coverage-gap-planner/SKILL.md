---
name: coverage-gap-planner
description: Use when Bash maintenance work needs a deliberate plan for which untested behaviors to cover next, especially after failures or shared-module edits.
---

# coverage-gap-planner

## When to Use

Use this skill when the user wants stronger test coverage, when touched Bash modules lack direct tests, or when recent failures expose missing edge cases.

Typical triggers:

- A shared Bash helper changed and only indirect tests exist.
- The repo has recurring regressions in argument parsing, file handling, env vars, or exit-code behavior.
- The task is to improve confidence without writing a broad, expensive test matrix.

## Instructions

1. Start from behavior, not lines.
   - Identify what the script or function promises to do.
   - List the inputs, outputs, side effects, and failure modes that matter.
2. Rank gaps by maintenance value:
   - Recently broken behavior.
   - Touched code paths.
   - Shared helpers with many dependents.
   - Edge cases around empty input, quoting, paths, env vars, and exit status.
3. Propose a small next batch of tests.
   - Prefer 2 to 5 high-yield cases over blanket expansion.
   - Keep each case tied to one observable contract.
4. Add direct tests where the bug or risk lives.
   - Avoid relying only on far-away integration coverage when a helper is critical.
5. After tests are added, note what remains intentionally uncovered and why.

Coverage heuristics for Bash:

- Empty strings, spaces in paths, missing files, and command failures are high-yield cases.
- If a function exports globals, assert both the return code and the resulting variable state.
- Favor tests around traps, temp files, and environment mutation because those regress easily.

## Gotchas

- Chasing percentage targets can produce noisy low-value tests.
- Untested shared helpers create more maintenance risk than lightly used leaf scripts.
- Do not add broad integration tests when one focused unit-level Bash test would make the contract clearer.
- Coverage planning is incomplete if it ignores failure paths and only covers happy cases.
