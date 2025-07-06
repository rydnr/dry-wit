#!/usr/bin/env dry-wit

DW.import ssh

function remoteSshCommand_success_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/ssh" <<'EOS'
#!/usr/bin/env bash
shift
# remaining args are the remote command
echo "$@"
EOS
  chmod +x "${tmp}/ssh"
  remoteSshCommand user host echo hi
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "remoteSshCommand failed"
  Assert.areEqual "user host echo hi" "${RESULT}" "Output mismatch"
}

function remoteSshCommand_failure_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/ssh" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/ssh"
  remoteSshCommand user host echo hi >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "remoteSshCommand should fail"
  Assert.isNotEmpty "${ERROR}" "ERROR should be set"
}

setScriptDescription "Runs tests for ssh.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
