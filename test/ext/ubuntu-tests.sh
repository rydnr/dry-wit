#!/usr/bin/env dry-wit

DW.import ubuntu

function retrieveVersion_parses_output_test() {
  local tmp
  tmp=$(mktemp -d)
  mkdir "${tmp}/bin"
  cat >"${tmp}/bin/dpkg" <<'EOS'
#!/usr/bin/env bash
if [[ $1 == -p ]]; then
  cat <<EOT
Package: foo
Version: 1.2.3
EOT
else
  exit 1
fi
EOS
  chmod +x "${tmp}/bin/dpkg"
  PATH="${tmp}/bin:$PATH" retrieveVersion foo
  local res=$?
  local ver="${RESULT}"
  rm -rf "${tmp}"
  Assert.isTrue ${res} 'retrieveVersion failed'
  Assert.areEqual '1.2.3' "${ver}" 'wrong version'
}

setScriptDescription "Runs tests for ubuntu.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
