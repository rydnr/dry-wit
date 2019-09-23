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

  removeSuffix 'my text"' '"';
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "my text" "removeSuffix 'my text"' '"' returned '${_result}' instead of 'my text'";
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
}

function areEqual_test() {
  areEqual "a" "a";
  Assert.isTrue $? "areEqual \"a\" \"a\" failed";
}

function split_test() {
  local _text="a;b;c";
  local _separator=";";
  if split "${_text}" "${_separator}"; then
    Assert.areEqual "a b c" "${RESULT}" "split \"${_text}\" \"${_separator}\" failed";
  else
    Assert.fail "split \"${_text}\" \"${_separator}\" failed";
  fi

  _text="a-b-c";
  _separator="-";
  if split "${_text}" "${_separator}"; then
      Assert.areEqual "a b c" "${RESULT}" "split \"${_text}\" \"${_separator}\" failed";
  else
      Assert.fail "split \"${_text}\" \"${_separator}\" failed";
  fi
}

function startsAndEndsWith_test() {
  local _text='"abc"';
  startsAndEndsWith "${_text}" '"';
  Assert.isTrue $? "startAndEndsWith \"${_text}\" '\"' failed";
}

function removeSurrounding_test() {
  local _text='-abc-';
  local _delimiter="-";
  if removeSurrounding "${_text}" "${_delimiter}"; then
    Assert.areEqual 'abc' "${RESULT}" "removeSurrounding \"${_text}\" \"${_delimiter}\" failed";
  else
    Assert.fail "removeSurrounding \"${_text}\" \"${_delimiter}\" failed";
  fi
  removeSurrounding "${_text}" "'";
  Assert.isFalse $? "removeSurrounding \"${_text}\" \"'\" succeed and it shouldn't";
}

function keyValueSplit_test() {
  local _text='key1="value1"';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";

  _text='key1="value1" key2="value2"';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";

  _text='key1="value1" key2="value2" key3="value3 with spaces"';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";
  Assert.areEqual 'key1="value1"
key2="value2"
key3="value3 with spaces"' "${RESULT}"  "keyValueSplit \"${_text}\" failed";

  local _text='key1=value1';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";

  _text='key1="value1" key2=value2';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";

  _text='key1=value1 key2=value2 key3="value3 with spaces"';
  keyValueSplit "${_text}";
  Assert.isTrue $? "keyValueSplit \"${_text}\" failed";
  Assert.areEqual 'key1=value1
key2=value2
key3="value3 with spaces"' "${RESULT}"  "keyValueSplit \"${_text}\" failed";
}

function sha512_test() {
  local _text="blablabla";
  sha512 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha512 \"${_text}\" failed";
  Assert.areEqual '7a7cfc99db9802272d1987e287926ac52642417bf2d68455e180412c226430d0321610e8740a46783b2b42802918d62d206d3b1b21dc600b6944ddecf5d9c256' "${_aux}" "sha512 \"${_text}\" failed";
}

function sha384_test() {
  local _text="blablabla";
  sha384 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha384 \"${_text}\" failed";
  Assert.areEqual 'e481492518ccc3aa9101d78a1692f1f21507ee40527b1f753c4a83fa244039f2569778bc19696a71fec0d8e8dcdb0e9e' "${_aux}" "sha384 \"${_text}\" failed";
}

function sha256_test() {
  local _text="blablabla";
  sha256 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha256 \"${_text}\" failed";
  Assert.areEqual '492f3f38d6b5d3ca859514e250e25ba65935bcdd9f4f40c124b773fe536fee7d' "${_aux}" "sha256 \"${_text}\" failed";
}

function sha224_test() {
  local _text="blablabla";
  sha224 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha224 \"${_text}\" failed";
  Assert.areEqual 'ab5f4e88665613700445f96ecf1eecb5f99125b72bda5851d5e80e78' "${_aux}" "sha224 \"${_text}\" failed";
}

function sha1_test() {
  local _text="blablabla";
  sha1 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha1 \"${_text}\" failed";
  Assert.areEqual '23c6834b1d353eabf976e524ed489c812ff86a7d' "${_aux}" "sha1 \"${_text}\" failed";
}

function sha_test() {
  local _text="blablabla";
  sha "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha \"${_text}\" failed";
  Assert.areEqual '23c6834b1d353eabf976e524ed489c812ff86a7d' "${_aux}" "sha \"${_text}\" failed";
}

setScriptDescription "Runs all tests implemented for string.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
