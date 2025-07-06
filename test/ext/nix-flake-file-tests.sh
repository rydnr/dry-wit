#!/usr/bin/env dry-wit

DW.import nix-flake

function extract_fields_from_flake_nix_test() {
  createTempFile
  local file="${RESULT}"
  cat >"${file}" <<'EOS'
{
  outputs = { self, nixpkgs }: {
    org = "acme";
    repo = "demo";
    version = "0.1.0";
    sha256 = "sha256-AAAA";
  };
}
EOS
  extractOrgFromFlakeNix "${file}"
  local org="${RESULT}"
  extractRepoFromFlakeNix "${file}"
  local repo="${RESULT}"
  extractVersionFromFlakeNix "${file}"
  local ver="${RESULT}"
  rm -f "${file}"
  Assert.areEqual "acme" "${org}" "org mismatch"
  Assert.areEqual "demo" "${repo}" "repo mismatch"
  Assert.areEqual "0.1.0" "${ver}" "version mismatch"
}

function update_fields_in_flake_nix_test() {
  createTempFile
  local file="${RESULT}"
  cat >"${file}" <<'EOS'
{
  version = "0.1.0";
  sha256 = "sha256-AAAA";
}
EOS
  updateVersionInFlakeNix "${file}" "0.2.0"
  local vres=$?
  updateSha256InFlakeNix "${file}" "sha256-BBBB"
  local sres=$?
  local version_line sha_line
  version_line="$(grep '^  version' "${file}" | tr -d ' ')"
  sha_line="$(grep '^  sha256' "${file}" | tr -d ' ')"
  rm -f "${file}"
  Assert.isTrue ${vres} "updateVersionInFlakeNix failed"
  Assert.isTrue ${sres} "updateSha256InFlakeNix failed"
  Assert.areEqual 'version="0.2.0";' "${version_line}" "version not updated"
  Assert.areEqual 'sha256="sha256-BBBB";' "${sha_line}" "sha256 not updated"
}

setScriptDescription "Runs flake file parsing tests"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
