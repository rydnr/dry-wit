#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import error;

function test_reset() {
  ERROR.resetState;
}

## Called before each test.
function test_setup() {
  test_reset;
}

## Called after each test.
function test_tearDown() {
  test_reset;
}

function isErrorDefined_works_test() {
  local -i _defined;
  addError ERROR1 "error 1 message";
  isErrorDefined ERROR1;
  _defined=$?;
  Assert.isTrue ${_defined} "isErrorDefined doesn't find ERROR1";
}

function exitWithError_declares_a_new_error_if_necessary_test() {
  local -i _errorCode;
  local _result;
  (exitWithError UNDEFINED_ERROR "Undefined error" > /dev/null);
  _errorCode=$?;
  _result="$(exitWithError UNDEFINED_ERROR "Custom undefined error")";
  Assert.isFalse ${_errorCode} "exitWithError doesn't exit with an error code";
  Assert.isNotEmpty ${_result} "exitWithError doesn't print anything";
  Assert.contains "${_result}" "Custom undefined error" "exitWithError doesn't define UNDEFINED_ERROR on demand";
}

function addError_converts_error_name_to_uppercase_test() {
  local -i _defined;
  addError error_sample "error sample";
  isErrorDefined ERROR_SAMPLE;
  _defined=$?;
  Assert.isTrue ${_defined} "isErrorDefined doesn't find ERROR_SAMPLE";
}


function exitWithErrorCode_finds_declared_error_test() {
  local -i _result;
  addError error_sample "error sample";
  (exitWithErrorCode ERROR_SAMPLE "exited due to error sample" 2>&1 > /dev/null 2>&1);
  _result=$?;
  Assert.isFalse ${_result} "exitWithErrorCode finds ERROR_SAMPLE";
}

setScriptDescription "Runs all tests implemented for error.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
