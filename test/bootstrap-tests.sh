#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function trace_logging_does_not_apply_to_bootstrap_module_test() {
  setTraceEnabled;
  BOOTSTRAP.isTraceEnabled;
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "BOOTSTRAP.isTraceEnabled uses setTraceEnabled to determine if tracing is enabled";
}

function trace_logging_honors_dw_vv_flag_test() {
  BASH_ARGV="-DW:vv";
  BOOTSTRAP.isTraceEnabled;
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "BOOTSTRAP.isTraceEnabled honors -DW:vv to determine if tracing is enabled";
}

setScriptDescription "Runs all tests implemented for dry-wit (bootstrap)";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
