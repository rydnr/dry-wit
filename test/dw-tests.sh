#!/bin/bash ../src/dry-wit-test
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2016-today ACM-SL
    Distributed this under the GNU General Public License v3.

Runs all tests implemented for dry-wit itself.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Tests for dry-wit's _parseCommonInput.
function _parseCommonInput_test() {

  _parseCommonInput "-h";
  Assert.noErrorThrown PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H;
}

function retrieveUidFromUser_test() {
  local _expectedUid=$(grep root /etc/passwd | cut -d':' -f 3);
  retrieveUidFromUser "root";
  Assert.isTrue $? "retrieveUidFromUser \"root\" failed";
  local _actualUid=${RESULT};
  Assert.areEqual ${_expectedUid} ${_actualUid} "retrieveUidFromUser \"root\" returned an invalid uid (${_actualUid})";
}

function retrieveGroupFromGid_test() {
  local _gid=$(grep root /etc/group | cut -d':' -f 3);
  retrieveGroupFromGid "${_gid}";
  Assert.isTrue $? "retrieveGroupFromGid failed";
  local _actualGroup=${RESULT};
  Assert.areEqual "root" ${_actualGroup} "retrieveGroupFromGid returned an invalid group (${_actualGroup})";
}

function _retrieveSettingsFiles_test() {
  local _settingsFiles;
  local _f;

  _retrieveSettingsFiles;
  _settingsFiles="${RESULT}";
  if isNotEmpty "${_settingsFiles}"; then
    for _f in "${DRY_WIT_SCRIPT_FOLDER}/$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "${DRY_WIT_SCRIPT_FOLDER}/.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh"; do
      Assert.contains "${_settingsFiles}" "${_f}" "Unexpected settings files";
    done
  fi
}

function contains_test() {
  String.contains "abc" "b";
  Assert.isTrue $? "contains 'abc' 'b' failed";

  String.contains "abc" "f";
  Assert.isFalse $? "contains 'abc' 'f' failed";
}

function String.startsWith_test() {
  String.startsWith "abc" "a";
  Assert.isTrue $? "startsWith 'abc' 'a' failed";

  String.startsWith "abc" "b";
  Assert.isFalse $? "startsWith 'abc' 'b' failed";
}

function String.endsWith_test() {
  String.endsWith "abc" "c";
  Assert.isTrue $? "endsWith 'abc' 'a' failed";

  String.endsWith "abc" "b";
  Assert.isFalse $? "endsWith 'abc' 'b' failed";
}
