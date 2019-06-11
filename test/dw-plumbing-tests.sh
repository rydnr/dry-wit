#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

## Tests for dry-wit's DRYWIT.
function DRYWIT.parseCommonInput_test() {

  DRYWIT.parseCommonInput "-h";
  Assert.noErrorThrown PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H;
}

function DRYWIT.retrieveSettingsFiles_test() {
  local _settingsFiles;
  local _f;

  import dw-plumbing;

  DRYWIT.retrieveSettingsFiles;
  _settingsFiles="${RESULT}";
  if isNotEmpty "${_settingsFiles}"; then
    for _f in "${DRY_WIT_SCRIPT_FOLDER}/$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "${DRY_WIT_SCRIPT_FOLDER}/.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh" \
              "./.$(basename ${DRY_WIT_SCRIPT_PATH} .sh).inc.sh"; do
      Assert.contains "${_settingsFiles}" "${_f}" "Unexpected settings files";
    done
  fi
}

setScriptDescription "Runs all tests implemented for dw-plumbing.dw.";
