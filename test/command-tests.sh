#!/usr/bin/env dry-wit
# Copyright 2020-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function runCommand_works_test() {
  runCommand "ls";
  local _result="${RESULT}";
  Assert.isTrue $? "runCommand 'ls' failed";
  Assert.isNotEmpty "${_result}" "runCommand 'ls' was silent";
}

function runCommandAsUidGid_works_test() {
  local _uid="$(id -u)";
  local _gid="$(id -g)";
  runCommandAsUidGid ${_uid} ${_gid} "${PWD}" "ls";
  local _result="${RESULT}";
  Assert.isTrue $? "runCommandAsUidGid 'ls' was silent";
}
setScriptDescription "Runs all tests implemented for command.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
