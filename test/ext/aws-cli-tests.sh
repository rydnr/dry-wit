#!/usr/bin/env dry-wit

DW.import aws-cli

function retrieveAwsCli_returns_path_test() {
  local tmp
  tmp=$(mktemp -d)
  PATH="${tmp}:$PATH"
  cat >"${tmp}/aws" <<'EOS'
#!/usr/bin/env bash
echo /usr/bin/aws
EOS
  chmod +x "${tmp}/aws"
  retrieveAwsCliFromProfileAndRegion prof us-west-1
  local res=$?
  local expected="${tmp}/aws --profile prof --region us-west-1"
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveAwsCliFromProfileAndRegion failed"
  Assert.areEqual "${expected}" "${RESULT}" "unexpected cli path"
}

function retrieveAwsRegionForProfile_parses_config_test() {
  local tmp
  tmp=$(mktemp -d)
  HOME="${tmp}"
  mkdir -p "${HOME}/.aws"
  cat >"${HOME}/.aws/config" <<'EOS'
[profile prof]
region = eu-central-1
EOS
  retrieveAwsRegionForProfile prof
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveAwsRegionForProfile failed"
  Assert.areEqual "eu-central-1" "${RESULT}" "wrong region"
}

function retrieveAwsAccessKeyIdForProfile_reads_creds_test() {
  local tmp
  tmp=$(mktemp -d)
  HOME="${tmp}"
  mkdir -p "${HOME}/.aws"
  cat >"${HOME}/.aws/credentials" <<'EOS'
[prof]
aws_access_key_id = KEYID
aws_secret_access_key = SECRET
EOS
  retrieveAwsAccessKeyIdForProfile prof
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveAwsAccessKeyIdForProfile failed"
  Assert.areEqual "KEYID" "${RESULT}" "wrong key id"
}

function retrieveAwsSecretAccessKeyForProfile_reads_creds_test() {
  local tmp
  tmp=$(mktemp -d)
  HOME="${tmp}"
  mkdir -p "${HOME}/.aws"
  cat >"${HOME}/.aws/credentials" <<'EOS'
[prof]
aws_access_key_id = KEYID
aws_secret_access_key = SECRET
EOS
  retrieveAwsSecretAccessKeyForProfile prof
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "retrieveAwsSecretAccessKeyForProfile failed"
  Assert.areEqual "SECRET" "${RESULT}" "wrong secret"
}

function awsProfileExists_checks_files_test() {
  local tmp
  tmp=$(mktemp -d)
  HOME="${tmp}"
  mkdir -p "${HOME}/.aws"
  cat >"${HOME}/.aws/config" <<'EOS'
[profile prof]
region = us-west-2
EOS
  cat >"${HOME}/.aws/credentials" <<'EOS'
[prof]
aws_access_key_id = KEY
aws_secret_access_key = SECRET
EOS
  awsProfileExists prof
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "awsProfileExists should succeed"
}

function awsProfileExists_returns_false_when_missing_test() {
  local tmp
  tmp=$(mktemp -d)
  HOME="${tmp}"
  mkdir -p "${HOME}/.aws"
  cat >"${HOME}/.aws/config" <<'EOS'
[profile other]
region = us-west-2
EOS
  cat >"${HOME}/.aws/credentials" <<'EOS'
[other]
aws_access_key_id = KEY
aws_secret_access_key = SECRET
EOS
  awsProfileExists prof
  local res=$?
  rm -rf "${tmp}"
  Assert.isFalse ${res} "awsProfileExists should fail for missing profile"
}

setScriptDescription "Runs tests for aws-cli.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
