#!/usr/bin/env dry-wit

DW.import gpg

function checkGpgKeyIdKnown_returns_true_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/gpg" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "--list-keys" ]]; then
  echo "ABCDEF"
fi
EOS
  chmod +x "${tmp}/gpg"
  checkGpgKeyIdKnown ABCDEF
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "key should be found"
}

function checkGpgKeyIdKnown_returns_false_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/gpg" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "--list-keys" ]]; then
  echo "ZZZZZZ"
fi
EOS
  chmod +x "${tmp}/gpg"
  checkGpgKeyIdKnown ABCDEF >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "key should not be found"
}

function extractEmailFromGpgKey_parses_email_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/gpg" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "--list-keys" ]]; then
  cat <<EOF2
uid [ultimate] Test User <test@example.com>
EOF2
fi
EOS
  chmod +x "${tmp}/gpg"
  extractEmailFromGpgKey ABCDEF
  local res=$?
  local email="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "extractEmailFromGpgKey failed"
  Assert.areEqual "test@example.com" "${email}" "email mismatch"
}

function extractOwnerNameFromGpgKey_parses_name_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/gpg" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "--list-keys" ]]; then
  cat <<EOF2
uid [ultimate] Test User <test@example.com>
EOF2
fi
EOS
  chmod +x "${tmp}/gpg"
  extractOwnerNameFromGpgKey ABCDEF
  local res=$?
  local name="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "extractOwnerNameFromGpgKey failed"
  Assert.areEqual "Test User" "${name}" "name mismatch"
}

setScriptDescription "Runs tests for gpg.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
