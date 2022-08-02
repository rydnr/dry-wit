#!/bin/bash dry-wit

setScriptDescription "Generates bashdoc documentation for a set of bash scripts";
setScriptLicenseSummary "Distributed under the terms of the GNU General Public License v3";
setScriptCopyright "Copyright 2020-today Automated Computing Machinery S.L.";

addCommandLineParameter baseFolder "The base folder of the bash scripts" MANDATORY SINGLE;
addCommandLineFlag outputFile "-o" "The output file" MANDATORY EXPECTS_ARGUMENT;
addCommandLineFlag extension "-e" "The file extension of the bash scripts" OPTIONAL EXPECTS_ARGUMENT ".sh";
addCommandLineFlag author "-A" "The author" MANDATORY EXPECTS_ARGUMENT;
addCommandLineFlag title "-T" "The title" MANDATORY EXPECTS_ARGUMENT;
addCommandLineFlag highlightTheme "-ht" "The highlight theme" OPTIONAL EXPECTS_ARGUMENT "";
addCommandLineFlag api "-a" "The API to document" OPTIONAL EXPECTS_ARGUMENT "public";
addCommandLineFlag includeDate "-d" "Whether to include the date" OPTIONAL NO_ARGUMENT "false";
addCommandLineFlag template "-t" "Path to the HTML template" OPTIONAL EXPECTS_ARGUMENT "";
addCommandLineFlag stylesheet "-s" "Path to the CSS stylesheet" OPTIONAL EXPECTS_ARGUMENT "";
checkReq bashdoc;

# fun: main
# api: public
# txt: Main logic. Gets called by dry-wit.
# txt: Returns 0/TRUE always, but may exit due to errors.
# use: main
function main() {
 	logTrace -n "BASE_FOLDER";
  logTraceResult SUCCESS "${BASE_FOLDER}";
  logTrace -n "EXTENSION";
  logTraceResult SUCCESS "${EXTENSION}";
  logTrace -n "OUTPUT_FILE";
  logTraceResult SUCCESS "${OUTPUT_FILE}";
  logTrace -n "AUTHOR";
  logTraceResult SUCCESS "${AUTHOR}";
  logTrace -n "TITLE";
  logTraceResult SUCCESS "${TITLE}";
  logTrace -n "HIGHLIGHT_THEME";
  logTraceResult SUCCESS "${HIGHLIGHT_THEME}";
  logTrace -n "API";
  logTraceResult SUCCESS "${API}";
  logTrace -n "INCLUDE_DATE";
  logTraceResult SUCCESS "${INCLUDE_DATE}";

  local -a _args=();
  _args[${#_args[@]}]="-o ${OUTPUT_FILE}";
  _args[${#_args[@]}]="--author ${AUTHOR}";
  _args[${#_args[@]}]="-T ${TITLE}";
  if isNotEmpty "${HIGHTLIGHT_THEME}" && areNotEqual "${HIGHLIGHT_THEME}" "false"; then
    _args[${#_args[@]}]="-H ${HIGHLIGHT_THEME}";
  fi
  _args[${#_args[@]}]="--api ${API}";
  if isTrue "${INCLUDE_DATE}"; then
    _args[${#_args[@]}]="--include-date";
  fi
  if isNotEmpty "${TEMPLATE}" && areNotEqual "${TEMPLATE}" "false"; then
    _args[${#_args[@]}]="--template ${TEMPLATE}";
  fi
  if isNotEmpty "${STYLESHEET}" && areNotEqual "${STYLESHEET}" "false"; then
    _args[${#_args[@]}]="--style ${STYLESHEET}";
  fi

  pushd "${BASE_FOLDER}" 2>&1 > /dev/null;
  local -a _files=( $(find . -name "*${EXTENSION}" | sort) );
  local _filesArgs="";
  local -i _f;
  for ((_f = 0; _f < ${#_files[@]}; _f++)); do
    _filesArgs="${_filesArgs} ${_files[${_f}]}";
  done
 	local _cmd="bashdoc ${_args[@]} ${_filesArgs}";

  logDebug "Running ${_cmd}";
  ${_cmd};
  popd 2>&1 > /dev/null;
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
