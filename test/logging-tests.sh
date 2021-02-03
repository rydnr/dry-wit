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
  local -i _width=212;
  local _message="[2020/06/11 18:28:52<logging-tests|myCategory>.] LOGGING.buildLogCategoryPrefix works";
  local _outcome="pass";
  LOGGING.alignRightForWidth "${_message}" "${_outcome}" ${_width};
  local -i _rescode=$?;
  local -i _offset=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  Assert.areEqual $((${_width}-${#_message}-${#_outcome}-2-1)) ${_offset} "LOGGING.alignRightForWidth doesn't find the correct offset";
}

function LOGGING.alignRightForWidth_finds_the_correct_offset_in_nested_logging_test() {
  local -i _width=212;
  local _message="This is a INFO message";
  local _logMessage="[2020/06/11 18:43:14<logging-tests|main:aeourch:3138465:.apurchoaekj/olekh:main:the_log_category_is_propagated_to_nested_logging_test>.] ${_message}";
  local _outcome="....";
  logInfo -n "${_message}";
  LOGGING.alignRightForWidth "${_message}" "${_outcome}" ${_width};
  local -i _rescode=$?;
  local -i _offset=${RESULT};
  logResult "done";
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  Assert.areEqual $((${_width}-${#_logMessage}-${#_outcome}-2-1)) ${_offset} "LOGGING.alignRightForWidth doesn't find the correct offset in nested logging";
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
