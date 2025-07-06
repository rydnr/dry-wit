#!/usr/bin/env dry-wit

DW.import rpm

function extractRpm_success_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  PATH="${tmp}/bin:$PATH"
  cat >"${tmp}/bin/rpm2cpio" <<'EOS'
#!/usr/bin/env bash
cat "$1"
EOS
  chmod +x "${tmp}/bin/rpm2cpio"
  cat >"${tmp}/bin/cpio" <<'EOS'
#!/usr/bin/env bash
cat >/dev/null
exit 0
EOS
  chmod +x "${tmp}/bin/cpio"
  local rpmFile
  rpmFile=$(mktemp)
  echo "content" > "${rpmFile}"
  extractRpm "${rpmFile}" "${tmp}"
  local res=$?
  rm -rf "${tmp}" "${rpmFile}"
  Assert.isTrue ${res} "extractRpm should succeed"
}

function extractRpm_failure_sets_error_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  PATH="${tmp}/bin:$PATH"
  cat >"${tmp}/bin/rpm2cpio" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/bin/rpm2cpio"
  cat >"${tmp}/bin/cpio" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/bin/cpio"
  local rpmFile
  rpmFile=$(mktemp)
  echo "content" > "${rpmFile}"
  extractRpm "${rpmFile}" "${tmp}" >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}" "${rpmFile}"
  Assert.isFalse ${res} "extractRpm should fail"
  Assert.isNotEmpty "${ERROR}" "ERROR should be set"
}

setScriptDescription "Runs tests for rpm.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
