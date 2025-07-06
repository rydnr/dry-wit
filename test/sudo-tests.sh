#!/usr/bin/env dry-wit

DW.import sudo

function checkPasswordlessSudo_succeeds_when_sudo_ok_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/sudo" <<'EOS'
#!/usr/bin/env bash
exit 0
EOS
  chmod +x "${tmp}/sudo"
  checkPasswordlessSudo
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "checkPasswordlessSudo should succeed"
}

function checkPasswordlessSudo_fails_when_sudo_fails_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/sudo" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/sudo"
  checkPasswordlessSudo >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "checkPasswordlessSudo should fail"
}

setScriptDescription "Runs tests for sudo.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
