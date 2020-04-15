#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function log_category_is_printed_while_logging_test() {
  local _result="$(logInfo 'sample log')";
  Assert.isNotEmpty "${_result}" "logInfo 'something' didn't print anything";
}

function echoLogOutcome_does_not_call_alignRight_with_invalid_keyword_parameter_test() {
  local _result="$(logInfo 'sample log' 2>&1)";
  Assert.doesNotContain "'SUCCESS|FAILURE' (pass) is not valid when calling LOGGING.alignRight. Review LOGGING.echoLogOutcome" "${_result}" "LOGGING.echoLogOutcome calls LOGGING.alignRight incorrectly";
}

function logToFile_appends_logging_to_a_file_test() {
  createTempFile;
  local _file="${RESULT}";

  local _message='sample logging message';
  logToFile "${_file}";
  logInfo "${_message}" > /dev/null 2&>1;
  tail -n 2 "${_file}" | grep "${_message}" > /dev/null > 2&>1;
  Assert.isTrue $? "Log file didn't contain logging";
  cat "${_file}" > /tmp/log
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
