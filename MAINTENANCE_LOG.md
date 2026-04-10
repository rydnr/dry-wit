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
