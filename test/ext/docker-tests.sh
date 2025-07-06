#!/usr/bin/env dry-wit

DW.import docker

function dockerCommand_success_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/docker" <<'EOS'
#!/usr/bin/env bash
echo ok
EOS
  chmod +x "${tmp}/docker"
  dockerCommand ps
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "dockerCommand should succeed"
}

function dockerCommand_failure_sets_error_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/docker" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/docker"
  dockerCommand ps >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "dockerCommand should fail"
  Assert.isNotEmpty "${ERROR}" "ERROR should be set"
}

function retrievePortsFromDockerfile_parses_ports_test() {
  createTempFile
  local file="${RESULT}"
  cat >"${file}" <<'EOS'
FROM busybox
EXPOSE 80
EXPOSE 8080 443
EOS
  retrievePortsFromDockerfile "${file}"
  local res=$?
  rm -f "${file}"
  Assert.isTrue ${res} "retrievePortsFromDockerfile failed"
  Assert.areEqual "80 8080 443" "${RESULT}" "Ports mismatch"
}

function dockerContainerExists_returns_id_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/docker" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == 'ps' ]]; then
  echo 'abc123'
else
  exit 1
fi
EOS
  chmod +x "${tmp}/docker"
  dockerContainerExists mycontainer
  local res=$?
  local id="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "dockerContainerExists should succeed"
  Assert.areEqual "abc123" "${id}" "Unexpected id"
}

setScriptDescription "Runs tests for docker.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
