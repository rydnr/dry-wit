---
name: bash-maintenance-orchestrator
description: Use when a Bash maintenance task needs coordinated testing, linting, and benchmarking instead of treating those loops as separate afterthoughts.
---

# bash-maintenance-orchestrator

## When to Use

Use this skill when the work spans more than one maintenance concern: correctness, coverage, lint hygiene, and performance.

Typical triggers:

- The user wants automated maintenance for a Bash framework or script suite.
- A change touches shared plumbing and needs regression tests plus lint plus performance checks.
- The task is broad enough that you need an execution order, not just one tool command.

## Instructions

1. Classify the task before editing:
   - Correctness or regression risk.
   - Coverage gap.
   - Lint debt.
   - Performance hotspot.
2. Set the execution order:
   - Reproduce behavior first.
   - Add or tighten tests second.
   - Fix implementation third.
   - Run `shellcheck` fourth.
   - Run `hyperfine` last when performance matters.
3. Keep the loop narrow until the change proves out.
   - Target touched files and nearby tests first.
   - Expand to the full suite before finishing.
4. Require evidence for each claim:
   - A test result for behavior.
   - A lint rerun for warning cleanup.
   - A benchmark comparison for performance claims.
5. End with a maintenance summary:
   - What behavior is now protected?
   - Which warnings were removed or intentionally left?
   - What performance changed, if anything?

Decision rules:

- If correctness and performance conflict, protect correctness first and measure again.
- If lint cleanup creates risk without tests, pause and add coverage before proceeding.
- If a hotspot is not user-visible or operationally meaningful, avoid clever micro-optimizations.

## Gotchas

- Do not run maintenance tools in a random order; that tends to bury the real regression source.
- Do not report “optimized” unless the benchmark loop actually improved.
- Do not close the task after a local narrow run if the repo has an established full-suite entrypoint.
- Tool output is not the same as judgment; prioritize the changes that materially improve the Bash maintenance loop.
