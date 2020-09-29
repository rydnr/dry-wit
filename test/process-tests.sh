#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function processAlreadyRunning_works_test() {
  anotherProcessAlreadyRunning;
  Assert.isFalse $? "anotherProcessAlreadyRunning failed";
}

setScriptDescription "Runs all tests implemented for process.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
