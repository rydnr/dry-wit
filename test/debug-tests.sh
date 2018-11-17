#!/bin/bash ../src/dry-wit-test
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

import debug;

function test_reset() {
  DEBUG.resetState;
  DEBUG.defaultState;
}

## Called before each test.
function test_setup() {
  test_reset;
}

## Called after each test.
function test_tearDown() {
  test_reset;
  DEBUG.getDebugLogFile;
  rm -f "${RESULT}" > /dev/null 2>&1;
}

function debugAssociativeArray_prints_each_entry_in_the_debug_file_test() {
  local _debugFile="${TEMP:-/tmp}/.$$.${SCRIPT_NAME}.log";
  setDebugLogFile "${_debugFile}";
  debugAssociativeArray __DW_ASSOCIATIVE_ARRAY_FOR_TESTING;
  Assert.isNotEmpty "${_debugFile}" "debugFile is not set";
  Assert.fileContains "${_debugFile}" "foo11 -> bar11" "debugAssociativeArray didn't write 'foo11 -> bar11' in the log file";
  Assert.fileContains "${_debugFile}" "foo214 -> bar214" "debugAssociativeArray didn't write 'foo214 -> bar214' in the log file";
  Assert.fileContains "${_debugFile}" "key-without-spaces -> value with spaces" "debugAssociativeArray didn't write 'key-without-spaces -> value with spaces' in the log file";
  Assert.fileContains "${_debugFile}" "key with spaces -> value with spaces" "debugAssociativeArray didn't write 'key with spaces -> value with spaces' in the log file";
}

declare -Ag __DW_ASSOCIATIVE_ARRAY_FOR_TESTING=( [foo11]=bar11 [foo214]=bar214 [key-without-spaces]="value with spaces" [key with spaces]="value with spaces");
#
