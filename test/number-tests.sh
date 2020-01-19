#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import number;

function isNumber_test() {
  isNumber "3";
  Assert.isTrue $? "isNumber '3' failed";
}

function mod_test() {
  if mod 7 10; then
    Assert.areEqual 7 ${RESULT} "mod 7 10 failed";
  else
    Assert.fail "mod 7 10 failed";
  fi
}

function isGreaterOrEqualTo_test() {
  Assert.isTrue isGreaterOrEqualTo 3 2 "isGreaterOrEqualTo 3 2 failed";
  Assert.isTrue isGreaterOrEqualTo 3 3 "isGreaterOrEqualTo 3 3 failed";
  Assert.isFalse isGreaterOrEqualTo 2 3 "isGreaterOrEqualTo 2 3 failed";
  isGreaterOrEqualTo "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isGreaterOrEqualTo 'a' 3 failed";
}

function isGreaterThan_test() {
  Assert.isTrue isGreaterThan 3 2 "isGreaterThan 3 2 failed";
  Assert.isFalse isGreaterThan 3 3 "isGreaterThan 3 3 failed";
  Assert.isFalse isGreaterThan 2 3 "isGreaterThan 2 3 failed";
  isGreaterThan "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isGreaterThan 'a' 3 failed";
}

function isLessOrEqualTo_test() {
  Assert.isTrue isLessOrEqualTo 2 3 "isLessOrEqualTo 2 3 failed";
  Assert.isFalse isLessOrEqualTo 3 3 "isLessOrEqualTo 3 3 failed";
  Assert.isFalse isLessOrEqualTo 3 2 "isLessOrEqualTo 3 2 failed";
  Assert.isTrue isLessOrEqualTo -1 0 "isLessOrEqualTo -1 0 failed";
  isLessOrEqualTo "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isLessOrEqualTo 'a' 3 failed";
}

function isLessThan_test() {
  Assert.isTrue isLessThan 2 3 "isLessThan 2 3 failed";
  Assert.isFalse isLessThan 3 3 "isLessThan 3 3 failed";
  Assert.isFalse isLessThan 3 2 "isLessThan 3 2 failed";
  isLessThan "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isLessThan 'a' 3 failed";
}

function zeroToOrdinal_test() {
  toOrdinal "0";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isFalse ${_rescode} "toOrdinal '0' returned ${RESULT}";
}

function oneToOrdinal_test() {
  toOrdinal "1";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '1' failed";
  Assert.areEqual "1st" "${RESULT}" "toOrdinal '1' failed";
}

function twoToOrdinal_test() {
  toOrdinal "2";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '2' failed";
  Assert.areEqual "2nd" "${RESULT}" "toOrdinal '2' failed";
}

function threeToOrdinal_test() {
  toOrdinal "3";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '3' failed";
  Assert.areEqual "3rd" "${RESULT}" "toOrdinal '3' failed";
}

function fourToOrdinal_test() {
  toOrdinal "4";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '4' failed";
  Assert.areEqual "4th" "${RESULT}" "toOrdinal '4' failed";
}

function lastDigit_test() {
  lastDigit "35";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "lastDigit '35' failed";
  Assert.areEqual "5" "${RESULT}" "lastDigit '35' failed";
}

function toOrdinal_test_() {
  local -i i;
  local _rescode=$?;
  local _result="${RESULT}";
  local _oldIFS="${IFS}";

  IFS="${DWIFS}";
  for i in $(seq 5 50); do
    IFS="${_oldIFS}";
    toOrdinal "${i}";
    _rescode=$?;
    _result="${RESULT}";
    Assert.isTrue ${_rescode} "toOrdinal '${i}' failed";
    Assert.areEqual "${i}th" "${RESULT}" "toOrdinal '${i}' failed";
  done
  IFS="${_oldIFS}";
}

setScriptDescription "Runs all tests implemented for number.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
