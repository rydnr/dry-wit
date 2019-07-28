#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import debug;

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

function defineEnvVar_adds_an_env_var_to___DW_ENVVAR_ENV_VARIABLES_test() {
  defineEnvVar "MY_VAR" MANDATORY "My env var" "foo" "date";
  Assert.isNotEmpty "${__DW_ENVVAR_ENV_VARIABLES[*]}" "__DW_ENVVAR_ENV_VARIABLES is empty";
  Assert.arrayContains "${__DW_ENVVAR_ENV_VARIABLES[@]}" "MY_VAR" "__DW_ENVVAR_ENV_VARIABLES does not contain MY_VAR";
}

function ___DW_ENVVAR_ENV_VARIABLES_does_not_include_empty_vars_test() {
  local i;
  defineEnvVar "MY_VAR" MANDATORY "My env var" "foo" "date";
  Assert.isNotEmpty "${__DW_ENVVAR_ENV_VARIABLES[*]}" "__DW_ENVVAR_ENV_VARIABLES is empty";
  for ((i = 0; i < ${#__DW_ENVVAR_ENV_VARIABLES[*]}; i++)); do
    Assert.isNotEmpty "${__DW_ENVVAR_ENV_VARIABLES[$i]}" "Variable at position $i is empty";
  done
}

function extractKeyInPair_test() {
  local pair="name1=value1"
  if extractKeyInPair "${pair}"; then
    Assert.areEqual "name1" "${RESULT}" "extractKeyInPair ${pair} failed";
  else
    Assert.fail "extractKeyInPair ${pair} failed";
  fi
}

function extractValueInPair_test() {
  local pair="name1=value1"
  if extractValueInPair "${pair}"; then
    Assert.areEqual "value1" "${RESULT}" "extractValueInPair ${pair} failed";
  else
    Assert.fail "extractValueInPair ${pair} failed";
  fi

  pair="name1=\"value with spaces\"";
  if extractValueInPair "${pair}"; then
      Assert.areEqual "value with spaces" "${RESULT}" "extractValueInPair ${pair} failed";
  else
      Assert.fail "extractValueInPair ${pair} failed";
  fi
}

declare -Ag __DW_ASSOCIATIVE_ARRAY_FOR_TESTING=( [foo11]=bar11 [foo214]=bar214 [key-without-spaces]="value with spaces" [key with spaces]="value with spaces");

setScriptDescription "Runs all tests implemented for envvar.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
