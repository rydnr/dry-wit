#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BENCH_HOME="$(mktemp -d /tmp/dry-wit-logging-bench.XXXXXX)"
OUTPUT_DIR="${BENCH_HOME}/output"
trap 'rm -rf "${BENCH_HOME}"' EXIT

SAMPLES="${1:-10}"
ITERATIONS="${2:-1000}"

mkdir -p "${BENCH_HOME}/.dry-wit/src/modules"
mkdir -p "${BENCH_HOME}/.dry-wit/src/modules/ext"
mkdir -p "${OUTPUT_DIR}"
cp "${REPO_DIR}"/src/modules/*.dw "${BENCH_HOME}/.dry-wit/src/modules/" 2>/dev/null
cp "${REPO_DIR}"/src/modules/ext/*.dw "${BENCH_HOME}/.dry-wit/src/modules/ext/" 2>/dev/null
cp "${REPO_DIR}"/src/dry-wit* "${BENCH_HOME}/.dry-wit/src/" 2>/dev/null

function format_ns() {
  local -i _ns="${1}"
  local -i _seconds=$((_ns / 1000000000))
  local -i _micros=$(((_ns % 1000000000) / 1000))

  printf "%d.%06d" "${_seconds}" "${_micros}"
}

function format_us() {
  local -i _ns="${1}"
  local -i _micros=$((_ns / 1000))
  local -i _nanos=$((_ns % 1000))

  printf "%d.%03d" "${_micros}" "${_nanos}"
}

function benchmark_scenario() {
  local _scenario="${1}"
  local -i _sum=0
  local -i _min=0
  local -i _max=0
  local -i _sample
  local _samplesFile="${OUTPUT_DIR}/${_scenario}.samples"
  : > "${_samplesFile}"

  for ((_sample = 1; _sample <= SAMPLES; _sample++)); do
    local _outputFile="${OUTPUT_DIR}/${_scenario}.${_sample}.log"
    local -i _startedAt
    local -i _finishedAt
    local -i _elapsed

    _startedAt=$(date +%s%N)
    HOME="${BENCH_HOME}" \
      PATH="${REPO_DIR}/src:${PATH}" \
      TERM="xterm-256color" \
      DW_BENCH_SCENARIO="${_scenario}" \
      DW_BENCH_ITERATIONS="${ITERATIONS}" \
      "${SCRIPT_DIR}/logging-benchmark-target.sh" \
      >"${_outputFile}" 2>&1
    local -i _rescode=$?
    _finishedAt=$(date +%s%N)

    if [ ${_rescode} -ne 0 ]; then
      echo "Benchmark failed for ${_scenario} in sample ${_sample}" >&2
      return ${_rescode}
    fi

    _elapsed=$((_finishedAt - _startedAt))
    _sum=$((_sum + _elapsed))
    echo "${_elapsed}" >> "${_samplesFile}"

    if [ ${_sample} -eq 1 ] || [ ${_elapsed} -lt ${_min} ]; then
      _min=${_elapsed}
    fi

    if [ ${_sample} -eq 1 ] || [ ${_elapsed} -gt ${_max} ]; then
      _max=${_elapsed}
    fi
  done

  local -i _avg=$((_sum / SAMPLES))
  local -i _avgPerIteration=$((_avg / ITERATIONS))
  local -i _stddev=0
  local -i _stddevPerIteration=0

  _stddev=$(awk '
    {
      values[NR] = $1
      sum += $1
    }
    END {
      if (NR < 2) {
        printf "%.0f", 0
        exit
      }
      mean = sum / NR
      for (i = 1; i <= NR; i++) {
        delta = values[i] - mean
        sq += delta * delta
      }
      printf "%.0f", sqrt(sq / NR)
    }
  ' "${_samplesFile}")
  _stddevPerIteration=$((_stddev / ITERATIONS))

  echo "scenario=${_scenario} samples=${SAMPLES} iterations=${ITERATIONS} avg=$(format_ns "${_avg}")s stddev=$(format_ns "${_stddev}")s min=$(format_ns "${_min}")s max=$(format_ns "${_max}")s avg_per_iteration=$(format_us "${_avgPerIteration}")us stddev_per_iteration=$(format_us "${_stddevPerIteration}")us"
}

benchmark_scenario message-only
benchmark_scenario color
benchmark_scenario right-aligned
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
