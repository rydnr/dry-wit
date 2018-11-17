#!/bin/bash ../src/dry-wit-test
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
  Assert.areEqual "${_result}" "abc" "removePrefix --abc returned ${_result} instead of abc";
}
