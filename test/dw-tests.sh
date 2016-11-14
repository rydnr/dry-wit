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
v
## Defines the errors.
## dry-wit hook
function defineErrors() {
  addError PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H "The _parseCommonInput method does not support -h";
  addError RETRIEVEUIDFROMUSER_CANNOT_RETRIEVE_ROOT_UID "retrieveUidFromUser \"root\" failed";
  addError RETRIEVEUIDFROMUSER_FAILED_FOR_USER_ROOT "retrieveUidFromUser \"root\" returned an invalid uid";
  addError RETRIEVEGROUPFROMGID_DOES_NOT_CHECK_INPUT_PARAMETERS "retrieveGroupFromGid does not check input parameters";
  addError RETRIEVEGROUPFROMGID_FAILED_FOR_GROUP_ROOT "retrieveGroupFromGid returned an invalid gid for group root";
}

## Tests for dry-wit's _parseCommonInput.
function _parseCommonInput_test() {

  _parseCommonInput "-h";
  assertNoErrorThrown PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H;
}

function retrieveUidFromUser_test() {
  local _expectedUid=$(grep root /etc/passwd | cut -d':' -f 3);
  retrieveUidFromUser "root";
  assertTrue $? RETRIEVEUIDFROMUSER_CANNOT_RETRIEVE_ROOT_UID;
  local _actualUid=${RESULT};
  assertEquals ${_expectedUid} ${_actualUid} RETRIEVEUIDFROMUSER_FAILED_FOR_USER_ROOT;
}

function retrieveGroupFromGid_test() {
  local _gid=$(grep root /etc/group | cut -d':' -f 3);
  retrieveGroupFromGid;
  assertErrorThrown RETRIEVEGROUPFROMGID_DOES_NOT_CHECK_INPUT_PARAMETERS;
  retrieveGroupFromGid "${_gid}";
  assertTrue $? RETRIEVEGROUPFROMGID_CANNOT_RETRIEVE_ROOT_GID;
  local _actualGroup=${RESULT};
  assertEquals "root" ${_actualGroup} RETRIEVEGROUPFROMGID_FAILED_FOR_GROUP_ROOT;
}

function _retrieveSettingsFiles_test() {
  local _settingsFiles;
  _retrieveSettingsFiles;
  _settingsFiles="${RESULT}";
  for _f in "${DRY_WIT_SCRIPT_FOLDER}/$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
                "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
                "${DRY_WIT_SCRIPT_FOLDER}/.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
                "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh"; do
    assertContains "${_settingsFiles}" "${_f}" "unexpected settings files";
  done
}
