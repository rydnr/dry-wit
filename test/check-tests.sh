#!/usr/bin/env dry-wit

DW.import check

function checkNumber_accepts_numeric_test() {
  checkNumber num 42 1
  Assert.isTrue $? "checkNumber failed on numeric"
}

function checkNumber_invalid_fails_test() {
  (checkNumber num abc 1 >/dev/null 2>&1)
  Assert.isFalse $? "checkNumber should fail for non-numeric"
}

function checkBoolean_accepts_valid_values_test() {
  checkBoolean flag TRUE 1
  Assert.isTrue $? "TRUE not accepted"
  checkBoolean flag 0 1
  Assert.isTrue $? "0 not accepted"
}

function checkBoolean_invalid_fails_test() {
  (checkBoolean flag maybe 1 >/dev/null 2>&1)
  Assert.isFalse $? "checkBoolean should fail for invalid"
}

function checkFileExists_detects_existing_test() {
  local file
  file=$(mktemp)
  checkFileExists file "${file}" 1
  local res=$?
  rm -f "${file}"
  Assert.isTrue ${res} "checkFileExists failed for existing file"
}

function checkFileExists_invalid_fails_test() {
  (checkFileExists file /no/such/file 1 >/dev/null 2>&1)
  Assert.isFalse $? "checkFileExists should fail for missing file"
}

setScriptDescription "Runs tests for check.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
