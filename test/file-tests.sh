#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function replaceVariablesInFile_works_test() {
  local _sourceFile;
  local _processedFile;
  local _expected;
  local _actual;
  local _date="$(date '+%Y%m%d')";

  createTempFile;
  _sourceFile="${RESULT}";
  createTempFile;
  _processedFile="${RESULT}";

  cat <<EOF > "${_sourceFile}"
Hello \${NAME}!
(\${DATE})

EOF

  if replaceVariablesInFile "${_sourceFile}" "${_processedFile}" "NAME=John" "DATE=today"; then
    read -r -d '' _expected <<EOF
Hello John!
(today)

EOF
    _actual=$(cat "${_processedFile}");
    Assert.areEqual "${_expected}" "${_actual}" "replaceVariableInFile failed";
  else
    Assert.fail "replaceVariableInFile failed";
  fi

  if replaceVariablesInFile "${_sourceFile}" "${_processedFile}" "NAME=Mary" "DATE=${_date}"; then
    read -r -d '' _expected <<EOF
Hello Mary!
(${_date})

EOF
    _actual=$(cat "${_processedFile}");
    Assert.areEqual "${_expected}" "${_actual}" "replaceVariableInFile failed";
  else
    Assert.fail "replaceVariableInFile failed";
  fi

  if replaceVariablesInFile "${_sourceFile}" "${_processedFile}" 'NAME="Name with spaces"' "DATE=\"${_date} AC\""; then
    read -r -d '' _expected <<EOF
Hello Name with spaces!
(${_date} AC)

EOF
    _actual=$(cat "${_processedFile}");
    Assert.areEqual "${_expected}" "${_actual}" "replaceVariableInFile failed";
  else
    Assert.fail "replaceVariableInFile failed";
  fi
}

setScriptDescription "Runs all tests implemented for file.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
