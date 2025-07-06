#!/usr/bin/env dry-wit

DW.import step

function set_and_get_step_folder_round_trip_test() {
  local tmp
  tmp=$(mktemp -d)
  setStepStatusFolder "${tmp}"
  getStepStatusFolder
  Assert.areEqual "${tmp}" "${RESULT}" "getStepStatusFolder did not return folder"
  rm -rf "${tmp}"
}

function buildStepFilename_generates_expected_path_test() {
  local tmp
  tmp=$(mktemp -d)
  setStepStatusFolder "${tmp}"
  DW.getScriptName
  local script="$(basename ${RESULT})"
  STEP.buildStepFilename "MY_STEP"
  local expected="${tmp}/.${script}-MY_STEP.done"
  Assert.areEqual "${expected}" "${RESULT}" "STEP.buildStepFilename returned wrong path"
  rm -rf "${tmp}"
}

setScriptDescription "Runs tests for step.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
