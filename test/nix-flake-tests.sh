#!/usr/bin/env dry-wit
# Copyright 2020-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

DW.import nix-flake

function retrieveLatestStableNixpkgsTag_test() {
  retrieveLatestStableNixpkgsTag
  local _result="${RESULT}"
  Assert.isTrue $? "retrieveLatestStableNixpkgsTag failed"
  Assert.isNotEmpty "${_result}" "retrieveLatestStableNixpkgsTag was silent"
}

setScriptDescription "Runs all tests implemented for nix-flake.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
