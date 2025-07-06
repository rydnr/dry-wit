#!/usr/bin/env dry-wit

DW.import curl

function curlGet_success_sets_result_and_status_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/curl" <<'EOS'
#!/usr/bin/env bash
echo "body"
echo "200"
EOS
  chmod +x "${tmp}/curl"
  curlGet http://example.com
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "curlGet should succeed"
  Assert.areEqual "body" "${RESULT}" "Unexpected result"
  Assert.areEqual "200" "${STATUS}" "Unexpected status"
}

function curlGet_failure_sets_error_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/curl" <<'EOS'
#!/usr/bin/env bash
echo "curl failed" >&2
exit 1
EOS
  chmod +x "${tmp}/curl"
  curlGet http://bad.url >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "curlGet should fail"
  Assert.isNotEmpty "${ERROR}" "ERROR should be set"
}

function curlDownload_success_writes_file_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/curl" <<'EOS'
#!/usr/bin/env bash
while [[ $1 == -* ]]; do shift; done
echo "data" > "$1"
EOS
  chmod +x "${tmp}/curl"
  local file
  file=$(mktemp)
  curlDownload http://example.com "${file}"
  local res=$?
  local content
  content="$(cat "${file}")"
  rm -rf "${tmp}" "${file}"
  Assert.isTrue ${res} "curlDownload should succeed"
  Assert.areEqual "data" "${content}" "File content mismatch"
}

function curlDownload_failure_sets_error_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/curl" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/curl"
  local file
  file=$(mktemp)
  curlDownload http://example.com "${file}" >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}" "${file}"
  Assert.isFalse ${res} "curlDownload should fail"
  Assert.isNotEmpty "${ERROR}" "ERROR should be set"
}

setScriptDescription "Runs tests for curl.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
