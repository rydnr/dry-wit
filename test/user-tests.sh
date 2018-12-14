#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function retrieveUidFromUser_test() {
  import user;
  local _expectedUid=$(grep root /etc/passwd | cut -d':' -f 3);
  retrieveUidFromUser "root";
  Assert.isTrue $? "retrieveUidFromUser \"root\" failed";
  local _actualUid=${RESULT};
  Assert.areEqual ${_expectedUid} ${_actualUid} "retrieveUidFromUser \"root\" returned an invalid uid (${_actualUid})";
}

function retrieveGroupFromGid_test() {
  import user;
  local _gid=$(grep root /etc/group | cut -d':' -f 3);
  retrieveGroupFromGid "${_gid}";
  Assert.isTrue $? "retrieveGroupFromGid failed";
  local _actualGroup=${RESULT};
  Assert.areEqual "root" ${_actualGroup} "retrieveGroupFromGid returned an invalid group (${_actualGroup})";
}

setScriptDescription "Runs all tests implemented for user.dw."
