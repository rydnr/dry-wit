#!/bin/bash dry-wit
# Copyright 2009 Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] [-d|--dry-run} folder
$SCRIPT_NAME [-h|--help]
(c) 2010 Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Creates a trivial report on the media files in given folder tree.

Where:
  * folder: The base folder.
  * -d|--dry-run: Does not do anything. Just tells what it'd do.
EOF
}

# Requirements
function checkRequirements() {
  checkReq find FIND_NOT_INSTALLED;
  checkReq wc WC_NOT_INSTALLED;
}

# Environment
function defineEnv() {
  export MEDIA_FILE_EXTENSIONS_DEFAULT="avi mpg mpeg wmv";
  export MEDIA_FILE_EXTENSIONS_DESCRIPTION="The extensions for media files";
  if    [ "${MEDIA_FILE_EXTENSIONS+1}" != "1" ] \
     || [ "x${MEDIA_FILE_EXTENSIONS}" == "x" ]; then
    export MEDIA_FILE_EXTENSIONS="${MEDIA_FILE_EXTENSIONS_DEFAULT}";
  fi

  export REPORT_FILE_DEFAULT="list.txt";
  export REPORT_FILE_DESCRIPTION="The file containing the media files in given folder";
  if    [ "${REPORT_FILE+1}" != "1" ] \
     || [ "x${REPORT_FILE}" == "x" ]; then
    export REPORT_FILE="${REPORT_FILE_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    MEDIA_FILE_EXTENSIONS \
    REPORT_FILE \
  );

  export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export FIND_NOT_INSTALLED="find not installed";
  export WC_NOT_INSTALLED="wc not installed";
  export INPUT_FOLDER_DOES_NOT_EXIST="input-folder does not exist";
  export CANNOT_ACCESS_INPUT_FOLDER="Cannot access input-folder";
  export REPORT_FILE_IS_NOT_WRITABLE="report-file is not writable";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    FIND_NOT_INSTALLED \
    WC_NOT_INSTALLED \
    INPUT_FOLDER_DOES_NOT_EXIST \
    CANNOT_ACCESS_INPUT_FOLDER \
    REPORT_FILE_IS_NOT_WRITABLE \
  );

  export ERROR_MESSAGES;
}

# Checking input
function checkInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logInfo -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
      -d | --dry-run)
         DRY_RUN=1;
         shift;
         ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  # Parameters
  if [ "x${INPUT_FOLDER%/}" == "x" ]; then
    INPUT_FOLDER="$1";
    shift;
  fi

  if [ ! -e "${INPUT_FOLDER%/}" ]; then
    if [ "x${DRY_RUN}" != "x" ]; then
      logInfoResult FAILURE "dry-run";
    else
      logInfoResult FAILURE "fail";
      exitWithErrorCode INPUT_FOLDER_DOES_NOT_EXIST;
    fi
  else
    if [ ! -x "${INPUT_FOLDER%/}" ]; then
      if [ "x${DRY_RUN}" != "x" ]; then
        logInfoResult WARN "fail";
      else
        logInfoResult FAILURE "fail";
        exitWithErrorCode CANNOT_ACCESS_INPUT_FOLDER;
      fi
    else
      if [ ! -w "${INPUT_FOLDER%/}" ]; then
        logInfoResult FAILURE "fail";
        exitWithErrorCode REPORT_FILE_IS_NOT_WRITABLE;
      else
        logInfoResult SUCCESS "valid";
      fi
    fi
  fi

}

function processFolder() {
  local _folder="${1}";
  local _result="0";

  local _findArgs="";
  local _firstExtension=0;
  local _baseFolderName="${_folder%%-*}";
  local _count="${_folder##*-}";
  local _finalName;

  find "${_folder}" -type d -exec processFolder {} \; 2> /dev/null > /dev/null;

  logInfo -n "Processing ${_folder} for files ${MEDIA_FILE_EXTENSIONS}";

  for _extension in ${MEDIA_FILE_EXTENSIONS}; do
    if [ ${_firstExtension} == 0 ]; then
      _findArgs="${_findArgs}-name '*.${_extension}'";
    else
      _findArgs="${_findArgs} -or -name '*.${_extension}'";
    fi
    _firstExtension=1;
  done;

  if isDebugEnabled; then
    logInfoResult SUCCESS "...";
    logDebug -n "find ${_folder%/}/ ${_findArgs} | wc -l";
  fi
  _result=$(echo find ${_folder%/}/ ${_findArgs} | sh 2> /dev/null | wc -l);
  logDebugResult SUCCESS "${_result}";

  # extracting the last part if necessary
  if [ ${_count} -gt -1 ] 2> /dev/null ; then
    _baseFolderName="${_folder}";
  fi
  _finalName="${_baseFolderName}-${_result}";

  if [ "x${DRY_RUN}" != "x" ]; then
    if isDebugEnabled; then
      logInfo -n "Processing folder";
    fi
    logInfoResult SUCCESS "mv \"${_folder}\" \"${_finalName}\"";
  else
    mv "${_folder}" "${_finalName}";
  fi

  export RESULT="${_result}";
}

function createReportFile() {
  local _folder="${1}";
  local _findArgs="";
  local _firstExtension=0;
  local _baseFolderName="${_folder%%-*}";
  local _count="${_folder##*-}";
  local _finalName;

  for _extension in ${MEDIA_FILE_EXTENSIONS}; do
    if [ ${_firstExtension} == 0 ]; then
      _findArgs="${_findArgs}-name '*.${_extension}'";
    else
      _findArgs="${_findArgs} -or -name '*.${_extension}'";
    fi
    _firstExtension=1;
  done;

  logInfo -n "Creating ${REPORT_FILE}";
  if [ "x${DRY_RUN}" != "x" ]; then
    logInfoResult SUCCESS "find ${_folder%/}/ ${_findArgs} > ${REPORT_FILE}";
  else
    _result=$(echo find ${_folder%/}/ ${_findArgs} | sh 2> /dev/null > "${REPORT_FILE}");
    logDebugResult SUCCESS "${_result}";
  fi
}

function main() {
  processFolder "${INPUT_FOLDER}";
  logInfo -n "Found ${RESULT} media files in ${INPUT_FOLDER}";
  if [ "x${DRY_RUN}" != "x" ]; then
    logInfoResult SUCCESS "touch ${INPUT_FOLDER%/}/Total-${RESULT}";
  else
    touch "${INPUT_FOLDER%/}"/"Total-${RESULT}"
    if [ $? == 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
    fi
  fi

  createReportFile "${INPUT_FOLDER}";
}
