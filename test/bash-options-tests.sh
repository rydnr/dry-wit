#!/usr/bin/env dry-wit

function restoreBashOptions_restores_options_test() {
  local _orig="${-}"
  set +B
  set +C
  restoreBashOptions "${_orig}"
  Assert.areEqual "${_orig}" "${-}" "restoreBashOptions failed to restore options"
}

function enableBraceExpansionOption_sets_option_and_returns_previous_test() {
  set +B
  local _before="${-}"
  enableBraceExpansionOption
  local _prev="${RESULT}"
  Assert.areEqual "${_before}" "${_prev}" "enableBraceExpansionOption RESULT incorrect"
  [[ ${-} == *B* ]]
  Assert.isTrue $? "Brace expansion not enabled"
}

function disableBraceExpansionOption_unsets_option_and_returns_previous_test() {
  set -B
  local _before="${-}"
  disableBraceExpansionOption
  local _prev="${RESULT}"
  Assert.areEqual "${_before}" "${_prev}" "disableBraceExpansionOption RESULT incorrect"
  [[ ${-} != *B* ]]
  Assert.isTrue $? "Brace expansion still enabled"
}

setScriptDescription "Runs tests for bash-options.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
