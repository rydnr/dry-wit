# MAINTENANCE_LOG

This log records the baseline metrics used to decide whether a maintenance cycle improved the repository enough to justify a commit.

## 2026-04-09 Baseline

- Scope: Initial baseline after stabilizing the test harness and making the full suite green.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: minimal dry-wit startup for a no-op script
- Benchmark harness:
  `TIMEFORMAT=%R; for i in $(seq 1 20); do { time env PATH="/home/chous/github/rydnr/dry-wit/src:$PATH" /tmp/drywit-noop.eboqyx.sh >/dev/null; } 2>>/tmp/drywit-after.times; done`
- Execution time:
  average `1.630800s`, minimum `1.598000s`, maximum `1.668000s`
- Notes:
  This is the first log entry. Future maintenance cycles should only commit when their benchmark result is lower than this entry's recorded average and the full test suite remains green.

## 2026-04-10 Baseline

- Scope: Refreshed baseline before starting a new maintenance cycle.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: minimal dry-wit startup for a no-op script
- Benchmark harness:
  `TIMEFORMAT=%R; for i in $(seq 1 20); do { time env PATH="/home/chous/github/rydnr/dry-wit/src:$PATH" /tmp/drywit-noop.eboqyx.sh >/dev/null; } 2>>/tmp/drywit-log-baseline.times; done`
- Execution time:
  average `1.620850s`, minimum `1.588000s`, maximum `1.680000s`
- Notes:
  Future maintenance cycles should only commit when their benchmark result is lower than this entry's recorded average and the full test suite remains green.

## 2026-04-10 Baseline 2

- Scope: Refreshed baseline after committing the Bash case-conversion optimization.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: minimal dry-wit startup for a no-op script
- Benchmark harness:
  `TIMEFORMAT=%R; for i in $(seq 1 20); do { time env PATH="/home/chous/github/rydnr/dry-wit/src:$PATH" /tmp/drywit-noop.eboqyx.sh >/dev/null; } 2>>/tmp/drywit-log-current.times; done`
- Execution time:
  average `1.549400s`, minimum `1.504000s`, maximum `1.583000s`
- Notes:
  Future maintenance cycles should only commit when their benchmark result is lower than this entry's recorded average and the full test suite remains green.

## 2026-04-10 Cycle 3

- Scope: Simplified module loading by removing an unused script-path lookup and invalid `BASH_SOURCE[0]`-based module probes from `findModule()`.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: minimal dry-wit startup for a no-op script
- Benchmark harness:
  `TIMEFORMAT=%R; for i in $(seq 1 20); do { time env PATH="/home/chous/github/rydnr/dry-wit/src:$PATH" /tmp/drywit-noop.eboqyx.sh >/dev/null; } 2>>/tmp/drywit-cycle-module-after.times; done`
- Execution time:
  average `1.396350s`, minimum `1.361000s`, maximum `1.421000s`
- Notes:
  This cycle improved the previous logged gate of `1.549400s` while keeping the full suite green.

## 2026-04-10 Logging Cycle 1

- Scope: Added a repeatable logging benchmark harness and removed a redundant `LOGGING.buildLogPrefix` call from `LOGGING.logInProgressNoNested()`.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Execution time before the change:
  plain average `8.198988s`, color average `9.335230s`, right-aligned average `13.226121s`
- Execution time after the change:
  plain average `6.156909s`, color average `7.293668s`, right-aligned average `11.121831s`
- Notes:
  This establishes the first committed logging benchmark for future logging-focused maintenance cycles. The harness lives in `test/logging-benchmark.sh` and `test/logging-benchmark-target.sh`.
