#!/usr/bin/env dry-wit

DW.import vault

function buildPipelineParameterPathInVault_formats_path_test() {
  buildPipelineParameterPathInVault "/concourse" main default src-branch
  local res=$?
  Assert.isTrue ${res} "buildPipelineParameterPathInVault failed"
  Assert.areEqual "concourse/main/default/src-branch" "${RESULT}" "path incorrect"
}

setScriptDescription "Runs tests for vault.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
