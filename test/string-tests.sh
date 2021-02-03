#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function contains_works_test() {
  local _text="abc";
  local _piece="b";
  contains "${_text}" "${_piece}";
  Assert.isTrue $? "contains '${_text}' '${_piece}' failed";

  _text="abc";
  _piece="f";
  contains "${_text}" "${_piece}";
  Assert.isFalse $? "contains '${_text}' '${_piece}' failed";

  _text="dev-contestia-50-core-CoreService";
  _piece="core";
  contains "${_text}" "${_piece}";
  Assert.isTrue $? "contains '${_text}' '${_piece}' failed";

  _text="contest.created";
  _piece=".";
  contains "${_text}" "${_piece}";
  Assert.isTrue $? "contains '${_text}' '${_piece}' failed";

  _text="contest-created";
  _piece=".";
  contains "${_text}" "${_piece}";
  Assert.isFalse $? "contains '${_text}' '${_piece}' failed";
}

function contains_works_for_multiline_texts_test() {

  local _text="
something";
  local _piece="something";
  contains "${_text}" "${_piece}";
  Assert.isTrue $? "contains '${_text}' '${_piece}' failed";

  _text="
An error occurred (AlreadyExistsException) when calling the CreateStack operation: Stack [staging-contestia-55-s3uploader-05-certificates-us-east-1] already exists";
  _piece="already exists";

  contains "${_text}" "${_piece}";
  Assert.isTrue $? "contains '${_text}' '${_piece}' failed";
}

function startsWith_works_test() {
  startsWith "abc" "a";
  Assert.isTrue $? "startsWith 'abc' 'a' failed";

  startsWith "abc" "b";
  Assert.isFalse $? "startsWith 'abc' 'b' failed";
}

function endsWith_works_test() {
  endsWith "abc" "c";
  Assert.isTrue $? "endsWith 'abc' 'a' failed";

  endsWith "abc" "b";
  Assert.isFalse $? "endsWith 'abc' 'b' failed";
}

function removePrefix_works_test() {
  local _input="--abc";
  local _prefix='--';
  local _expected='abc';
  removePrefix "${_input}" "${_prefix}";
  local -i _done=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_done} "removePrefix failed";
  Assert.areEqual "${_result}" "${_expected}" "removePrefix '${_input}' '${_prefix}' returned '${_result}' instead of '${_expected}'";

  _input="-e";
  _prefix='-';
  _expected='e';
  removePrefix "${_input}" "${_prefix}";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removePrefix failed";
  Assert.areEqual "${_result}" "${_expected}" "removePrefix '${_input}' '${_prefix}' returned '${_result}' instead of '${_expected}'";

  _input="-X:e";
  _prefix='-X:';
  _expected='e';
  removePrefix "${_input}" "${_prefix}";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removePrefix failed";
  Assert.areEqual "${_result}" "${_expected}" "removePrefix '${_input}' '${_prefix}' returned '${_result}' instead of '${_expected}'";
}

function removeSuffix_works_test() {
  local _input='abc--';
  local _suffix='--';
  local _expected="abc";
  removeSuffix "${_input}" "${_suffix}";
  local -i _done=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "${_expected}" "removeSuffix '${_input}' '${_suffix}' returned '${_result}' instead of '${_expected}'";

  _input="my-test.sh";
  _suffix="-test.sh";
  _expected="my";
  removeSuffix "${_input}" "${_suffix}";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "${_expected}" "removeSuffix '${_input}' '${_suffix}' returned '${_result}' instead of '${_expected}'";

  _input="my text";
  _suffix='"';
  _expected="my text";
  removeSuffix 'my text"' '"';
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "${_expected}" "removeSuffix '${_input}' '${_suffix}' returned '${_result}' instead of '${_expected}'";

  _input='abc-e';
  _suffix='-e';
  _expected="abc";
  removeSuffix "${_input}" "${_suffix}";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "${_expected}" "removeSuffix '${_input}' '${_suffix}' returned '${_result}' instead of '${_expected}'";

  _input='this_very_test';
  _suffix='_test';
  _expected="this_very";
  removeSuffix "${_input}" "${_suffix}";
  _done=$?;
  _result="${RESULT}";
  Assert.isTrue ${_done} "removeSuffix failed";
  Assert.areEqual "${_result}" "${_expected}" "removeSuffix '${_input}' '${_suffix}' returned '${_result}' instead of '${_expected}'";
}

function toUpper_works_test() {
  toUpper "abc";
  local _result="${RESULT}";
  Assert.areEqual "ABC" "${_result}" "toUpper failed for 'abc'";
}

function toLower_works_test() {
  toLower "ABC";
  local _result="${RESULT}";
  Assert.areEqual "abc" "${_result}" "toLower failed for 'ABC'";
}

function normalize_works_test() {
  normalize "X:default-values";
  local _result="${RESULT}";
  Assert.areEqual "X_default_values" "${_result}" "normalize failed for 'X:default-values'";
}

function normalizeUppercase_works_test() {
  normalizeUppercase "X:default-values";
  local _result="${RESULT}";
  Assert.areEqual "X_DEFAULT_VALUES" "${_result}" "normalize failed for 'X:default-values'";
}

function replaceAll_works_test() {
  replaceAll "a b c" " " ",";
  local _result="${RESULT}";
  Assert.areEqual "a,b,c" "${_result}" "replaceAll 'a b c' ' ' ',' failed";
}

function replaceAll_works_with_forward_slashes_test() {
  replaceAll "a/b/c" "b" ",";
  local _result="${RESULT}";
  Assert.areEqual "a/,/c" "${_result}" "replaceAll 'a/b/c' 'b' ',' failed";
}

function replaceAll_works_with_backward_slashes_test() {
  replaceAll "a\\b\\c" "b" ",";
  local _result="${RESULT}";
  Assert.areEqual "a\\,\\c" "${_result}" "replaceAll 'a\\b\\c' 'b' ',' failed";
}

function replaceAll_works_with_ampersands_test() {
  replaceAll "a&b&c" "b" ",";
  local _result="${RESULT}";
  Assert.areEqual "a&,&c" "${_result}" "replaceAll 'a&b&c' 'b' ',' failed";
}

function areEqual_works_test() {
  areEqual "a" "a";
  Assert.isTrue $? "areEqual \"a\" \"a\" failed";
}

function split_works_test() {
  local _text="a;b;c";
  local _separator=";";
  local -a _myArray;
  split "${_text}" "${_separator}" _myArray;
  local -i _rescode=$?;
  Assert.isTrue ${_rescode} "split \"${_text}\" \"${_separator}\ _myArray failed";
  Assert.areEqual "3" "${#_myArray[@]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "a" "${_myArray[0]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "b" "${_myArray[1]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "c" "${_myArray[2]}" "split \"${_text}\" \"${_separator}\" _myArray failed";

  _text="d-e-f-g";
  _separator="-";
  split "${_text}" "${_separator}" _myArray;
 _rescode=$?;
  Assert.isTrue ${_rescode} "split \"${_text}\" \"${_separator}\ _myArray failed";
  Assert.areEqual "4" "${#_myArray[@]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "d" "${_myArray[0]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "e" "${_myArray[1]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "f" "${_myArray[2]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
  Assert.areEqual "g" "${_myArray[3]}" "split \"${_text}\" \"${_separator}\" _myArray failed";
}

function startsAndEndsWith_works_test() {
  local _text='"abc"';
  startsAndEndsWith "${_text}" '"';
  Assert.isTrue $? "startAndEndsWith \"${_text}\" '\"' failed";
}

function removeSurrounding_works_test() {
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
function trim_works_test() {
  local _text='    abc       ';
  trim "${_text}";
  Assert.areEqual 'abc' "${RESULT}" "trim \"${_text}\" failed";
}

function keyValueSplit_works_test() {
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

  _text='key1=value1';
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

function sha512_works_test() {
  local _text="blablabla";
  sha512 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha512 \"${_text}\" failed";
  Assert.areEqual '7a7cfc99db9802272d1987e287926ac52642417bf2d68455e180412c226430d0321610e8740a46783b2b42802918d62d206d3b1b21dc600b6944ddecf5d9c256' "${_aux}" "sha512 \"${_text}\" failed";
}

function sha384_works_test() {
  local _text="blablabla";
  sha384 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha384 \"${_text}\" failed";
  Assert.areEqual 'e481492518ccc3aa9101d78a1692f1f21507ee40527b1f753c4a83fa244039f2569778bc19696a71fec0d8e8dcdb0e9e' "${_aux}" "sha384 \"${_text}\" failed";
}

function sha256_works_test() {
  local _text="blablabla";
  sha256 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha256 \"${_text}\" failed";
  Assert.areEqual '492f3f38d6b5d3ca859514e250e25ba65935bcdd9f4f40c124b773fe536fee7d' "${_aux}" "sha256 \"${_text}\" failed";
}

function sha224_works_test() {
  local _text="blablabla";
  sha224 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha224 \"${_text}\" failed";
  Assert.areEqual 'ab5f4e88665613700445f96ecf1eecb5f99125b72bda5851d5e80e78' "${_aux}" "sha224 \"${_text}\" failed";
}

function sha1_works_test() {
  local _text="blablabla";
  sha1 "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha1 \"${_text}\" failed";
  Assert.areEqual '23c6834b1d353eabf976e524ed489c812ff86a7d' "${_aux}" "sha1 \"${_text}\" failed";
}

function sha_works_test() {
  local _text="blablabla";
  sha "${_text}";
  local -i _result=$?;
  local _aux="${RESULT}";
  Assert.isTrue ${_result} "sha \"${_text}\" failed";
  Assert.areEqual '23c6834b1d353eabf976e524ed489c812ff86a7d' "${_aux}" "sha \"${_text}\" failed";
}

function lastCharacter_works_test() {
  local _text="a,u[}uouk]";
  lastCharacter "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "lastCharacter '${_text}' failed";
  Assert.areEqual ']' "${_result}" "lastCharacter '${_text}' failed";
}

function firstCharacter_works_test() {
  local _text="a,u[}uouk]";
  firstCharacter "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "firstCharacter '${_text}' failed";
  Assert.areEqual 'a' "${_result}" "firstCharacter '${_text}' failed";
}

function countMatchesOfCharsInString_works_test() {
  local _text="a,u[}uouk]";
  countMatchesOfCharsInString "a" "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "countMatchesOfCharsInString '${_text}' failed";
  Assert.areEqual '1' "${_result}" "countMatchesOfCharsInString '${_text}' failed";

  local _text="abcaba";
  countMatchesOfCharsInString "ab" "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  Assert.isTrue ${_rescode} "countMatchesOfCharsInString '${_text}' failed";
  Assert.areEqual '5' "${_result}" "countMatchesOfCharsInString '${_text}' failed";
}

function camelCaseToSnakeCase_works_test() {
  local _text="baseFolder";
  camelCaseToSnakeCase "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="base_folder";
  Assert.isTrue ${_rescode} "camelCaseToSnakeCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "camelCaseToSnakeCase '${_text}' failed";

  _text="outputFile";
  camelCaseToSnakeCase "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="output_file";
  Assert.isTrue ${_rescode} "camelCaseToSnakeCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "camelCaseToSnakeCase '${_text}' failed";
}

function camelCaseToPascalCase_works_test() {
  local _text="baseFolder";
  camelCaseToPascalCase "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="BaseFolder";
  Assert.isTrue ${_rescode} "camelCaseToPascalCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "camelCaseToPascalCase '${_text}' failed";

  _text="outputFile";
  camelCaseToPascalCase "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="OutputFile";
  Assert.isTrue ${_rescode} "camelCaseToPascalCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "camelCaseToPascalCase '${_text}' failed";
}

function snakeCaseToCamelCase_works_test() {
  local _text="base_folder";
  snakeCaseToCamelCase "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="baseFolder";
  Assert.isTrue ${_rescode} "snakeCaseToCamelCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "snakeCaseToCamelCase '${_text}' failed";

  _text="output_file";
  snakeCaseToCamelCase "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="outputFile";
  Assert.isTrue ${_rescode} "snakeCaseToCamelCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "snakeCaseToCamelCase '${_text}' failed";
}

function snakeCaseToPascalCase_works_test() {
  local _text="base_folder";
  snakeCaseToPascalCase "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="BaseFolder";
  Assert.isTrue ${_rescode} "snakeCaseToPascalCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "snakeCaseToPascalCase '${_text}' failed";

  _text="output_file";
  snakeCaseToPascalCase "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="OutputFile";
  Assert.isTrue ${_rescode} "snakeCaseToPascalCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "snakeCaseToPascalCase '${_text}' failed";
}

function uncapitalize_works_test() {
  local _text="MyText";
  uncapitalize "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="myText";
  Assert.isTrue ${_rescode} "uncapitalize '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "uncapitalize '${_text}' failed";

  _text="OtherSample";
  uncapitalize "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="otherSample";
  Assert.isTrue ${_rescode} "uncapitalize '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "uncapitalize '${_text}' failed";
}

function capitalize_works_test() {
  local _text="myText";
  capitalize "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="MyText";
  Assert.isTrue ${_rescode} "capitalize '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "capitalize '${_text}' failed";

  _text="otherSample";
  capitalize "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="OtherSample";
  Assert.isTrue ${_rescode} "capitalize '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "capitalize '${_text}' failed";
}

function tailText_works_test() {
  local _text="abcde";
  tailText "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="bcde";
  Assert.isTrue ${_rescode} "tailText '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "tailText '${_text}' failed";
}

function stringLength_works_test() {
  local _text="abc";
  stringLength "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected=3;
  Assert.isTrue ${_rescode} "stringLength '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "stringLength '${_text}' failed";
}

function toCamelCase_works_test() {
  local _text="my_text";
  toCamelCase "${_text}";
  local -i _rescode=$?;
  local _result="${RESULT}";
  local _expected="MyText";
  Assert.isTrue ${_rescode} "toCamelCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "toCamelCase '${_text}' failed";

  _text="other sample";
  toCamelCase "${_text}";
  _rescode=$?;
  _result="${RESULT}";
  _expected="OtherSample";
  Assert.isTrue ${_rescode} "toCamelCase '${_text}' failed";
  Assert.areEqual "${_expected}" "${_result}" "toCamelCase '${_text}' failed";
}
setScriptDescription "Runs all tests implemented for string.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
