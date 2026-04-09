---
name: bash-bats-loop
description: Use when maintaining Bash code and the next move should be a fast Bats regression loop that narrows failures before editing more code.
---

# bash-bats-loop

## When to Use

Use this skill when the task is about Bash regressions, missing tests, flaky test behavior, or confidence after script changes.

Typical triggers:

- The repo already uses `bats` or `bats-core`.
- A Bash module, function, or CLI entrypoint changed and tests need to be updated or expanded.
- The user asks for tighter regression protection or a faster fix-then-test loop.
- You need to isolate a failing case before changing more code.

## Instructions

1. Find the closest existing test entrypoint first.
   - Prefer repo-native commands such as `bash test/test-all.sh`, `make test`, or a documented Bats wrapper.
   - If the repo uses direct `bats` invocation, list likely target files before running broad suites.
2. Reproduce the current state with the smallest useful scope.
   - Start with the nearest file or suite.
   - Expand to the full test command only after the local failure is understood.
3. When a failure is present, reduce it to one behavioral statement.
   - What input, setup, or environment causes the failure?
   - What exact output, exit code, or side effect is wrong?
4. Add or tighten tests before broad refactors.
   - Prefer one focused regression test for the concrete bug.
   - Add neighboring edge cases only when they are clearly coupled.
5. Re-run the smallest relevant test scope after each edit.
6. Before finishing, run the repo’s broader Bash test entrypoint to confirm the local fix did not break adjacent behavior.
7. Summarize the final confidence level in terms of covered behaviors, not just “tests pass.”

Testing heuristics:

- Prefer deterministic assertions over snapshot-like text dumps.
- Assert exit status and stderr/stdout separately when shell behavior matters.
- Keep fixtures minimal; Bash tests become fragile when setup is too implicit.
- If the code uses env vars, temp files, or traps, reset them explicitly inside the test.

## Gotchas

- Do not start by widening the test matrix. First make one failure legible.
- Do not trust a passing broad suite if the specific regression still lacks a direct test.
- Bash tests often fail because of environment leakage, current directory assumptions, or temp-file reuse; check those before assuming the implementation is wrong.
- If the repo has a wrapper like `test/test-all.sh`, use it before declaring the work finished because it may stage files or environment expected by the suite.
