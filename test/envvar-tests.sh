#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import debug;

function test_reset() {
  DEBUG.resetState;
  DEBUG.defaultState;
  setDebugEchoEnabled TRUE;
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
  DEBUG.getDebugLogFile;
  local _debugFile="${RESULT}";
  Assert.isNotEmpty "${_debugFile}" "debugFile is not set";
  debugAssociativeArray __DW_ASSOCIATIVE_ARRAY_FOR_TESTING;
  Assert.fileContains "${_debugFile}" "foo11 -> bar11" "debugAssociativeArray didn't write 'foo11 -> bar11' in the log file";
  Assert.fileContains "${_debugFile}" "foo214 -> bar214" "debugAssociativeArray didn't write 'foo214 -> bar214' in the log file";
  Assert.fileContains "${_debugFile}" "key-without-spaces -> value with spaces" "debugAssociativeArray didn't write 'key-without-spaces -> value with spaces' in the log file";
  Assert.fileContains "${_debugFile}" "key with spaces -> value with spaces" "debugAssociativeArray didn't write 'key with spaces -> value with spaces' in the log file";
}

function defineEnvVar_adds_an_environment_variable_test() {
  defineEnvVar "MY_VAR" MANDATORY "My env var" "foo" "date";
  ENVVAR.getEnvironmentVariablesVariableName;
  local _variableName=${RESULT};
  local -n _envVariables=${_variableName};
  Assert.isNotEmpty "${_envVariables[@]}" "Environment variables array is empty";
  # The next line is critical!
  local _array="${_envVariables[@]}";
  Assert.arrayContains "MY_VAR" "${_array}" 'Environment variables array does not contain MY_VAR.';
}

function empty_vars_are_not_included_as_environment_variables_test() {
  local -i i;
  defineEnvVar "MY_VAR" MANDATORY "My env var" "foo" "date";
  ENVVAR.getEnvironmentVariablesVariableName;
  local -n _envVariables=${RESULT};
  Assert.isNotEmpty "${_envVariables[@]}" "Environment variables arary is empty";
  for ((i = 0; i < ${#_envVariables[@]}; i++)); do
    Assert.isNotEmpty "${_envVariables[$i]}" "Variable at position $i is empty";
  done
}

function extractKeyInPair_works_test() {
  local _pair="name1=value1"
  local _expected="name1";
  if extractKeyInPair "${_pair}"; then
    Assert.areEqual "${_expected}" "${RESULT}" "extractKeyInPair ${_pair} failed";
  else
    Assert.fail "extractKeyInPair ${_pair} failed";
  fi

  _pair="name99=value1x"
  _expected="name99";
  if extractKeyInPair "${_pair}"; then
    Assert.areEqual "${_expected}" "${RESULT}" "extractKeyInPair ${_pair} failed";
  else
    Assert.fail "extractKeyInPair ${_pair} failed";
  fi
}

function extractValueInPair_works_test() {
  local _pair="name1=value1"
  local _expected="value1";
  if extractValueInPair "${_pair}"; then
    Assert.areEqual "${_expected}" "${RESULT}" "extractValueInPair ${_pair} failed";
  else
    Assert.fail "extractValueInPair ${_pair} failed";
  fi

  _pair='name1="value with spaces"';
  _expected="value with spaces";
  if extractValueInPair "${_pair}"; then
    Assert.areEqual "${_expected}" "${RESULT}" "extractValueInPair ${_pair} failed";
  else
    Assert.fail "extractValueInPair ${_pair} failed";
  fi

  _pair="name1= ";
  _expected="";
  if extractValueInPair "${_pair}"; then
    Assert.areEqual "${_expected}" "${RESULT}" "extractValueInPair ${_pair} failed";
  else
    Assert.fail "extractValueInPair ${_pair} failed";
  fi
}

function overrideEnvVar_works_test() {
  defineEnvVar OVERRIDE_ENVVAR_TEST OPTIONAL "test envvar" "not overridden";
  Assert.areEqual "${OVERRIDE_ENVVAR_TEST}" "not overridden" "OVERRIDE_ENVVAR is not defined correctly";
  overrideEnvVar OVERRIDE_ENVVAR_TEST "overridden";
  Assert.areEqual "${OVERRIDE_ENVVAR_TEST}" "overridden" "OVERRIDE_ENVVAR is not overridden correctly";
}

function isVariableDefinedInFile_works_test() {
  createTempFile;
  local _file="${RESULT}";
  cat <<EOF > "${_file}"
defineEnvVar MYVAR MANDATORY "The MYVAR description" "myValue";
EOF

  isVariableDefinedInFile "${_file}" MYVAR;
  local -i _result=$?;
  Assert.isTrue ${_result} "isVariableDefinedInFile [file] MYVAR failed";
  isVariableDefinedInFile "${_file}" MYOTHERVAR;
  _result=$?;
  Assert.isFalse ${_result} "isVariableDefinedInFile [file] MYOTHERVAR passed and should not pass";
}

declare -Ag __DW_ASSOCIATIVE_ARRAY_FOR_TESTING=( [foo11]=bar11 [foo214]=bar214 [key-without-spaces]="value with spaces" [key with spaces]="value with spaces");

setScriptDescription "Runs all tests implemented for envvar.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
