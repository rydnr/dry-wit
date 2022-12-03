#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function test_reset() {
  commandLineFlagCheckingCallbackCalled=${FALSE}
  commandLineFlagParsingCallbackCalled=${FALSE}
  checkInputChecksMandatoryFlagsCheckCalled=${FALSE}
  commandLineParameterCheckingCallbackCalled=${FALSE}
  commandLineParameterParsingCallbackCalled=${FALSE}
  optionalEnvVarCheckingCallbackCalled=${FALSE}
  optionalEnvVarParsingCallbackCalled=${FALSE}
  compoundCommandLineFlagCheckingCallbackCalled=${FALSE}
  compoundCommandLineFlagParsingCallbackCalled=${FALSE}
  checkInputCallbackCalled=${FALSE}
  CLI.resetState
  CLI.defaultState
  ENVVAR.resetState
  setDebugEchoEnabled FALSE
}

## Called before each test.
function test_setup() {
  test_reset
}

## Called after each test.
function test_tearDown() {
  test_reset
}

function dw_check_file_cli_flag() {
  commandLineFlagCheckingCallbackCalled=${TRUE}
}

function dw_parse_file_cli_flag() {
  commandLineFlagParsingCallbackCalled=${TRUE}
}

function dw_check_file_cli_parameter() {
  commandLineParameterCheckingCallbackCalled=${TRUE}
}

function dw_parse_file_cli_parameter() {
  commandLineParameterParsingCallbackCalled=${TRUE}
}

function dw_check_my_optional_envvar_cli_envvar() {
  optionalEnvVarCheckingCallbackCalled=${TRUE}
}

function dw_parse_my_optional_envvar_cli_envvar() {
  optionalEnvVarParsingCallbackCalled=${TRUE}
}

function dw_parse_repository_cli_parameter() {
  export REPOSITORY="${1}"
}

function dw_check_rootPassword_cli_parameter() {
  compoundCommandLineParameterCheckingCallbackCalled=${TRUE}
}

function dw_parse_rootPassword_cli_parameter() {
  compoundCommandLineParameterParsingCallbackCalled=${TRUE}
}

function dw_parse_repositories_cli_parameter() {
  export REPOSITORIES="${@}"
}

function dw_checkInput() {
  checkInputCallbackCalled=${TRUE}
}

function verbose_flag_is_supported_by_default_test() {
  local _result="$(checkInput -v)"
  Assert.isEmpty "${_result}" "checkInput returned something"
}

function checkInput_is_silent_when_providing_a_single_parameter_already_declared_test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE
  local _result="$(checkInput "/tmp/1.txt")"
  Assert.isEmpty "${_result}" "checkInput returned something"
}

function addCommandLineParameter_checking_callback_is_called_in_checkInput_test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE
  checkInput "/tmp/1.txt"
  Assert.isTrue ${commandLineParameterCheckingCallbackCalled} "dw_check_file_cli_parameter was not called in checkInput"
  Assert.isFalse ${commandLineParameterParsingCallbackCalled} "dw_parse_file_cli_parameter was called in checkInput"
}

function addCommandLineParameter_checking_callback_is_called_in_checkInput_for_a_compound_parameter_test() {
  addCommandLineParameter "rootPassword" "The root password" MANDATORY SINGLE
  checkInput "secret"
  Assert.isTrue ${compoundCommandLineParameterCheckingCallbackCalled} "dw_check_rootPassword_cli_parameter was not called in checkInput"
  Assert.isFalse ${compoundCommandLineParameterParsingCallbackCalled} "dw_parse_rootPassword_cli_parameter was called in checkInput"
}

function setScriptCopyright_is_included_in_the_usage_test() {
  local _copyright="2018-today Acme Inc."
  setScriptCopyright "${_copyright}"
  local _usage="$(usage)"
  Assert.contains "${_usage}" "${_copyright}" "Copyright is not included in the usage message"
}

function setScriptLicenseSummary_is_included_in_the_usage_test() {
  local _license="Distributed this under the GNU General Public License v3."
  setScriptLicenseSummary "${_license}"
  local _usage="$(usage)"
  Assert.contains "${_usage}" "${_license}" "License is not included in the usage message"
}

function usage_includes_command_line_flags_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT
  local _usage="$(usage)"
  Assert.contains "${_usage}" "-f|--file arg" "'usage' does not include -f|--file information"
}

function retrieveCommandLineShortNameFlagKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key
  CLI.buildCommandLineFlagKey "f" "file"
  _key="${RESULT}"
  CLI.retrieveCommandLineFlagShortNameFromKey "${_key}"
  Assert.areEqual "f" "${RESULT}" "f and ${RESULT} are not equal"
}

function retrieveCommandLineFlagLongNameFromKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key
  CLI.buildCommandLineFlagKey "f" "file"
  _key="${RESULT}"
  CLI.retrieveCommandLineFlagLongNameFromKey "${_key}"
  Assert.areEqual "file" "${RESULT}" "file and ${RESULT} are not equal"
}

function retrieveCommandLineFlagDescriptionFromKey_and_buildCommandLineFlagKey_are_consistent_test() {
  local _key
  local _description="The file to read"
  addCommandLineFlag "file" "f" "${_description}" MANDATORY EXPECTS_ARGUMENT
  CLI.buildCommandLineFlagKey "f" "file"
  _key="${RESULT}"
  CLI.retrieveCommandLineFlagDescriptionFromKey "${_key}"
  Assert.areEqual "${_description}" "${RESULT}" "${_description} and ${RESULT} are not equal"
}

function commandLineFlag_descriptions_are_included_in_the_usage_test() {
  local _flagDescription="file: The file to read"
  addCommandLineFlag "file" "f" "${_flagDescription}" MANDATORY EXPECTS_ARGUMENT
  local _usage="$(usage)"
  Assert.contains "${_usage}" "${_flagDescription}" "'usage' does not include ${_flagDescription}"
}

function setScriptDescription_is_included_in_the_usage_test() {
  local _description="This script does this and that"
  setScriptDescription "${_description}"
  local _usage="$(usage)"
  Assert.contains "${_usage}" "${_description}" "The script description is not included in the usage message"
}

function commandLineParameters_are_included_in_the_usage_test() {
  local _name="project"
  local _description="The project"
  addCommandLineParameter "${_name}" "${_description}" MANDATORY SINGLE
  local _usage="$(usage)"
  Assert.contains "${_usage}" "${_description}" "The script description is not included in the usage message"
}

function usage_does_not_print_too_many_empty_lines_test() {
  local _usage="$(usage)"
  usage | grep -e '^\n\n\n' >/dev/null
  local -i _tooManyEmptyLines=$?
  Assert.isFalse ${_tooManyEmptyLines} "usage() can include too many empty lines depending on the script metadata"
}

function checkInput_checks_mandatory_flags_test() {
  addCommandLineFlag file f "The file to read" MANDATORY NO_ARGUMENT
  (checkInput >/dev/null)
  local -i _rescode=$?
  local _result="$(checkInput)"
  Assert.isFalse ${_rescode} "checkInput didn't exit when a mandatory flag is missing"
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything"
  Assert.contains "${_result}" "file is mandatory" "checkInput didn't exit with an error message"
}

function checkInput_checks_flags_with_arguments_test() {
  addCommandLineFlag file f "The file to read" MANDATORY EXPECTS_ARGUMENT
  (checkInput -f >/dev/null)
  local -i _rescode=$?
  local _result="$(checkInput -f)"
  Assert.isFalse ${_rescode} "checkInput didn't exit when a mandatory flag is missing"
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything"
  Assert.contains "${_result}" "file expects an argument" "checkInput didn't exit with an error message"
}

function checkInput_checks_mandatory_parameters_test() {
  addCommandLineParameter file "The file to read" MANDATORY SINGLE
  (checkInput >/dev/null)
  local -i _rescode=$?
  local _result="$(checkInput)"
  Assert.isFalse ${_rescode} "checkInput didn't exit when a mandatory parameter is missing"
  Assert.isNotEmpty "${_result}" "checkInput didn't return anything"
  Assert.contains "${_result}" "file is mandatory" "checkInput didn't exit with an error message"
}

function checkInput_does_not_complain_with_no_flags_and_one_parameter_test() {
  addCommandLineParameter file "The file to read" MANDATORY SINGLE
  local _result="$(checkInput "/tmp/1.txt")"
  Assert.isEmpty "${_result}" "checkInput returned something"
}

function cli_module_adds_debug_flag_automatically_test() {
  local -i _debugDefined
  CLI.isCommandLineFlagDefined "-v"
  _debugDefined=$?
  Assert.isTrue ${_debugDefined} "CLI module does not define -v flag automatically"
  CLI.isCommandLineFlagDefined "--debug"
  _debugDefined=$?
  Assert.isTrue ${_debugDefined} "CLI module does not define --debug flag automatically"
}

function cli_module_adds_trace_flag_automatically_test() {
  local -i _traceDefined
  CLI.isCommandLineFlagDefined "-vv"
  _traceDefined=$?
  Assert.isTrue ${_traceDefined} "CLI module does not define -vv flag automatically"
  CLI.isCommandLineFlagDefined "--trace"
  _traceDefined=$?
  Assert.isTrue ${_traceDefined} "CLI module does not define --trace flag automatically"
}

function cli_module_adds_quiet_flag_automatically_test() {
  local -i _quietDefined
  CLI.isCommandLineFlagDefined "-q"
  _quietDefined=$?
  Assert.isTrue ${_quietDefined} "CLI module does not define -q flag automatically"
  CLI.isCommandLineFlagDefined "--quiet"
  _quietDefined=$?
  Assert.isTrue ${_quietDefined} "CLI module does not define --quiet flag automatically"
}

function cli_module_adds_help_flag_automatically_test() {
  local -i _helpDefined
  CLI.isCommandLineFlagDefined "-h"
  _helpDefined=$?
  Assert.isTrue ${_helpDefined} "CLI module does not define -h flag automatically"
  CLI.isCommandLineFlagDefined "--help"
  _helpDefined=$?
  Assert.isTrue ${_helpDefined} "CLI module does not define --help flag automatically"
}

function cli_module_allows_deleting_automatic_flags_test() {
  local -i _helpDefined
  removeCommandLineFlag "-h"
  CLI.isCommandLineFlagDefined "-h"
  _helpDefined=$?
  Assert.isFalse ${_helpDefined} "CLI module does not allow removing the -h flag"
  CLI.isCommandLineFlagDefined "--help"
  _helpDefined=$?
  Assert.isFalse ${_helpDefined} "CLI module does not allow removing the --help flag"
}

function addCommandLineParameter_parsing_callback_is_called_in_parseInput_test() {
  addCommandLineParameter "file" "The file to read" MANDATORY SINGLE
  parseInput "/tmp/1.txt"
  Assert.isFalse ${commandLineParameterCheckingCallbackCalled} "dw_check_file_cli_parameter was called in checkInput"
  Assert.isTrue ${commandLineParameterParsingCallbackCalled} "dw_parse_file_cli_parameter was not called in checkInput"
}

function addCommandLineFlag_parsing_callback_is_called_in_parseInput_test() {
  addCommandLineFlag "file" "f" "The file to read" MANDATORY EXPECTS_ARGUMENT
  parseInput "-f" "/tmp/1.txt"
  Assert.isTrue ${commandLineFlagParsingCallbackCalled} "dw_check_file_cli_flag was not called in parseInput"
  Assert.isFalse ${commandLineFlagCheckingCallbackCalled} "dw_parse_file_cli_flag was called in parseInput"
}

function checkInput_calls_a_check_callback_for_defined_environment_variables_test() {
  defineEnvVar MY_OPTIONAL_ENVVAR OPTIONAL "An environment variable used for testing" "default-value"
  checkInput
  Assert.isTrue ${optionalEnvVarCheckingCallbackCalled} "dw_check_my_optional_envvar_cli_envvar was not called in parseInput"
  Assert.isFalse ${optionalEnvVarParsingCallbackCalled} "dw_parse_my_optional_envvar_cli_envvar was called in parseInput"
}

function checkInput_checks_mandatory_environment_variables_are_not_empty_test() {
  defineEnvVar MY_MANDATORY_ENVVAR MANDATORY "An environment variable used for testing" "default-value"
  export MY_MANDATORY_ENVVAR=""
  local _result="$(MY_MANDATORY_ENVVAR="" checkInput)"
  Assert.isNotEmpty "${_result}" "checkInput didn't check for MY_MANDATORY_ENVVAR"
}

function parseInput_does_not_fail_if_there_is_no_callback_function_for_a_mandatory_parameter_test() {
  addCommandLineParameter "folder" "The file to read" MANDATORY SINGLE
  (parseInput "/tmp" >/dev/null 2>&1)
  Assert.isTrue $? "parseInput worked even with no callback defined"
}

function parseInput_uses_the_default_value_of_an_optional_command_line_flag_test() {
  addCommandLineFlag "tag" "t" "The tag" OPTIONAL EXPECTS_ARGUMENT "latest"
  addCommandLineFlag "overwrite-latest-tag" "olt" "Whether to override latest tag" OPTIONAL NO_ARGUMENT "false"
  parseInput "-v"
  Assert.isNotEmpty "${TAG}" "TAG is not defined"
  Assert.areEqual "latest" "${TAG}" "TAG should be 'latest' when omitted"
  Assert.isNotEmpty "${OVERWRITE_LATEST_TAG}" "OVERWRITE_LATEST_TAG is not defined"
  Assert.areEqual "false" "${OVERWRITE_LATEST_TAG}" "OVERWRITE_LATEST_TAG should be 'false' when not defined."
}

function parseInput_does_not_swallow_parameters_test() {
  setDebugEchoEnabled TRUE
  addCommandLineParameter "repository" "The repository" MANDATORY SINGLE
  parseInput "-v" "base"
  Assert.isNotEmpty "${REPOSITORY}" "REPOSITORY was empty"
}

function drywit_calls_dw_checkInput_test() {
  checkInput
  Assert.isTrue ${checkInputCallbackCalled} "dw_checkInput is not called"
}

function parseInput_calls_parameter_callback_with_just_the_parameter_test() {
  addCommandLineFlag "noCache" "nc" "Whether to use the cached images or not" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "force" "f" "Whether to build the image even if it's already built" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "overwriteLatest" "o" "Whether to overwrite the \"latest\" tag with the new one (default: false)" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "registryTag" "rt" "Whether to tag also for pushing the image to the remote registry (implicit if -rp is enabled)" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "registryPush" "rp" "Optionally, whether to push the image to a remote registry" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "reduceImage" "ri" "Whether to reduce the size of the resulting image" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "cleanupImages" "ci" "Whether to try to cleanup images" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "cleanupContainers" "cc" "Whether to try to cleanup containers" OPTIONAL NO_ARGUMENT "false"
  addCommandLineFlag "X:evalDefaults" "X:e" "Whether to eval all default values, which potentially slows down the script unnecessarily" OPTIONAL NO_ARGUMENT
  addCommandLineParameter "repositories" "The repositories to build" MANDATORY MULTIPLE
  checkInput -v -f -o base
  Assert.isTrue $? 'checkInput -v -f -o base failed'
  parseInput -v -f -o base
  Assert.isNotEmpty "${REPOSITORIES}" "REPOSITORIES was empty"
  Assert.areEqual "base" "${REPOSITORIES}" 'Repositories are not parsed correctly'
}

function empty_default_values_for_optional_flags_are_allowed_test() {
  addCommandLineFlag "probablyEmpty" "pe" "A probably empty flag" OPTIONAL EXPECTS_ARGUMENT ""
  checkInput
  Assert.isEmpty "${PROBABLY_EMPTY}" "PROBABLY_EMPTY should be empty"

  addCommandLineFlag "anotherProbablyEmpty" "ape" "A probably empty flag" OPTIONAL EXPECTS_ARGUMENT "false"
  checkInput -ape ""
  Assert.isEmpty "${ANOTHER_PROBABLY_EMPTY}" "ANOTHER_PROBABLY_EMPTY should be empty"
}

function flags_whose_values_contain_spaces_are_supported_test() {
  addCommandLineFlag myFlag pe "A flag" OPTIONAL EXPECTS_ARGUMENT ""
  parseInput -pe 'with spaces'
  Assert.areEqual 'with spaces' "${MY_FLAG}" "Flags with spaces are not correctly parsed"

  addCommandLineFlag versionFlag vf "A flag" OPTIONAL EXPECTS_ARGUMENT "version 1"
  parseInput -vf 'with spaces'
  Assert.areEqual 'with spaces' "${VERSION_FLAG}" "Flags with spaces are not correctly parsed"
}

function flags_whose_values_contain_spaces_and_there_are_more_flags_are_supported_test() {
  addCommandLineFlag versionFlag vf "A flag" OPTIONAL EXPECTS_ARGUMENT "version 1"
  addCommandLineFlag anotherVersionFlag avf "Another flag" OPTIONAL EXPECTS_ARGUMENT "version 2"
  parseInput -vf 'with spaces' -avf 'another flag with spaces'
  Assert.areEqual 'with spaces' "${VERSION_FLAG}" "Flags with spaces are not correctly parsed"
  Assert.areEqual 'another flag with spaces' "${ANOTHER_VERSION_FLAG}" "Flags with spaces are not correctly parsed"
}

function mandatory_flags_are_parsed_correctly_test() {
  addCommandLineFlag "myFlag" "pe" "A flag" MANDATORY EXPECTS_ARGUMENT ""
  parseInput -pe 'mandatory'
  Assert.areEqual 'mandatory' "${MY_FLAG}" "Mandatory flags are not correctly parsed"
}

function any_dw_flag_is_ignored_test() {
  local _flag="undefined"
  local _result="$(checkInput -DW:${_flag})"
  Assert.isTrue $? "-DW:${_flag} is not ignored"
  Assert.isEmpty "${_result}" "-DW:${_flag} is not ignored"

  _flag="vv"
  _result="$(checkInput -DW:${_flag})"
  Assert.isTrue $? "-DW:${_flag} is not ignored"
  Assert.isEmpty "${_result}" "-DW:${_flag} is not ignored"
}

function ARGS_variable_does_not_get_overwritten_test() {
  addCommandLineFlag "userId" "u" "The user id" OPTIONAL EXPECTS_ARGUMENT ""
  addCommandLineFlag "userName" "U" "The user name" OPTIONAL EXPECTS_ARGUMENT ""
  addCommandLineFlag "groupId" "g" "The group id" OPTIONAL EXPECTS_ARGUMENT ""
  addCommandLineFlag "groupName" "G" "The group name" OPTIONAL EXPECTS_ARGUMENT ""
  addCommandLineParameter "folder" "The folder where the command should run" MANDATORY SINGLE
  addCommandLineParameter "command" "The command to run" MANDATORY SINGLE
  addCommandLineParameter "args" "The command arguments" OPTIONAL MULTIPLE
  local _expected
  _expected="one two"
  parseInput -pe /tmp cmd ${_expected}
  Assert.areEqual "${_expected}" "${ARGS}" "ARGS variable not set or its value is not correct"
}

function parameters_with_multiple_values_test() {
  addCommandLineParameter "folders" "The folders" MANDATORY MULTIPLE
  local _expected
  _expected="one two"
  parseInput -pe ${_expected}
  Assert.areEqual "${_expected}" "${FOLDERS}" "FOLDERS variable not set or its value is not correct"
}

declare -ig commandLineFlagCheckingCallbackCalled=${FALSE}
declare -ig commandLineFlagParsingCallbackCalled=${FALSE}
declare -ig checkInputChecksMandatoryFlagsCheckCalled=${FALSE}
declare -ig commandLineParameterCheckingCallbackCalled=${FALSE}
declare -ig commandLineParameterParsingCallbackCalled=${FALSE}
declare -ig optionalEnvVarCheckingCallbackCalled=${FALSE}
declare -ig optionalEnvVarParsingCallbackCalled=${FALSE}
declare -ig compoundCommandLineParameterCheckingCallbackCalled=${FALSE}
declare -ig compoundCommandLineParameterParsingCallbackCalled=${FALSE}
declare -ig checkInputCallbackCalled=${FALSE}

setScriptDescription "Runs all tests implemented for cli.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
