#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function run_plain_benchmark() {
  local -i _iterations="${1}"
  local -i _i

  export ENABLE_COLOR=${FALSE}
  export ENABLE_RIGHT_JUSTIFIED_LOGGING=${FALSE}

  for ((_i = 0; _i < _iterations; _i++)); do
    logInfo "Logging benchmark message"
  done
}

function run_color_benchmark() {
  local -i _iterations="${1}"
  local -i _i

  export ENABLE_COLOR=${TRUE}
  export ENABLE_RIGHT_JUSTIFIED_LOGGING=${FALSE}

  for ((_i = 0; _i < _iterations; _i++)); do
    logInfo "Logging benchmark message"
  done
}

function run_right_aligned_benchmark() {
  local -i _iterations="${1}"
  local -i _i

  export ENABLE_COLOR=${FALSE}
  export ENABLE_RIGHT_JUSTIFIED_LOGGING=${TRUE}
  export DW_TERM_WIDTH=120

  for ((_i = 0; _i < _iterations; _i++)); do
    logInfo -n "Logging benchmark message"
    logInfoResult SUCCESS "done"
  done
}

function main() {
  local _scenario="${DW_BENCH_SCENARIO:-${1}}"
  local -i _iterations="${DW_BENCH_ITERATIONS:-${2:-1000}}"

  setQuietMode ${FALSE}

  case "${_scenario}" in
    plain)
      run_plain_benchmark "${_iterations}"
      ;;
    color)
      run_color_benchmark "${_iterations}"
      ;;
    right-aligned)
      run_right_aligned_benchmark "${_iterations}"
      ;;
    *)
      echo "Unknown scenario: ${_scenario}" >&2
      return 1
      ;;
  esac

  if isTrue "${ENABLE_LOGGING_SPANS}"; then
    LOGGING.printSpanReport
  fi
}

setScriptDescription "Runs logging performance benchmark scenarios"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
