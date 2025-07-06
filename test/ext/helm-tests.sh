#!/usr/bin/env dry-wit

DW.import helm

function helmInstallOrUpgrade_success_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/helm" <<'EOS'
#!/usr/bin/env bash
echo ok
EOS
  chmod +x "${tmp}/helm"
  HELM.helmInstallOrUpgrade install myrel chart values.yaml
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "HELM.helmInstallOrUpgrade should succeed"
}

function helmInstallOrUpgrade_failure_sets_error_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/helm" <<'EOS'
#!/usr/bin/env bash
exit 1
EOS
  chmod +x "${tmp}/helm"
  HELM.helmInstallOrUpgrade install myrel chart values.yaml >/dev/null 2>&1
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "HELM.helmInstallOrUpgrade should fail"
}

function helmUninstall_runs_helm_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/helm" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == "uninstall" ]]; then
  echo "removed $2"
else
  exit 1
fi
EOS
  chmod +x "${tmp}/helm"
  helmUninstall myrel
  local res=$?
  local out="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "helmUninstall failed"
  Assert.areEqual "removed myrel" "${out}" "unexpected uninstall output"
}

setScriptDescription "Runs tests for helm.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
