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
  if toOrdinal "0"; then
    Assert.fail "toOrdinal '0' returned ${RESULT}";
  else
    Assert.pass;
  fi
}

function oneToOrdinal_test() {
  if toOrdinal "1"; then
    Assert.areEqual "1st" "${RESULT}" "toOrdinal '1' failed";
  else
    Assert.fail "toOrdinal '1' failed";
  fi
}

function twoToOrdinal_test() {
  if toOrdinal "2"; then
    Assert.areEqual "2nd" "${RESULT}" "toOrdinal '2' failed";
  else
    Assert.fail "toOrdinal '2' failed";
  fi
}

function threeToOrdinal_test() {
  if toOrdinal "3"; then
    Assert.areEqual "3rd" "${RESULT}" "toOrdinal '3' failed";
  else
    Assert.fail "toOrdinal '3' failed";
  fi
}

function toOrdinal_test() {
  local -i i;
  local _oldIFS="${IFS}";

  for i in {4..50}; do
    IFS="${_oldIFS}";
    if toOrdinal "${i}"; then
      Assert.areEqual "${i}th" "${RESULT}" "toOrdinal '${i}' failed";
    else
      Assert.fail "toOrdinal '${i}' failed";
    fi
  done
  IFS="${_oldIFS}";
}

setScriptDescription "Runs all tests implemented for number.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
