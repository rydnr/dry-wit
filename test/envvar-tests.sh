#!/usr/bin/env dry-wit
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
  defineEnvVar MY_VAR MANDATORY "My env var" "foo" "date";
  ENVVAR.getEnvironmentVariablesVariableName;
  local _variableName=${RESULT};
  local -n _envVariables=${_variableName};
  Assert.isNotEmpty "${_envVariables[@]}" "Environment variables array is empty";
  # The next line is critical!
  local _array="${_envVariables[@]}";
  Assert.arrayContains MY_VAR "${_array}" 'Environment variables array does not contain MY_VAR.';
}

function defineEnvVar_does_not_add_an_already_existing_environment_variable_to_envVars_names_test() {
  local _expected="first value";
  defineEnvVar MY_VAR_1 MANDATORY "My env var" "${_expected}";
  Assert.areEqual "${MY_VAR_1}" "${_expected}" "Invalid value of MY_VAR_1";
  defineEnvVar MY_VAR_1 MANDATORY "My env var" "other value";
  Assert.isFalse $? "MY_VAR_1 shouldn't be defined more than once";
  Assert.areEqual "${MY_VAR_1}" "${_expected}" "MY_VAR_1 should remain constant when using defineEnvVar";
  ENVVAR.getEnvironmentVariablesVariableName;
  local _variableName=${RESULT};
  local -n _envVariables=${_variableName};
  local _oldIFS="${IFS}";
  local _envVar;
  local -i _matches=0;
  IFS="${DWIFS}";
  for _envVar in ${_envVariables[@]}; do
    if areEqual "${_envVar}" MY_VAR_1; then
      _matches=$((_matches+1));
    fi
  done
  isGreaterThan ${_matches} 1;
  Assert.isFalse $? "MY_VAR_1 is annotated ${_matches} times, instead of 1";
}

function defineEnvVar_does_not_add_an_already_existing_environment_variable_test() {
  local _expected="first value";
  defineEnvVar MY_VAR_2 MANDATORY "My env var" "${_expected}";
  Assert.isTrue $? "Couldn't define MY_VAR_2";
  Assert.areEqual "${MY_VAR_2}" "${_expected}" "Invalid value of MY_VAR_2";
  defineEnvVar MY_VAR_2 MANDATORY "My env var" "other value";
  Assert.isFalse $? "MY_VAR_2 shouldn't be defined more than once";
}

function defineEnvVar_overrides_an_existing_environment_variable_test() {
  local _expected1="first value";
  defineEnvVar MY_VAR_3 MANDATORY "My env var" "${_expected}";
  Assert.areEqual "${MY_VAR_3}" "${_expected}" "Invalid value of MY_VAR_3";
  local _expected2="other value";
  defineEnvVar MY_VAR_3 MANDATORY "My env var" "${_expected2}";
  Assert.areEqual "${MY_VAR_3}" "${_expected2}" "MY_VAR_3 should have changed";
}

function isEnvVarDefined_detects_existing_envvars_test() {
  defineEnvVar MY_VAR_4 MANDATORY "My env var" "whatever";
  isEnvVarDefined MY_VAR_4;
  Assert.isTrue $? "MY_VAR_4 is not detected";
  isEnvVarDefined "MY_VAR_4_$$";
  Assert.isFalse $? "MY_VAR_4_$$ is detected and it shouldn't";
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

function check_bug_envvar_defaults_fixed_test() {
  local _expected="contest.created contest.updated form.created form.updated application.created application.updated";
  defineEnvVar EVENT_EXCHANGE_TO_EVENT_QUEUE_BINDINGS MANDATORY "The space-separated list of bindings from the events exchange to the FormService event queue" "${_expected}";
  evalEnvVar EVENT_EXCHANGE_TO_EVENT_QUEUE_BINDINGS;
  local _actual="${RESULT}";
  Assert.areEqual "${_expected}" "${_actual}" "evalVarDefault failed for EVENT_EXCHANGE_TO_EVENT_QUEUE_BINDINGS";

  _expected="/backup/rabbitmq/storage/mnesia/.bootstrap.lock";
  defineEnvVar BOOTSTRAP_LOCK_FILE MANDATORY "The file indicating if the bootstrap is running" "${_expected}";
  evalEnvVar BOOTSTRAP_LOCK_FILE;
  _actual="${RESULT}";
  Assert.areEqual "${_expected}" "${_actual}" "evalVarDefault failed for BOOTSTRAP_LOCK_FILE";
}

function isInEnvvarFormat_works_test() {
  local _input="create.contest";
  ENVVAR.isInEnvvarFormat "${_input}";
  Assert.isFalse $? "ENVVAR.isInEnvvarFormat failed for ${_input}";

  _input="/Dockerfile";
  ENVVAR.isInEnvvarFormat "${_input}";
  Assert.isFalse $? "ENVVAR.isInEnvvarFormat failed for ${_input}";

  _input="MY_VAR";
  ENVVAR.isInEnvvarFormat "${_input}";
  Assert.isTrue $? "ENVVAR.isInEnvvarFormat failed for ${_input}";

  _input="my_var";
  ENVVAR.isInEnvvarFormat "${_input}";
  Assert.isFalse $? "ENVVAR.isInEnvvarFormat failed for ${_input}";

  _input="/backup/rabbitmq/changesets";
  ENVVAR.isInEnvvarFormat "${_input}";
  Assert.isFalse $? "ENVVAR.isInEnvvarFormat failed for ${_input}";
}

function check_checkIsEnvVarReadonly_works_test() {
  export MY_EXTERNAL_VAR="$(date)";
  defineEnvVar MY_EXTERNAL_VAR OPTIONAL "Test variable" "${MY_EXTERNAL_VAR}";
  ENVVAR.isEnvVarReadonly MY_EXTERNAL_VAR;
  Assert.isTrue $? "ENVVAR.isEnvVarReadonly failed for MY_EXTERNAL_VAR / ${MY_EXTERNAL_VAR}";
}

function check_overrideEnvVar_fails_for_environment_variables_defined_externally_test() {
  local _expected="$(date)";
  export MY_EXTERNAL_VAR2="${_expected}";
  defineEnvVar MY_EXTERNAL_VAR2 OPTIONAL "Test variable" "${MY_EXTERNAL_VAR}";
  local _overriden="A different value";
  overrideEnvVar MY_EXTERNAL_VAR2 "${_overriden}";
  Assert.isFalse $? "ENVVAR.overrideEnvVar returned TRUE for MY_EXTERNAL_VAR2";
  Assert.areEqual "${_expected}" "${MY_EXTERNAL_VAR2}" "ENVVAR.overrideEnvVar changed MY_EXTERNAL_VAR2 value from ${_expected} to ${_overriden}";
}

declare -Ag __DW_ASSOCIATIVE_ARRAY_FOR_TESTING=( [foo11]=bar11 [foo214]=bar214 [key-without-spaces]="value with spaces" [key with spaces]="value with spaces");

setScriptDescription "Runs all tests implemented for envvar.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
