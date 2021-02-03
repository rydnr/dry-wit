#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function isZero_works_test() {
  isZero 0;
  Assert.isTrue $? "isZero 0 failed";

  isZero 1;
  Assert.isFalse $? "isZero 1 failed";

  isZero "0";
  Assert.isTrue $? "isZero '0' failed";

  isZero "1";
  Assert.isFalse $? "isZero '1' failed";

  isZero "a";
  Assert.isFalse $? "isZero 'a' failed";
}

function isEmpty_works_test() {
  isEmpty "";
  Assert.isTrue $? "isEmpty '' failed";

  isEmpty "a";
  Assert.isFalse $? "isEmpty 'a' failed";

  isEmpty 0;
  Assert.isFalse $? "isEmpty 0 failed";
}

function isTrue_works_test() {
  isTrue 0;
  Assert.isTrue $? "isTrue 0 failed";

  isTrue 1;
  Assert.isFalse $? "isTrue 1 failed";
}

function isFalse_works_test() {
  isFalse 1;
  Assert.isTrue $? "isFalse 1 failed";

  isFalse 0;
  Assert.isFalse $? "isFalse 0 failed";
}

function areEqual_works_test() {
  areEqual "a" "a";
  Assert.isTrue $? "areEqual 'a' 'a' failed";

  areEqual "a" "b";
  Assert.isFalse $? "areEqual 'a' 'b' failed";
}

function areNotEqual_works_test() {
  areNotEqual "a" "b";
  Assert.isTrue $? "areNotEqual 'a' 'b' failed";

  areNotEqual "a" "a";
  Assert.isFalse $? "areNotEqual 'a' 'a' failed";
}

function isFunctionDefined_works_test() {
  isFunctionDefined "isFunctionDefined_works_test";
  Assert.isTrue $? "isFunctionDefined 'isFunctionDefined_works_test' failed";
}

setScriptDescription "Runs all tests implemented for stdlib.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
