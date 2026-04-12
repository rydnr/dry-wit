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

## 2026-04-10 Logging Research Cycle

- Scope: Researched alternative logging approaches, replaced per-call `date` command substitution with Bash builtin time formatting, and prototyped timestamp/category-prefix caching in the current logger.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Execution time before the change:
  plain average `6.156909s`, color average `7.293668s`, right-aligned average `11.121831s`
- Execution time after the change:
  plain average `5.165392s`, color average `6.360054s`, right-aligned average `11.164379s`
- Research findings:
  Bash command substitution runs in a subshell, so `$(date ...)` in the hot path is more expensive than builtin formatting.
  Bash builtin `printf` supports `-v` and `%(datefmt)T`, which can replace external `date` for log timestamps.
  `tput` is terminfo-backed and portable, but it should stay out of hot logging loops.
  xterm-compatible terminals accept standard SGR color sequences directly, so an ANSI-fast optional backend is feasible.
- Research links:
  Bash command substitution: <https://www.gnu.org/software/bash/manual/bash.html?from=20421>
  Bash builtins including `printf -v` and `%(datefmt)T`: <https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html>
  `tput` and terminfo capabilities: <https://invisible-island.net/ncurses/man/tput.1.html>
  xterm SGR control sequences: <https://www.xfree86.org/current/ctlseqs.html>
- Notes:
  This cycle is recorded as research rather than a commit gate win because plain and color logging improved, but the long-run right-aligned scenario regressed slightly. The most promising next step is a user-selectable simple logger mode with a fixed prefix and without `FUNCNAME`-based category derivation.

## 2026-04-10 Logging Cycle 2

- Scope: Added user-selectable `standard`, `simple`, and `ansi-fast` logging backends while keeping the public logging API unchanged. Also kept the timestamp and category-prefix caches in the standard backend.
- Test command: `bash test/test-all.sh`
- Test result: `168/168` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Standard backend:
  plain average `5.165392s`, color average `6.360054s`, right-aligned average `11.164379s`
- Simple backend:
  plain average `4.616885s`, color average `4.664706s`, right-aligned average `12.386227s`
- ANSI-fast backend:
  plain average `4.620926s`, color average `4.754460s`, right-aligned average `12.412064s`
- Research links:
  Bash command substitution: <https://www.gnu.org/software/bash/manual/bash.html?from=20421>
  Bash builtins including `printf -v` and `%(datefmt)T`: <https://www.gnu.org/s/bash/manual/html_node/Bash-Builtins.html>
  `tput` and terminfo capabilities: <https://invisible-island.net/ncurses/man/tput.1.html>
  xterm SGR control sequences: <https://www.xfree86.org/current/ctlseqs.html>
- Notes:
  `simple` and `ansi-fast` are clear wins for plain and color logging because they skip namespace/category derivation and the standard token renderer. They are not wins for right-aligned logging, where spacing and completion handling still dominate. `ansi-fast` is slightly faster than the standard color path but not meaningfully faster than `simple`, so the main value of `ansi-fast` is colored compact output rather than extra speed over `simple`.

## 2026-04-10 Logging Cycle 3

- Scope: Added a safe fallback to the `standard` logging backend when `LOGGING_BACKEND` is empty or unsupported, and replaced `evalVar()` shelling-out with Bash-native indirect expansion plus variable-name validation.
- Test command: `bash test/test-all.sh`
- Test result: `172/172` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Standard backend before the change:
  plain average `5.165392s`, color average `6.360054s`, right-aligned average `11.164379s`
- Standard backend after the change:
  plain average `5.118526s`, color average `6.336259s`, right-aligned average `11.126722s`
- Notes:
  This cycle focuses on correctness and hot-path cleanup rather than a backend redesign. Unsupported `LOGGING_BACKEND` values now resolve deterministically to `standard`, so users always get a known implementation. The environment-variable lookup path no longer forks `sh` for indirect resolution, which removes avoidable process overhead from backend selection and any other `evalVar()` callers. The gains are modest but consistently non-regressive across all three standard logging scenarios.

## 2026-04-11 Logging Cycle 4

- Scope: Focused on the right-aligned completion path by removing string concatenation from outcome-length calculation, deleting no-op token/color loops, and replacing separator construction in `LOGGING.alignRight()` with a single `printf`-based path.
- Test command: `bash test/test-all.sh`
- Test result: `172/172` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Standard backend before the change:
  plain average `5.118526s`, color average `6.336259s`, right-aligned average `11.126722s`
- Standard backend after the change:
  plain average `5.300272s`, color average `6.397214s`, right-aligned average `10.379365s`
- Notes:
  This cycle intentionally targeted the right-aligned path rather than overall logger throughput. The completion path improved materially by about `0.747357s` over the previous standard-backend baseline. Plain and color runs measured slightly slower in this sample set, so future cycles should treat this as a specialization win for right-aligned logging, not a general logging improvement.

## 2026-04-11 Logging Cycle 5

- Scope: Added `LOGGING_RIGHT_ALIGNMENT_MODE` with `auto`, `padding`, and `cursor`, and implemented a TTY-only cursor-positioning path for right-aligned outcomes. Also updated the logging benchmark to report standard deviation so small movements can be evaluated against run-to-run noise.
- Test command: `bash test/test-all.sh`
- Test result: `174/174` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Standard backend after the change:
  plain average `5.261735s`, stddev `0.027659s`, color average `6.450360s`, stddev `0.053595s`, right-aligned average `10.399780s`, stddev `0.025009s`
- Console probe:
  `LOGGING_RIGHT_ALIGNMENT_MODE=cursor` on a TTY rendered the outcome with cursor positioning instead of padding and preserved the visible layout.
- Notes:
  The benchmark still redirects output to a file, so it continues to measure the padding path rather than the new cursor path. That means it now tells us two different things: the variance for the existing file-safe benchmark path, and the availability of a faster console-specific alignment mode when stdout is an interactive terminal. The plain and color shifts are within a few standard deviations and should not be interpreted as meaningful on their own.

## 2026-04-11 Logging Cycle 6

- Scope: Added `ENABLE_LOGGING_HOT_PATH_CHECKS` so the repeated runtime validations in hot logging paths can be suppressed without removing the checks from the source code.
- Test command: `bash test/test-all.sh`
- Test result: `176/176` passed, `0` failed
- Benchmark target: repeated logging to a captured output file for three scenarios: plain `logInfo`, color-enabled `logInfo`, and right-aligned `logInfo -n` + `logInfoResult`
- Benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- Checks enabled:
  plain average `6.422429s`, stddev `0.086244s`, color average `7.826778s`, stddev `0.053458s`, right-aligned average `13.343820s`, stddev `0.040899s`
- Checks disabled:
  plain average `6.416510s`, stddev `0.094627s`, color average `7.802931s`, stddev `0.008118s`, right-aligned average `13.317580s`, stddev `0.029331s`
- Notes:
  Suppressing hot-path checks is a real but modest lever in the current implementation. It improves all three measured scenarios, but only slightly. This is useful as an optional fast mode, not as a complete answer to logging performance by itself.

## 2026-04-11 Logging Cycle 7

- Scope: Added a PTY-based terminal benchmark to evaluate `bashsimplecurses` as an optional console-rendering backend candidate instead of reasoning from file-redirection benchmarks.
- Test command: `bash test/test-all.sh`
- Test result: `176/176` passed, `0` failed
- Benchmark target: repeated terminal rendering inside a real PTY for current `dry-wit` logging and for a minimal `bashsimplecurses` window that displays one left-aligned message.
- Benchmark harness:
  `bash test/terminal-logging-benchmark.sh 3 20`
- Results:
  `dry-wit-plain` average `10.613666s`, stddev `0.057547s`; `dry-wit-right-aligned` average `24.469097s`, stddev `0.067114s`; `bashsimplecurses-scroll` average `1.008100s`, stddev `0.014107s`; `bashsimplecurses-dashboard` average `1.035450s`, stddev `0.011838s`
- Notes:
  This does not prove `bashsimplecurses` is a drop-in logging replacement. The evaluated `bashsimplecurses` case is a minimal window redraw, not a full reproduction of `dry-wit` timestamp/category/outcome formatting. But it does prove the important first point: a curses-style optional dependency does not inherently degrade console throughput here. Source inspection also explains why it is better treated as a rendering helper than a logging library: it manages a screen buffer, uses `tput` for cursor/state control, and is designed around repeated window redraws. So the next useful step is not to replace `logInfo()` wholesale, but to prototype a narrow optional backend for the specific console-heavy paths that benefit from alternate rendering.

## 2026-04-11 Logging Cycle 8

- Scope: Cached the visible prefix length and current open-line length so right-aligned outcome rendering can reuse already-emitted line state instead of rebuilding prefix/category state on completion.
- Test command: `bash test/test-all.sh`
- Test result: `178/178` passed, `0` failed
- File benchmark harness:
  `bash test/logging-benchmark.sh 5 10`
- File benchmark result:
  plain average `6.750529s`, stddev `0.081615s`, color average `8.172138s`, stddev `0.012825s`, right-aligned average `10.368310s`, stddev `0.159414s`
- PTY benchmark harness:
  `bash test/terminal-logging-benchmark.sh 3 20`
- PTY benchmark result:
  `dry-wit-plain` average `11.225932s`, stddev `0.120831s`; `dry-wit-right-aligned` average `19.632802s`, stddev `0.016581s`; `bashsimplecurses-scroll` average `1.012715s`, stddev `0.002405s`; `bashsimplecurses-dashboard` average `1.035450s`, stddev `0.010669s`
- Notes:
  The meaningful win here is the PTY right-aligned case: the previous PTY probe in Cycle 7 measured `dry-wit-right-aligned` at `24.469097s`, so this cache-based change cuts that to `19.632802s` while preserving the existing API and keeping the old reconstruction path as fallback. Plain and color still move around enough that they should not be over-interpreted from a single cycle. This is a better fit than trying to force `bashsimplecurses` into the logging API, because it removes avoidable work inside the current design rather than introducing a dashboard library where a line renderer is needed.

## 2026-04-11 Logging Cycle 9

- Scope: Prototyped an optional drop-in native logging backend selected with `LOGGING_BACKEND=native-c`, added helper auto-discovery with fallback to `standard`, packaged the helper build in `nix/flake.nix`, and added availability/fallback coverage in `test/logging-tests.sh`.
- Test command: `bash test/test-all.sh`
- Test result: `180/180` passed, `0` failed
- File benchmark harness:
  `DW_NATIVE_LOGGER_BIN=/tmp/dry-wit-native-logger LOGGING_BACKEND=<backend> bash test/logging-benchmark.sh 5 10`
- File benchmark result:
  `standard` plain average `6.822419s`, stddev `0.124191s`, color average `7.894678s`, stddev `0.036420s`, right-aligned average `9.989359s`, stddev `0.211094s`; `native-c` plain average `6.308193s`, stddev `0.095679s`, color average `6.241957s`, stddev `0.041911s`, right-aligned average `9.288115s`, stddev `0.072938s`
- PTY benchmark harness:
  `DW_NATIVE_LOGGER_BIN=/tmp/dry-wit-native-logger LOGGING_BACKEND=<backend> bash test/terminal-logging-benchmark.sh 3 20`
- PTY benchmark result:
  `standard` `dry-wit-plain` average `11.479710s`, stddev `0.077332s`; `dry-wit-right-aligned` average `19.556455s`, stddev `0.036974s`; `native-c` `dry-wit-plain` average `10.608589s`, stddev `0.034454s`; `dry-wit-right-aligned` average `17.018550s`, stddev `0.035341s`
- Notes:
  This is the first optional dependency path that clearly outperforms the current Bash renderer while preserving the existing shell API. The improvement is meaningful in both file-capture and PTY measurements, especially for color and right-aligned output. The architectural caveat still holds: this backend spawns one helper process per log call, so it is not the ceiling for native performance. A persistent helper or linked extension would be the next lever if more throughput is needed.

## 2026-04-12 Logging Cycle 10

- Scope: Added a persistent daemon transport for the `native-c` backend using a Bash coprocess plus a daemon mode in `dry-wit-native-logger`, while keeping `spawn` available through `DW_NATIVE_LOGGER_TRANSPORT=spawn`. The default `auto` transport now prefers the daemon path.
- Test command: `bash test/test-all.sh`
- Test result: `182/182` passed, `0` failed
- File benchmark harness:
  `DW_NATIVE_LOGGER_BIN=/tmp/dry-wit-native-logger LOGGING_BACKEND=native-c DW_NATIVE_LOGGER_TRANSPORT=<transport> bash test/logging-benchmark.sh 5 10`
- File benchmark result:
  `spawn` plain average `6.522489s`, stddev `0.039949s`, color average `6.610332s`, stddev `0.024698s`, right-aligned average `9.751608s`, stddev `0.037490s`; `daemon` plain average `6.511833s`, stddev `0.018294s`, color average `6.558424s`, stddev `0.058312s`, right-aligned average `9.718647s`, stddev `0.031176s`
- PTY benchmark harness:
  `DW_NATIVE_LOGGER_BIN=/tmp/dry-wit-native-logger LOGGING_BACKEND=native-c DW_NATIVE_LOGGER_TRANSPORT=<transport> bash test/terminal-logging-benchmark.sh 3 20`
- PTY benchmark result:
  `spawn` `dry-wit-plain` average `10.056994s`, stddev `0.037590s`; `dry-wit-right-aligned` average `16.059921s`, stddev `0.052751s`; `daemon` `dry-wit-plain` average `10.044515s`, stddev `0.029569s`; `dry-wit-right-aligned` average `16.130426s`, stddev `0.004506s`
- Notes:
  The daemon transport works and slightly improves the file-capture benchmark, which confirms that repeated helper spawns were part of the overhead. But the PTY results are effectively flat and even slightly worse for right-aligned output in this sample set. The practical conclusion is that the process boundary is no longer the main bottleneck once rendering is native. The next significant wins will likely come from reducing terminal writes, alignment work, or protocol overhead rather than from transport changes alone.

## 2026-04-12 Logging Cycle 11

- Scope: Added opt-in logging profiling spans under `ENABLE_LOGGING_SPANS`, with aggregated totals and counts plus `LOGGING.printSpanReport`, so the hot logging stages can be ranked directly instead of inferred from whole-benchmark timings.
- Test command: `bash test/test-all.sh`
- Test result: `184/184` passed, `0` failed
- Span runs:
  `ENABLE_LOGGING_SPANS=0 DW_LOGGING_SPANS_FILE=<file> LOGGING_BACKEND=native-c DW_NATIVE_LOGGER_TRANSPORT=spawn test/logging-benchmark-target.sh`
- Plain scenario report, `20` iterations:
  `native.message` total `3031406us`, avg `151570us`; `retrieveLogTimestamp` total `582563us`, avg `29128us`; `logToFiles` total `517619us`, avg `25880us`
- Right-aligned scenario report, `20` iterations:
  `echoSimpleLogOutcome` total `4610528us`, avg `230526us`; `native.message` total `3012404us`, avg `150620us`; `native.outcome` total `2242473us`, avg `112123us`; `logToFiles` total `1018012us`, avg `25450us`; `retrieveActiveLogLineLength` total `672946us`, avg `33647us`; `retrieveLogTimestamp` total `555369us`, avg `27768us`
- Notes:
  The dominant plain-logging span is the native message path itself. For right-aligned logging, the main bottleneck is the outcome phase, not prefix/timestamp work. That means the next meaningful optimization pass should focus first on the right-aligned outcome renderer and second on reducing the native message/outcome protocol cost. The span instrumentation is behind an opt-in flag because it is materially slower than the normal path.
