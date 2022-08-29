#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function retrieveUidFromUser_works_test() {
  DW.import user
  local _expectedUid=$(grep root /etc/passwd | cut -d':' -f 3)
  retrieveUidFromUser "root"
  Assert.isTrue $? "retrieveUidFromUser \"root\" failed"
  local _actualUid=${RESULT}
  Assert.areEqual ${_expectedUid} ${_actualUid} "retrieveUidFromUser \"root\" returned an invalid uid (${_actualUid})"
}

function retrieveGroupFromGid_works_test() {
  DW.import user
  local _gid=$(grep root /etc/group | cut -d':' -f 3)
  if retrieveGroupFromGid "${_gid}"; then
    local _actualGroup=${RESULT}
    Assert.areEqual "root" ${_actualGroup} "retrieveGroupFromGid returned an invalid group (${_actualGroup})"
  else
    Assert.fail "retrieveGroupFromGid failed"
  fi
}

setScriptDescription "Runs all tests implemented for user.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
