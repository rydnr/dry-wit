#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function contains_test() {
  contains "abc" "b";
  Assert.isTrue $? "contains 'abc' 'b' failed";

  contains "abc" "f";
  Assert.isFalse $? "contains 'abc' 'f' failed";
}

function startsWith_test() {
  startsWith "abc" "a";
  Assert.isTrue $? "startsWith 'abc' 'a' failed";

  startsWith "abc" "b";
  Assert.isFalse $? "startsWith 'abc' 'b' failed";
}

function endsWith_test() {
  endsWith "abc" "c";
  Assert.isTrue $? "endsWith 'abc' 'a' failed";

  endsWith "abc" "b";
  Assert.isFalse $? "endsWith 'abc' 'b' failed";
}

function removePrefix_test() {
  removePrefix "--abc" "-*";
  local -i _done=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_done} "removePrefix failed";
  Assert.areEqual "${_result}" "abc" "removePrefix '--abc' '-*' returned '${_result}' instead of 'abc'";
}

function removeSuffix_test() {
  removeSuffix "abc--" "-*";
  local -i _done=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "abc" "removeSuffix 'abc--' '-*' returned '${_result}' instead of 'abc'";

  removeSuffix "my-test.sh" "-test.sh";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "my" "removeSuffix 'my-test.sh' '-test.sh' returned '${_result}' instead of 'my'";
}

function toUpper_test() {
  toUpper "abc";
  local _result="${RESULT}";
  Assert.areEqual "ABC" "${_result}" "toUpper failed for 'abc'";
}

function toLower_test() {
  toLower "ABC";
  local _result="${RESULT}";
  Assert.areEqual "abc" "${_result}" "toLower failed for 'ABC'";
}

function normalize_test() {
  normalize "X:default-values";
  local _result="${RESULT}";
  Assert.areEqual "X_default_values" "${_result}" "normalize failed for 'X:default-values'";
}

function normalizeUppercase_test() {
  normalizeUppercase "X:default-values";
  local _result="${RESULT}";
  Assert.areEqual "X_DEFAULT_VALUES" "${_result}" "normalize failed for 'X:default-values'";
}

function replaceAll_test() {
  replaceAll "a b c" " " ",";
  local _result="${RESULT}";
  Assert.areEqual "a,b,c" "${_result}" "replaceAll 'a b c' failed";

function areEqual_test() {
  areEqual "a" "a";
  Assert.isTrue $? "areEqual \"a\" \"a\" failed";
}
#
