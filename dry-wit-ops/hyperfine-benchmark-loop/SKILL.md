---
name: hyperfine-benchmark-loop
description: Use when Bash performance work should be measured with repeatable hyperfine benchmarks instead of intuition or one-off timing.
---

# hyperfine-benchmark-loop

## When to Use

Use this skill when the task is about Bash runtime cost, startup latency, command throughput, or validating that a maintenance change did not regress performance.

Typical triggers:

- The user mentions `hyperfine`, benchmarking, slowness, startup time, or regressions.
- A script contains loops, subprocess churn, repeated filesystem scans, or expensive pipelines.
- Two implementations need an evidence-based comparison.

## Instructions

1. Define the exact command under test before benchmarking.
   - Use the smallest reproducible command that exercises the hot path.
   - Freeze obvious inputs, environment variables, and fixture paths.
2. Measure a baseline first with `hyperfine`.
   - Warm caches if the workflow depends on them, or explicitly measure cold runs separately.
   - Record command shape, setup assumptions, and sample size.
3. Change one meaningful variable at a time.
   - Avoid mixing refactors with benchmark work.
   - Keep test coverage green between benchmark revisions.
4. Compare baseline and candidate using the same benchmark harness.
5. Report whether the difference is large enough to matter operationally.
   - Prefer relative change and absolute impact together.
   - Call out variance if results overlap heavily.
6. Before finishing, confirm the faster path still preserves behavior with the repo’s tests.

Optimization heuristics for Bash:

- Reduce subshells, external processes, and repeated parsing in hot loops.
- Cache stable command output instead of recomputing it.
- Prefer shell builtins when behavior stays correct and readable.
- Measure after each change; shell performance guesses are often wrong.

## Gotchas

- One `time` sample is not a benchmark.
- Benchmarking the wrong command wrapper can hide the real hotspot.
- If setup dominates runtime, benchmark setup separately from the core operation.
- Performance wins that break quoting, error handling, or portability are not acceptable for maintenance work.
