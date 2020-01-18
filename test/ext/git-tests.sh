#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function test_reset() {
  setDebugEchoEnabled FALSE;
}

## Called before each test.
function test_setup() {
  test_reset;
}

## Called after each test.
function test_tearDown() {
  test_reset;
}

DW.import git;

function retrieveRemoteHead_works_for_drywit_test() {
  local -i rescode;
  local _result;
  retrieveRemoteHead ${PWD} master;
  _rescode=$?;
  _result="${RESULT}";
  Assert.isTrue ${_rescode} "retrieveRemoteHead . master failed";
  Assert.isNotEmpty "${_result}" "'retrieveRemoteHead . master' returned nothing";
}

function retrieveRemoteHeadFromURL_works_for_drywit_test() {
  local -i rescode;
  local _result;
  retrieveRemoteHeadFromURL https://github.com/rydnr/dry-wit master;
  _rescode=$?;
  _result="${RESULT}";
  Assert.isTrue ${_rescode} "'retrieveRemoteHeadFromURL https://github.com/rydnr/dry-wit master' failed";
  Assert.isNotEmpty "${_result}" "'retrieveRemoteHeadFromURL https://github.com/rydnr/dry-wit master' returned nothing";
}

setScriptDescription "Runs all tests implemented for git.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
