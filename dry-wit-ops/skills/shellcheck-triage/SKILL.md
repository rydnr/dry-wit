---
name: shellcheck-triage
description: Use when Bash maintenance work should be driven by ShellCheck findings, especially when warnings need prioritization and safe fixes.
---

# shellcheck-triage

## When to Use

Use this skill when a Bash codebase needs lint-guided cleanup or when a task mentions `shellcheck`, quoting bugs, subshell issues, portability concerns, or warning backlogs.

Typical triggers:

- The user asks to fix or reduce ShellCheck warnings.
- A Bash refactor should avoid introducing common shell hazards.
- A failing script hints at quoting, globbing, exit-code, or word-splitting mistakes.

## Instructions

1. Run `shellcheck` against the narrowest affected files first.
2. Group findings by risk before editing:
   - Behavioral correctness issues first.
   - Error-handling and quoting issues second.
   - Style-only cleanup last.
3. Fix warnings in small batches with one rationale per batch.
   - Explain why the warning is valid in this codebase.
   - Avoid mass edits that change control flow without test coverage.
4. After each batch, re-run the relevant tests or script entrypoint.
5. Only suppress a warning when the code intentionally violates the default heuristic and that intent is stable.
6. When suppressing, keep the scope tight and document the reason in the source if the code would otherwise look wrong.

Priority examples:

- Treat quoting, unbound expansions, masked exit codes, and brittle pipelines as behavior bugs.
- Treat duplicated `[` style, cosmetic braces, or optional idioms as lower priority unless the repo has a strict policy.
- If a warning touches command substitution or array handling, verify runtime behavior instead of assuming the linter alone proves the fix.

## Gotchas

- Do not “fix” ShellCheck by changing semantics the tests relied on.
- Do not blanket-disable warnings at file scope when one line-local suppression is enough.
- Some warnings reflect repo conventions rather than bugs; check existing style before normalizing everything.
- Bash lint cleanup without a follow-up test run is incomplete for any warning tied to expansions, conditionals, pipelines, or traps.
