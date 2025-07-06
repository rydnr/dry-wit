#!/usr/bin/env dry-wit

DW.import trap

function customHook_calls_custom_function_test() {
  function customUSR1Hook() { return 0; }
  TRAP.customHook USR1
  local res=$?
  unset -f customUSR1Hook
  Assert.isTrue ${res} "custom hook should return success"
}

function customHook_failure_propagates_test() {
  function customUSR2Hook() { return 1; }
  TRAP.customHook USR2 >/dev/null 2>&1
  local res=$?
  unset -f customUSR2Hook
  Assert.isFalse ${res} "custom hook failure not propagated"
}

function customHook_no_hook_returns_success_test() {
  TRAP.customHook TERM
  Assert.isTrue $? "Should succeed when no custom hook"
}

setScriptDescription "Runs tests for trap.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
