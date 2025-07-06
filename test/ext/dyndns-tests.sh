#!/usr/bin/env dry-wit

DW.import dyndns

function checkIp_parses_html_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/curl" <<'EOS'
#!/usr/bin/env bash
printf '<html><head><title>Current IP Check</title></head><body>Current IP Address: 10.2.3.4</body></html>'
EOS
  chmod +x "${tmp}/bin/curl"
  PATH="${tmp}/bin:$PATH" checkIp
  local res=$?
  local ip="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "checkIp should succeed"
  Assert.areEqual "10.2.3.4" "${ip}" "Wrong IP"
}

function checkIp_error_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/curl" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/bin/curl"
  PATH="${tmp}/bin:$PATH" checkIp >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "checkIp should fail"
}

setScriptDescription "Runs tests for dyndns.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
