#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function test_reset() {
  setDebugEchoEnabled FALSE;
}

## Called before each test.
function test_setup() {
  test_reset;

  TEST_REPO_DIR="$(mktemp -d /tmp/dry-wit-git-local.XXXXXX)";
  TEST_REMOTE_DIR="$(mktemp -d /tmp/dry-wit-git-remote.XXXXXX)";

  command git init --quiet --bare "${TEST_REMOTE_DIR}/remote.git";
  command git init --quiet -b master "${TEST_REPO_DIR}/repo";
  command git -C "${TEST_REPO_DIR}/repo" config user.name "dry-wit tests";
  command git -C "${TEST_REPO_DIR}/repo" config user.email "dry-wit-tests@example.invalid";
  command printf 'dry-wit test fixture\n' > "${TEST_REPO_DIR}/repo/README";
  command git -C "${TEST_REPO_DIR}/repo" add README;
  command git -C "${TEST_REPO_DIR}/repo" commit --quiet -m "Initial commit";
  command git -C "${TEST_REPO_DIR}/repo" remote add origin "${TEST_REMOTE_DIR}/remote.git";
  command git -C "${TEST_REPO_DIR}/repo" push --quiet -u origin master;
}

## Called after each test.
function test_tearDown() {
  command rm -rf "${TEST_REPO_DIR}" "${TEST_REMOTE_DIR}";
  test_reset;
}

DW.import git;

function retrieveRemoteHead_works_for_drywit_test() {
  local -i rescode;
  local _result;
  retrieveRemoteHead "${TEST_REPO_DIR}/repo" master;
  _rescode=$?;
  _result="${RESULT}";
  Assert.isTrue ${_rescode} "retrieveRemoteHead ${TEST_REPO_DIR}/repo master failed";
  Assert.isNotEmpty "${_result}" "'retrieveRemoteHead ${TEST_REPO_DIR}/repo master' returned nothing";
}

function retrieveRemoteHeadFromURL_works_for_drywit_test() {
  local -i rescode;
  local _result;
  retrieveRemoteHeadFromURL "${TEST_REMOTE_DIR}/remote.git" master;
  _rescode=$?;
  _result="${RESULT}";
  Assert.isTrue ${_rescode} "'retrieveRemoteHeadFromURL ${TEST_REMOTE_DIR}/remote.git master' failed";
  Assert.isNotEmpty "${_result}" "'retrieveRemoteHeadFromURL ${TEST_REMOTE_DIR}/remote.git master' returned nothing";
}

setScriptDescription "Runs all tests implemented for git.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
