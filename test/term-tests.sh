#!/usr/bin/env dry-wit

DW.import term

function retrieveTERM_returns_os_when_empty_test() {
  TERM=""
  retrieveTERM
  local expected="$(uname | tr '[:upper:]' '[:lower:]')"
  Assert.areEqual "${expected}" "${RESULT}" "retrieveTERM did not return OS name"
}

function getTermWidth_prefers_env_variable_test() {
  export DW_TERM_WIDTH=55
  getTermWidth
  Assert.areEqual 55 "${RESULT}" "getTermWidth didn't use DW_TERM_WIDTH"
  unset DW_TERM_WIDTH
}

function TERM.retrieveTermWidthFromEnvVar_returns_value_test() {
  export DW_TERM_WIDTH=90
  TERM.retrieveTermWidthFromEnvVar
  Assert.areEqual 0 $? "TERM.retrieveTermWidthFromEnvVar failed"
  Assert.areEqual 90 "${RESULT}" "Wrong width"
  unset DW_TERM_WIDTH
}

setScriptDescription "Runs tests for term.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
