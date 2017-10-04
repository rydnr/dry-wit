#!/bin/bash dry-wit
# Copyright 2017-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3
# Adapted from http://www.admin-magazine.com/Articles/Using-rsync-for-Backups/(offset)/2

function usage() {
cat <<EOF
$SCRIPT_NAME sourceFolder destinationFolder
$SCRIPT_NAME [-h|--help]
(c) 2017-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Backs up the source folder (updating ${backupFolderName})

Where:
  * sourceFolder: the source folder to back up.
  * destinationFolder: the destination folder.
Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

# Error messages
function defineErrors() {
  addError INVALID_OPTION "Unrecognized option";
  addError SOURCE_FOLDER_IS_MANDATORY "sourceFolder is mandatory";
  addError SOURCE_FOLDER_DOES_NOT_EXIST "sourceFolder does not exist";
  addError SOURCE_FOLDER_IS_NOT_A_FOLDER "sourceFolder is not a folder";
  addError DESTINATION_FOLDER_IS_MANDATORY "destinationFolder is mandatory";
  addError DESTINATION_FOLDER_DOES_NOT_EXIST "destinationFolder does not exist";
  addError DESTINATION_FOLDER_IS_NOT_A_FOLDER "destinationFolder is not a folder";
  addError BACKUP_FOLDER_NAME_PREFIX_IS_MANDATORY "BACKUP_FOLDER_NAME_PREFIX is mandatory";
  addError MAX_BACKUPS_IS_MANDATORY "MAX_BACKUPS is mandatory";
  addError CANNOT_PROCESS_PREVIOUS_BACKUP "Error processing previous backup";
  addError CANNOT_BACK_UP_SOURCE_FOLDER "Cannot back up source folder";
  addError CANNOT_REMOVE_OLDEST_BACKUP "Cannot remove oldest backup";
  addError CANNOT_RENAME_OLD_BACKUP "Cannot rename old backup";
  addError CANNOT_CREATE_BACKUP_FOLDER "Cannot create backup folder";
}

## Parses the input
## dry-wit hook
function parseInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults)
         shift;
         ;;
    esac
  done

  # Parameters
  if isEmpty "${SOURCE_FOLDER}"; then
    SOURCE_FOLDER="${1}";
    shift;
  fi

  if isEmpty "${DESTINATION_FOLDER}"; then
    DESTINATION_FOLDER="${1}";
    shift;
  fi
}

## Checking input
## dry-wit hook
function checkInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;

  logDebug -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults)
        ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  if isEmpty "${SOURCE_FOLDER}"; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode SOURCE_FOLDER_IS_MANDATORY;
  fi

  if [ ! -e "${SOURCE_FOLDER}" ]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode SOURCE_FOLDER_DOES_NOT_EXIST;
  fi

  if [ ! -d "${SOURCE_FOLDER}" ]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode SOURCE_FOLDER_IS_NOT_A_FOLDER;
  fi

  if isEmpty "${DESTINATION_FOLDER}"; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode DESTINATION_FOLDER_IS_MANDATORY;
  fi

  if [ ! -e "${DESTINATION_FOLDER}" ]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode DESTINATION_FOLDER_DOES_NOT_EXIST;
  fi

  if [ ! -d "${DESTINATION_FOLDER}" ]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode DESTINATION_FOLDER_IS_NOT_A_FOLDER;
  fi

  if isEmpty "${BACKUP_FOLDER_NAME_PREFIX}"; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode BACKUP_FOLDER_NAME_PREFIX_IS_MANDATORY;
  fi

  if isEmpty "${MAX_BACKUPS}"; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode MAX_BACKUPS_IS_MANDATORY;
  else
    logDebugResult SUCCESS "valid";
  fi
}

## Checks whether two folders contains the same files.
## 1 -> The first folder.
## 2 -> The second folder.
## <- 0/${TRUE} if both folders are equal; 1/${FALSE} otherwise.
## Example:
##   if foldersAreEqual "/tmp/$$.1" "/tmp/$$.2"; then
##     echo "/tmp/$$.1 and /tmp/$$.2 are equal"
##   fi
function foldersAreEqual() {
  local _first="${1}";
  local _second="${2}";
  local -i _rescode;

  checkNotEmpty "first" "${_first}" 1;
  checkNotEmpty "second" "${_second}" 2;

  logTrace -n "Comparing ${_first} and ${_second} for differences";

  if [ -e "${_first}" ] && [ -e "${_second}" ]; then
    diff -wur "${_first}/" "${_second}/" 2>&1 > /dev/null
    _rescode=$?;
  elif [ ! -e "${_first}" ] && [ ! -e "${_second}" ]; then
    _rescode=${TRUE};
  else
    _rescode=${FALSE};
  fi

  if isTrue ${_rescode}; then
    logTraceResult SUCCESS "identical"
  else
    logTraceResult SUCCESS "different"
  fi

  return ${_rescode}
}

## Deletes given folder
## 1 -> The folder to remove.
## <- 0/${TRUE} if the folder was deleted; 1/${FALSE} otherwise.
## Example:
##   if deleteFolder "/tmp/$$"; then
##     echo "/tmp/$$ removed successfully"
##   fi
function deleteFolder() {
  local _folder="${1}";
  local -i _rescode=${TRUE};

  checkNotEmpty "folder" "${_folder}" 1;

  if [ -e "${_folder}" ]; then
    logInfo -n "Removing ${_folder}";
    rm -rf "${_folder}";
    _rescode=$?;
    if isTrue ${_rescode}; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
    fi
  fi

  return ${_rescode};
}

## Renames/moves given folder.
## 1 -> The folder to rename.
## 2 -> The destination folder.
## <- 0/${TRUE} if the folder was deleted; 1/${FALSE} otherwise.
## Example:
##   if moveFolder "/tmp/$$" "/tmp/$$.bak"; then
##     echo "/tmp/$$.bak removed successfully"
##   fi
function moveFolder() {
  local _source="${1}";
  local _destination="${2}";
  local -i _rescode=${TRUE};

  checkNotEmpty "source" "${_source}" 1;
  checkNotEmpty "destination" "${_destination}" 2;

  if [ -e "${_source}" ]; then
    if [ -e "${_destination}" ]; then
      logInfo -n "Destination ${_destination} already exists";
      logInfoResult FAILURE "failed";
      _rescode=${FALSE};
    else
      logInfo -n "Moving ${_source} to ${_destination}";
      mv "${_source}" "${_destination}";
      _rescode=$?;
      if isTrue ${_rescode}; then
        logInfoResult SUCCESS "done";
      else
        logInfoResult FAILURE "failed";
      fi
    fi
  fi

  return ${_rescode};
}

function main() {
  if [ ! -e "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0" ]; then
    mkdir -p "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0" 2>&1 > /dev/null;
    if isFalse $?; then
      exitWithErrorCode CANNOT_CREATE_BACKUP_FOLDER "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0";
    fi
  fi
  if ! foldersAreEqual "${SOURCE_FOLDER}" "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0"; then
    if [ -e "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}${MAX_BACKUPS}" ]; then
      if ! deleteFolder "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}${MAX_BACKUPS}"; then
        exitWithErrorCode CANNOT_REMOVE_OLDEST_BACKUP "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}${MAX_BACKUPS}";
      fi
    fi
    for i in $(seq 1 ${MAX_BACKUPS}); do
      if [ -e "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}${i}" ]; then
        if ! moveFolder "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}${i}" "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}$((i+1))"; then
          exitWithErrorCode CANNOT_RENAME_OLD_BACKUP "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}$((i+1))";
        fi
      fi
    done
    logInfo -n "Processing previous backup";
    cp -al "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0" "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}1";
    if isTrue $?; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
      exitWithErrorCode CANNOT_PROCESS_PREVIOUS_BACKUP;
    fi
    logInfo -n "Backing up ${SOURCE_FOLDER}";
    rsync -a --delete "${SOURCE_FOLDER}/"  "${DESTINATION_FOLDER}/${BACKUP_FOLDER_NAME_PREFIX}0/"
    if isTrue $?; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
      exitWithErrorCode CANNOT_BACK_UP_SOURCE_FOLDER;
    fi
  fi
}
