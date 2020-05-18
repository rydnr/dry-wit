#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import number;

function isNumber_works_test() {
  isNumber "3";
  Assert.isTrue $? "isNumber '3' failed";
}

function mod_works_test() {
  if mod 7 10; then
    Assert.areEqual 7 ${RESULT} "mod 7 10 failed";
  else
    Assert.fail "mod 7 10 failed";
  fi
}

function isGreaterOrEqualTo_works_test() {
  Assert.isTrue isGreaterOrEqualTo 3 2 "isGreaterOrEqualTo 3 2 failed";
  Assert.isTrue isGreaterOrEqualTo 3 3 "isGreaterOrEqualTo 3 3 failed";
  Assert.isFalse isGreaterOrEqualTo 2 3 "isGreaterOrEqualTo 2 3 failed";
  isGreaterOrEqualTo "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isGreaterOrEqualTo 'a' 3 failed";
}

function isGreaterThan_works_test() {
  Assert.isTrue isGreaterThan 3 2 "isGreaterThan 3 2 failed";
  Assert.isFalse isGreaterThan 3 3 "isGreaterThan 3 3 failed";
  Assert.isFalse isGreaterThan 2 3 "isGreaterThan 2 3 failed";
  isGreaterThan "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isGreaterThan 'a' 3 failed";
}

function isLessOrEqualTo_works_test() {
  Assert.isTrue isLessOrEqualTo 2 3 "isLessOrEqualTo 2 3 failed";
  Assert.isFalse isLessOrEqualTo 3 3 "isLessOrEqualTo 3 3 failed";
  Assert.isFalse isLessOrEqualTo 3 2 "isLessOrEqualTo 3 2 failed";
  Assert.isTrue isLessOrEqualTo -1 0 "isLessOrEqualTo -1 0 failed";
  isLessOrEqualTo "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isLessOrEqualTo 'a' 3 failed";
}

function isLessThan_works_test() {
  Assert.isTrue isLessThan 2 3 "isLessThan 2 3 failed";
  Assert.isFalse isLessThan 3 3 "isLessThan 3 3 failed";
  Assert.isFalse isLessThan 3 2 "isLessThan 3 2 failed";
  isLessThan "a" 3;
  local -i _result=$?;
  Assert.areEqual 255 ${_result} "isLessThan 'a' 3 failed";
}

function zeroToOrdinal_works_test() {
  toOrdinal "0";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isFalse ${_rescode} "toOrdinal '0' returned ${RESULT}";
}

function oneToOrdinal_works_test() {
  toOrdinal "1";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '1' failed";
  Assert.areEqual "1st" "${RESULT}" "toOrdinal '1' failed";
}

function twoToOrdinal_works_test() {
  toOrdinal "2";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '2' failed";
  Assert.areEqual "2nd" "${RESULT}" "toOrdinal '2' failed";
}

function threeToOrdinal_works_test() {
  toOrdinal "3";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '3' failed";
  Assert.areEqual "3rd" "${RESULT}" "toOrdinal '3' failed";
}

function fourToOrdinal_works_test() {
  toOrdinal "4";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "toOrdinal '4' failed";
  Assert.areEqual "4th" "${RESULT}" "toOrdinal '4' failed";
}

function lastDigit_works_test() {
  lastDigit "35";
  local _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "lastDigit '35' failed";
  Assert.areEqual "5" "${RESULT}" "lastDigit '35' failed";
}

function toOrdinal_works_test() {
  local -i i;
  local _rescode=$?;
  local _expected;
  local _actual;
  local _oldIFS="${IFS}";

  IFS="${DWIFS}";
  for i in $(seq 1 105); do
    IFS="${_oldIFS}";
    toOrdinal "${i}";
    _rescode=$?;
    _actual="${RESULT}";
    Assert.isTrue ${_rescode} "toOrdinal '${i}' failed";
    if endsWith "${i}" "1"; then
      _expected="${i}st";
    elif endsWith "${i}" "2"; then
      _expected="${i}nd";
    elif endsWith "${i}" "3"; then
      _expected="${i}rd";
    else
      _expected="${i}th";
    fi
    Assert.areEqual "${_expected}" "${_actual}" "toOrdinal '${i}' failed";
  done
  IFS="${_oldIFS}";
}

function multiply_works_test() {
  local -i _first=3;
  local -i _second=5;

  multiply ${_first} ${_second};
  local -i _rescode=$?;
  local _result=${RESULT};

  Assert.isTrue ${_rescode} "multiply ${_first} ${_second} failed (non-zero code)";
  Assert.isNotEmpty "${_result}" "multiply ${_first} ${_second} failed (returned an empty string)";
  Assert.areEqual 15 "${_result}" "multiply ${_first} ${_second} failed (${_result})";
}

function divide_works_test() {
  local -i _first=15;
  local -i _second=5;

  divide ${_first} ${_second};
  local -i _rescode=$?;
  local -i _result=${RESULT};

  Assert.isTrue ${_rescode} "divide ${_first} ${_second} failed (non-zero code))";
  Assert.isNotEmpty "${_result}" "divide ${_first} ${_second} failed (returned an empty string)";
  Assert.areEqual 3 "${_result}" "divide ${_first} ${_second} failed (${_result})";
}

function add_works_test() {
  local -i _first=15;
  local -i _second=5;

  add ${_first} ${_second} 2> /dev/null;
  local -i _rescode=$?;
  local _result=${RESULT};

  Assert.isTrue ${_rescode} "add ${_first} ${_second} failed (non-zero-code)";
  Assert.isNotEmpty "${_result}" "add ${_first} ${_second} failed (returned an empty string)";
  Assert.areEqual 20 "${_result}" "add ${_first} ${_second} failed (${_result})";
}

function subtract_works_test() {
  local -i _first=15;
  local -i _second=5;

  subtract ${_first} ${_second};
  local -i _rescode=$?;
  local -i _result=${RESULT};

  Assert.isTrue ${_rescode} "subtract ${_first} ${_second} (non-zero code)";
  Assert.isNotEmpty "${_result}" "subtract ${_first} ${_second} failed (returned an empty string)";
  Assert.areEqual 10 "${_result}" "subtract ${_first} ${_second} failed (${_result})";
}

setScriptDescription "Runs all tests implemented for number.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
