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

function debug_logging_does_not_apply_to_bootstrap_module_test() {
  setDebugEnabled;
  BOOTSTRAP.isDebugEnabled;
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "BOOTSTRAP.isDebugEnabled uses setDebugEnabled to determine if tracing is enabled";
}

function debug_logging_honors_dw_v_flag_test() {
  BASH_ARGV="-DW:v";
  BOOTSTRAP.isDebugEnabled;
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "BOOTSTRAP.isDebugEnabled honors -DW:v to determine if tracing is enabled";
}

function xtrace_logging_honors_dw_xv_flag_test() {
  BASH_ARGV="-DW:xv";
  BOOTSTRAP.isXtraceEnabled;
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "BOOTSTRAP.isDebugEnabled honors -DW:xv to determine if xtracing is enabled";
}

setScriptDescription "Runs all tests implemented for dry-wit (bootstrap)";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
