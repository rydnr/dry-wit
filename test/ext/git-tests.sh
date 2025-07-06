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
}

## Called after each test.
function test_tearDown() {
  test_reset;
}

DW.import git;

function retrieveRemoteHead_works_for_drywit_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/git" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "-C" ]]; then shift 2; fi
if [[ $1 == "ls-remote" ]]; then
  echo "abcdef refs/remotes/origin/master"
else
  exit 1
fi
EOS
  chmod +x "${tmp}/git"
  retrieveRemoteHead "${PWD}" master
  local res=$?
  local result="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveRemoteHead . master failed"
  Assert.areEqual "abcdef" "${result}" "Unexpected hash"
}

function retrieveRemoteHeadFromURL_works_for_drywit_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/git" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "ls-remote" ]]; then
  printf '123456\trefs/heads/master\n'
else
  exit 1
fi
EOS
  chmod +x "${tmp}/git"
  retrieveRemoteHeadFromURL https://example.com master
  local res=$?
  local result="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveRemoteHeadFromURL failed"
  Assert.areEqual "123456" "${result}" "Unexpected hash"
}

setScriptDescription "Runs all tests implemented for git.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
