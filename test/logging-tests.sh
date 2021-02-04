#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

# helper function
function empty_log_category() {
  local _oldIFS="${IFS}";
  LOGGING.popLogCategory;
  local -i _rescode=$?;
  local _category="${RESULT}";
  IFS="${DWIFS}";
  while isTrue ${_rescode}; do
    IFS="${_oldIFS}";
    LOGGING.popLogCategory;
    _rescode=$?;
    _category="${RESULT}";
  done
  IFS="${_oldIFS}";
  LOGGING.peekLogCategory;
  _category="${RESULT}";
  export RESULT="${_category}";
  isEmpty "${_category}";
  return $?;
}

function LOGGING.alignRightForWidth_finds_the_correct_offset_test() {
  local -i _termWidth=212;
  local _logMessage="[2020/06/11 18:28:52<logging-tests|myCategory>.] LOGGING.buildLogCategoryPrefix works";
  local _outcome="did not pass";
  LOGGING.processLogOutcomeTokens "${_outcome}";
  LOGGING.logOutcomeTokensLength;
  local -i _logOutcomeTokensLength=${RESULT};
  LOGGING.alignRightForWidth "${_logMessage}" ${_termWidth};
  local -i _rescode=$?;
  local -i _actual=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  local -i _expected=$((${_termWidth}-(${#_logMessage}+${_logOutcomeTokensLength})%${_termWidth} + 1));
  Assert.areEqual ${_expected} ${_actual} "LOGGING.alignRightForWidth doesn't find the correct offset in nested logging";
}

function LOGGING.alignRightForWidth_finds_the_correct_offset_in_nested_logging_test() {
  local -i _termWidth=212;
  local _message="This is a INFO message";
  local _logMessage="[2020/06/11 18:43:14<logging-tests|main:aeourch:3138465:.apurchoaekj/olekh:main:the_log_category_is_propagated_to_nested_logging_test>.] ${_message}";
  local _outcome="....";
  LOGGING.processLogOutcomeTokens "${_outcome}";
  LOGGING.logOutcomeTokensLength;
  local -i _logOutcomeTokensLength=${RESULT};
  LOGGING.alignRightForWidth "${_logMessage}" ${_termWidth};
  local -i _rescode=$?;
  local -i _actual=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  local -i _expected=$((${_termWidth}-(${#_logMessage}+${_logOutcomeTokensLength})%${_termWidth} + 1));
  Assert.areEqual ${_expected} ${_actual} "LOGGING.alignRightForWidth doesn't find the correct offset in nested logging";
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
