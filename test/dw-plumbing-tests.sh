#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function DRYWIT.retrieveSettingsFiles_test() {
  local _settingsFiles;
  local _f;
  local _oldIFS="${IFS}";
  local -a _toDelete=();

  DW.import dw-plumbing;

  IFS="${DWIFS}";
  for _f in "$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
            ".$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
            "${DRY_WIT_SCRIPT_FOLDER}/$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
            "${DRY_WIT_SCRIP_FOLDER}/.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh"; do
      IFS="${_oldIFS}";
      if touch "${_f}" 2> /dev/null; then
          _toDelete+=("${_f}");
      fi
  done
  IFS="${_oldIFS}";
  DRYWIT.retrieveSettingsFiles;
  _settingsFiles="${RESULT}";
  if isNotEmpty "${_settingsFiles}"; then
    IFS="${DWIFS}";
    for _f in "$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              ".$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "${DRY_WIT_SCRIPT_FOLDER}/$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "${DRY_WIT_SCRIP_FOLDER}/.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh"; do
      IFS="${_oldIFS}";
      retrieveAbsolutePath "${_f}";
      Assert.contains "${_settingsFiles}" "${RESULT}" "Unexpected settings files";
    done
    IFS="${DWIFS}";
    for _f in _toDelete; do
        retrieveAbsolutePath "${_f}";
        if ! rm -f "${RESULT}" 2> /dev/null; then
            echo "Could not remove ${RESULT}";
        fi
    done
    IFS="${_oldIFS}";
  fi
}

setScriptDescription "Runs all tests implemented for dw-plumbing.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
