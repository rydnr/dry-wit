#!/usr/bin/env bash

if [ -z "${DW_BSC_LIB}" ] || [ ! -f "${DW_BSC_LIB}" ]; then
  echo "Missing bashsimplecurses library: ${DW_BSC_LIB}" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${DW_BSC_LIB}"

declare -gi DW_BSC_ITERATION=0
declare -gi DW_BSC_TARGET_ITERATIONS="${DW_BENCH_ITERATIONS:-100}"
declare -g DW_BSC_MODE="${DW_BSC_MODE:-scroll}"

function main() {
  window "dry-wit logging benchmark" "blue" "100%"
    append "Logging benchmark message" left
  endwin
}

function update() {
  DW_BSC_ITERATION=$((DW_BSC_ITERATION + 1))

  if [ "${DW_BSC_ITERATION}" -ge "${DW_BSC_TARGET_ITERATIONS}" ]; then
    clean_env
    exit 0
  fi
}

case "${DW_BSC_MODE}" in
  scroll)
    main_loop -q -s -t 0
    ;;
  dashboard)
    main_loop -q -t 0
    ;;
  *)
    echo "Unknown bashsimplecurses mode: ${DW_BSC_MODE}" >&2
    exit 1
    ;;
esac
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
