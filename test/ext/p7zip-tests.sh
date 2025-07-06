#!/usr/bin/env dry-wit

DW.import p7zip

function p7encrypt_invokes_7za_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/7za" <<EOS
#!/usr/bin/env bash
echo "$@" > "${tmp}/args"
exit 0
EOS
  chmod +x "${tmp}/bin/7za"
  PATH="${tmp}/bin:$PATH"
  p7encrypt "${tmp}/output.7z" secret foo.txt
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "p7encrypt should succeed"
}

function p7encrypt_failure_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/7za" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/bin/7za"
  PATH="${tmp}/bin:$PATH"
  p7encrypt "${tmp}/out.7z" secret foo >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "p7encrypt should fail"
}

setScriptDescription "Runs tests for p7zip.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
