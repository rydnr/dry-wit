#!/bin/bash ../src/dry-wit-test
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

import cli;

function test_reset() {
  commandLineFlagCheckingCallbackCalled=${FALSE};
  commandLineFlagParsingCallbackCalled=${FALSE};
  checkInputChecksMandatoryFlagsCheckCalled=${FALSE};
  commandLineParameterCheckingCallbackCalled=${FALSE};
  commandLineParameterParsingCallbackCalled=${FALSE};
  CLI.resetState;
}

## Called before each test.
function test_setup() {
  test_reset;
}

## Called after each test.
function test_tearDown() {
  test_reset;
}

function dw_check_file_cli_flag() {
  commandLineFlagCheckingCallbackCalled=${TRUE};
}

function dw_parse_file_cli_flag() {
  commandLineFlagParsingCallbackCalled=${TRUE};
}

function dw_check_file_cli_parameter() {
  commandLineParameterCheckingCallbackCalled=${TRUE};
}

function dw_parse_file_cli_parameter() {
  commandLineParameterParsingCallbackCalled=${TRUE};
}

function addCommandLineFlag_checking_callback_is_called_in_checkInput_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT;
  checkInput "-f" "/tmp/1.txt";
  Assert.isTrue ${commandLineFlagCheckingCallbackCalled} "dw_check_file_cli_flag not called in checkInput";
  Assert.isFalse ${commandLineFlagParsingCallbackCalled} "dw_parse_file_cli_flag was called in checkInput";
}

function addCommandLineFlag_parsing_callback_is_called_in_parseInput_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT;
  parseInput "-f" "/tmp/1.txt";
  Assert.isTrue ${commandLineFlagParsingCallbackCalled} "dw_check_file_cli_flag not called in parseInput";
  Assert.isFalse ${commandLineFlagCheckingCallbackCalled} "dw_parse_file_cli_flag was called in parseInput";
}

function setScriptCopyright_is_included_in_the_usage_test() {
  local _copyright="2018-today Acme Inc."
  setScriptCopyright "${_copyright}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_copyright}" "Copyright is not included in the usage message";
}

function setScriptLicenseSummary_is_included_in_the_usage_test() {
  local _license="Distributed this under the GNU General Public License v3.";
  setScriptLicenseSummary "${_license}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_license}" "License is not included in the usage message";
}

function usage_includes_command_line_flags_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT;
  local _usage="$(usage)";
  Assert.contains "${_usage}" "-f|--file arg" "'usage' does not include -f|--file information";
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
  addCommandLineFlag "file" "f" "${_description}" MANDATORY EXPECTS_ARGUMENT;
  CLI.buildCommandLineFlagKey "f" "file";
  _key="${RESULT}";
  CLI.retrieveCommandLineFlagDescriptionFromKey "${_key}";
  Assert.areEqual "${_description}" "${RESULT}" "${_description} and ${RESULT} are not equal";
}

function commandLineFlag_descriptions_are_included_in_the_usage_test() {
  local _flagDescription="file: The file to read";
  addCommandLineFlag "file" "f" "${_flagDescription}" MANDATORY EXPECTS_ARGUMENT;
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_flagDescription}" "'usage' does not include ${_flagDescription}";
}

function setScriptDescription_is_included_in_the_usage_test() {
  local _description="This script does this and that";
  setScriptDescription "${_description}";
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_description}" "The script description is not included in the usage message";
}

function commandLineParameters_are_included_in_the_usage_test() {
  local _name="project";
  local _description="The project";
  addCommandLineParameter "${_name}" "${_description}" MANDATORY SINGLE;
  local _usage="$(usage)";
  Assert.contains "${_usage}" "${_description}" "The script description is not included in the usage message";
}

function usage_does_not_print_too_many_empty_lines_test() {
  local _usage="$(usage)";
  usage | grep -e '^\n\n\n' > /dev/null
  local -i _tooManyEmptyLines=$?;
  Assert.isFalse ${_tooManyEmptyLines} "usage() can include too many empty lines depending on the script metadata";
}

function checkInput_checks_mandatory_flags_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY NO_ARGUMENT;
  (checkInput > /dev/null)
  local -i _rescode=$?;
  local _result="$(checkInput)";
  Assert.isFalse ${_rescode} "checkInput didn't exited when a mandatory flag is missing";
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything";
  Assert.contains "${_result}" "Error" "checkInput didn't exited with an error message";
}

function checkInput_checks_flags_with_arguments_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT;
  (checkInput -f > /dev/null)
  local -i _rescode=$?;
  local _result="$(checkInput -f)";
  Assert.isFalse ${_rescode} "checkInput didn't exited when a mandatory flag is missing";
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything";
  Assert.contains "${_result}" "Error" "checkInput didn't exited with an error message";
}

function checkInput_checks_mandatory_parameters_test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE;
  (checkInput > /dev/null)
  local -i _rescode=$?;
  local _result="$(checkInput)";
  Assert.isFalse ${_rescode} "checkInput didn't exited when a mandatory parameter is missing";
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything";
  Assert.contains "${_result}" "Error" "checkInput didn't exited with an error message";
}

function addCommandLineParameter_checking_callback_is_called_in_checkInput_test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE;
  checkInput "/tmp/1.txt";
  Assert.isTrue ${commandLineParameterCheckingCallbackCalled} "dw_check_file_cli_parameter was not called in checkInput";
  Assert.isFalse ${commandLineParameterParsingCallbackCalled} "dw_parse_file_cli_parameter was called in checkInput";
}

function addCommandLineParameter_parsing_callback_is_called_in_parseInput__test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE;
  parseInput "/tmp/1.txt";
  Assert.isFalse ${commandLineParameterCheckingCallbackCalled} "dw_check_file_cli_parameter was called in checkInput";
  Assert.isTrue ${commandLineParameterParsingCallbackCalled} "dw_parse_file_cli_parameter was not called in checkInput";
}


#
