#!/bin/bash ../src/dry-wit-test
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

import cli;

function test_setup() {
  commandLineFlagCheckingCallbackCalled=${FALSE};
  commandLineFlagParsingCallbackCalled=${FALSE};
}

function commandLineFlagCheckingCallback() {
  commandLineFlagCheckingCallbackCalled=${TRUE};
}

function commandLineFlagParsingCallback() {
  commandLineFlagParsingCallbackCalled=${TRUE};
}

function addCommandLineFlag_checking_callback_is_called_in_checkInput_test() {
  addCommandLineFlag "f" "file" "The file to read" MANDATORY EXPECTS_ARGUMENT commandLineFlagParsingCallback commandLineFlagCheckingCallback;
  checkInput "-f" "/tmp/1.txt";
  Assert.isTrue ${commandLineFlagCheckingCallbackCalled} "checkingCallback not called in checkInput";
  Assert.isFalse ${commandLineFlagParsingCallbackCalled} "parsingCallback was called in checkInput";
}

function addCommandLineFlag_parsing_callback_is_called_in_parseInput_test() {
  addCommandLineFlag "f" "file" "The file to read" MANDATORY EXPECTS_ARGUMENT commandLineFlagParsingCallback commandLineFlagCheckingCallback;
  parseInput "-f" "/tmp/1.txt";
  Assert.isTrue ${commandLineFlagParsingCallbackCalled} "parsingCallback not called in parseInput";
  Assert.isFalse ${commandLineFlagCheckingCallbackCalled} "checkingCallback was called in parseInput";
}

function setCopyright_is_included_in_the_usage_test() {
  local _copyright="2018-today Acme Inc."
  setCopyright "${_copyright}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_copyright}" "Copyright is not included in the usage message";
}

function setLicenseSummary_is_included_in_the_usage_test() {
  local _license="Distributed this under the GNU General Public License v3.";

  setLicenseSummary "${_license}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_license}" "License is not included in the usage message";
}

function usage_includes_command_line_flags_test() {
  addCommandLineFlag "f" "file" "The file to read" MANDATORY EXPECTS_ARGUMENT commandLineFlagParsingCallback commandLineFlagCheckingCallback;
  local _usage="$(usage)";
  Assert.contains "${_usage}" "-f|--file arg" "'usage' does not include -f|--file information";
  usage
}

function retrieveCommandLineShortNameFlagKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key;
  CLI.buildCommandLineFlagKey "f" "file";
  _key="${RESULT}";
  CLI.retrieveCommandLineFlagShortNameFromKey "${_key}";
  Assert.areEqual "f" "${RESULT}" "f and ${RESULT} are not equal";
}

function retrieveCommandLineFlagLongNameFromKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key;
  CLI.buildCommandLineFlagKey "f" "file";
  _key="${RESULT}";
  CLI.retrieveCommandLineFlagLongNameFromKey "${_key}";
  Assert.areEqual "file" "${RESULT}" "file and ${RESULT} are not equal";
}

function retrieveCommandLineFlagDescriptionFromKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key;
  local _description="The file to read";
  addCommandLineFlag "f" "file" "${_description}" MANDATORY EXPECTS_ARGUMENT commandLineFlagParsingCallback commandLineFlagCheckingCallback;
  CLI.buildCommandLineFlagKey "f" "file";
  _key="${RESULT}";
  CLI.retrieveCommandLineFlagDescriptionFromKey "${_key}";
  Assert.areEqual "${_description}" "${RESULT}" "${_description} and ${RESULT} are not equal";
}

function commandLineFlag_descriptions_are_included_in_the_usage_test() {
  local _flagDescription="file: The file to read";
  addCommandLineFlag "f" "file" "${_flagDescription}" MANDATORY EXPECTS_ARGUMENT commandLineFlagCheckingCallback commandLineFlagParsingCallback commandLineFlagCheckingCallback;
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_flagDescription}" "'usage' does not include ${_flagDescription}";
}

function setScriptDescription_is_included_in_the_usage_test() {
  local _description="This script does this and that";
  setScriptDescription "${_description}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_description}" "The script description is not included in the usage message";
}
#
