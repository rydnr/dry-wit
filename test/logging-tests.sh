#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function log_category_is_printed_while_logging_test() {
  local _result="$(logInfo 'sample log')";
  Assert.isNotEmpty "${_result}" "logInfo 'something' didn't print anything";
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
