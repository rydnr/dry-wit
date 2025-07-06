#!/usr/bin/env dry-wit

DW.import keytool

function convertKeystoreTo_invokes_keytool_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/keytool" <<EOS
#!/usr/bin/env bash
echo "$@" > "${tmp}/args"
exit 0
EOS
  chmod +x "${tmp}/bin/keytool"
  PATH="${tmp}/bin:$PATH"
  convertKeystoreTo "${tmp}/src.jks" secret "${tmp}/dest.p12" pkcs12
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "convertKeystoreTo should succeed"
}

function convertKeystoreTo_failure_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/keytool" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/bin/keytool"
  PATH="${tmp}/bin:$PATH"
  convertKeystoreTo "${tmp}/src.jks" secret "${tmp}/dest.p12" pkcs12 >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "convertKeystoreTo should fail"
}

setScriptDescription "Runs tests for keytool.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
