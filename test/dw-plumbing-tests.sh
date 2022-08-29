#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function DRYWIT.retrieveSettingsFiles_works_test() {
  local _settingsFiles
  local _f
  local _oldIFS="${IFS}"
  local -a _toDelete=()

  IFS="${DWIFS}"
  DW.getScriptPath
  local _scriptPath="${RESULT}"
  DW.getScriptFolder
  local _scriptFolder="${RESULT}"

  for _f in "$(basename ${_scriptPath} .sh).inc.sh" \
    ".$(basename ${_scriptPath} .sh).inc.sh" \
    "${_scriptFolder}/$(basename ${_scriptPath} .sh).inc.sh" \
    "${_scriptFolder}/.$(basename ${_scriptPath} .sh).inc.sh"; do
    IFS="${_oldIFS}"
    if touch "${_f}" 2>/dev/null; then
      _toDelete+=("${_f}")
    fi
  done
  IFS="${_oldIFS}"
  DRYWIT.retrieveSettingsFiles
  _settingsFiles="${RESULT}"
  if isNotEmpty "${_settingsFiles}"; then
    IFS="${DWIFS}"
    for _f in "$(basename ${_scriptPath} .sh).inc.sh" \
      ".$(basename ${_scriptPath} .sh).inc.sh" \
      "${_scriptFolder}/$(basename ${_scriptPath} .sh).inc.sh" \
      "${_scriptFolder}/.$(basename ${_scriptPath} .sh).inc.sh"; do
      IFS="${_oldIFS}"
      retrieveAbsolutePath "${_f}"
      Assert.contains "${_settingsFiles}" "${RESULT}" "Unexpected settings files"
    done
    IFS="${DWIFS}"
    for _f in _toDelete; do
      retrieveAbsolutePath "${_f}"
      if ! rm -f "${RESULT}" 2>/dev/null; then
        echo "Could not remove ${RESULT}"
      fi
    done
    IFS="${_oldIFS}"
  fi
}

function cleanup_deletes_temporary_files_test() {
  createTempFile
  local _tempFile="${RESULT}"

  touch "${_tempFile}"
  cleanup
  fileExists "${_tempFile}"
  local -i _fileExists=$?

  Assert.isFalse ${_fileExists} "Temporary file ${_tempFile} was not cleaned up when calling cleanup"
}

function DRYWIT.checkReq_label_is_optional_test() {
  DW.import array
  DRYWIT.addMissingDependencyError foobar
  normalizeUppercase "${_req}_NOT_INSTALLED"
  arrayContains "${__DW_ERROR_MESSAGES[@]}" "${RESULT}"
  Assert.isTrue $? "DEPENDENCY_NOT_INSTALLED error message not generated automatically"
}

setScriptDescription "Runs all tests implemented for dw-plumbing.dw"
addError PARSEINTPUT_DOES_NOT_SUPPORT_SMALL_H "parseInput does not support -h"
addError DEPENDENCY_NOT_INSTALLED_ERROR_MESSAGE_NOT_GENERATED_AUTOMATICALLY "DEPENDENCY_NOT_INSTALLED error message not generated automatically"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
