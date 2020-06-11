#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function log_category_is_printed_while_logging_test() {
  local _result="$(logInfo 'sample log')";
  Assert.isNotEmpty "${_result}" "logInfo 'something' didn't print anything";
}

function echoLogOutcome_does_not_call_alignRight_with_invalid_keyword_parameter_test() {
  local _result="$(logInfo 'sample log' 2>&1)";
  Assert.doesNotContain "'SUCCESS|FAILURE' (pass) is not valid when calling LOGGING.alignRight. Review LOGGING.echoLogOutcome" "${_result}" "LOGGING.echoLogOutcome calls LOGGING.alignRight incorrectly";
}

function logToFile_appends_logging_to_a_file_test() {
  createTempFile;
  local _file="${RESULT}";

  local _message='sample logging message';
  logToFile "${_file}";
  logInfo "${_message}" > /dev/null 2&>1;
  tail -n 2 "${_file}" | grep "${_message}" > /dev/null > 2&>1;
  Assert.isTrue $? "Log file didn't contain logging";
  cat "${_file}" > /tmp/log
}

function logDebug_inside_logInfo_does_not_mess_the_log_category_test() {
  setInfoEnabled;
  logInfo "logInfo stuff";
  setDebugEnabled;
  getLogCategory;
  logDebug "category: ${RESULT}";
  Assert.isTrue $? "tautology";
}

function the_log_category_is_propagated_to_nested_logging_test() {
  logInfo -n "This is a INFO message";
  getLogCategory;
  local _parentCategory="${RESULT}";
  logInfo "This is a nested message";
  getLogCategory;
  local _childCategory="${RESULT}";
  logResult SUCCESS "done";
  contains "${_childCategory}" "${_parentCategory}";
  local -i _contains=$?;
  Assert.isTrue "${_contains}" "child category (${_childCategory}) does not contain parent category (${_parentCategory})";
}

function log_prefix_uses_all_log_category_stack_test() {
  local _category1="aeourch";
  local _category2="3138465";
  LOGGING.pushLogCategory "${_category1}";
  LOGGING.pushLogCategory "${_category2}";
  LOGGING.buildLogPrefix ${FALSE};
  local _actual="${RESULT}";
  Assert.contains "${_actual}" "${_category1}" "LOGGING.buildLogPrefix doesn't use ${_category1} category";
  Assert.contains "${_actual}" "${_category2}" "LOGGING.buildLogPrefix doesn't use ${_category2} category";

  _category1=".apurchoaekj/olekh";
  _category2="4<35P1EU<>U5";
  LOGGING.pushLogCategory "${_category1}";
  LOGGING.pushLogCategory "${_category2}";
  LOGGING.buildLogPrefix ${FALSE};
  _actual="${RESULT}";
  Assert.contains "${_actual}" "${_category1}" "LOGGING.buildLogPrefix doesn't use ${_category1} category";
  Assert.contains "${_actual}" "${_category2}" "LOGGING.buildLogPrefix doesn't use ${_category2} category";
}

function processLogPrefixTokens_works_test() {
  local _timestamp="2020/06/10 10:15:53";
  local _namespace="my-script";
  local _categoryPrefix="func1:func2";
  local _levelPrefix="O";
  local _expected="[ ${_timestamp} < ${_namespace} | ${_categoryPrefix} > ${_levelPrefix} ]";
  LOGGING.processLogPrefixTokensWithValues "${_timestamp}" "${_namespace}" "${_categoryPrefix}" "${_levelPrefix}";

  LOGGING.getLogPrefixTokensVariableName;
  local -n _logPrefixTokens=${RESULT};
  local _actual="${_logPrefixTokens[@]}";
  Assert.isNotEmpty "${_actual}" "LOGGING.processLogPrefixTokensWithValues built an empty array";
  Assert.areEqual "${_expected}" "${_actual}" "LOGGING.processLogPrefixTokens failed";
}

function LOGGING.buildLogCategoryPrefix_works_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT})is not empty after emptying log category stack";

  local _category="myCategory";
  LOGGING.pushLogCategory "${_category}";

  LOGGING.getLogPrefixCategorySeparator;
  local _separator="${RESULT}"

  LOGGING.getLogCategoryStackVariableName;
  local -n _logCategories=${RESULT};

  LOGGING.buildLogCategoryPrefix "${_separator}";
  local _actual="${RESULT}";

  Assert.isNotEmpty "${_actual}" "LOGGING.buildLogCategoryPrefix '${_separator}' returned an empty prefix";
  Assert.areEqual "${_category}" "${_actual}" "LOGGING.buildLogCategoryPrefix '${_separator}' failed";
}

function LOGGING.buildLogCategoryPrefix_does_not_include_DW_LOGGING_EMPTY_LOG_CATEGORY_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT})is not empty after emptying log category stack";

  LOGGING.pushLogCategory "${DW_LOGGING_EMPTY_LOG_CATEGORY}";

  LOGGING.getLogPrefixCategorySeparator;
  local _separator="${RESULT}"

  LOGGING.buildLogCategoryPrefix "${_separator}";
  local _actual="${RESULT}";

  Assert.isNotEmpty "${_actual}" "LOGGING.buildLogCategoryPrefix '${_separator}' returned an empty prefix";
  Assert.contains "${_actual}" "${DW_LOGGING_EMPTY_LOG_CATEGORY}" "LOGGING.buildLogCategoryPrefix '${_separator}' failed";
}

function alignRight_works_test() {
  local _message="test";
  local _outcome="done";
  local -i _width=80;
  LOGGING.alignRightForWidth "${_message}" "${_outcome}" ${_width};
  local -i _rescode=$?;
  local -i _width=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth '${_message}' '${_outcome}' ${_width} failed";
  Assert.areEqual 69 ${_width} "LOGGING.alignRightForWidth '${_message}' '${_outcome}' ${_width} failed";
}

function buildDefaultLogCategory_works_test() {
  LOGGING.buildDefaultLogCategory;
  local _actual="${RESULT}";
  local _expected="${FUNCNAME[0]}";
  Assert.isNotEmpty "${_actual}" "LOGGING.buildDefaultLogCategory returned an empty string";
  Assert.areEqual "${_expected}" "${_actual}" "LOGGING.buildDefaultLogCategory failed";
}

function buildDefaultLogCategory_works_in_a_second_scenario_test() {
  LOGGING.buildDefaultLogCategory;
  local _actual="${RESULT}";
  local _expected="${FUNCNAME[0]}";
  Assert.isNotEmpty "${_actual}" "LOGGING.buildDefaultLogCategory returned an empty string";
  Assert.areEqual "${_expected}" "${_actual}" "LOGGING.buildDefaultLogCategory failed";
}

# helper function
function empty_log_category() {
  local _oldIFS="${IFS}";
  LOGGING.popLogCategory;
  local -i _rescode=$?;
  local _category="${RESULT}";
  IFS="${DWIFS}";
  while isTrue ${_rescode}; do
    IFS="${_oldIFS}";
    LOGGING.popLogCategory;
    _rescode=$?;
    _category="${RESULT}";
  done
  IFS="${_oldIFS}";
  LOGGING.peekLogCategory;
  _category="${RESULT}";
  export RESULT="${_category}";
  isEmpty "${_category}";
  return $?;
}

function an_initial_LOGGING.logStuff_INFO_minusN_pushes_the_log_category_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT})is not empty after emptying log category stack";

  LOGGING.logStuff INFO -n "test";
  LOGGING.peekLogCategory;
  local _category="${RESULT}";
  logInfoResult SUCCESS "done";
  Assert.isNotEmpty "${_category}" "logInfo -n 'test' does not push the log category";
  Assert.areEqual "${FUNCNAME[0]}" "${_category}" "logInfo -n 'test' does not push ${FUNCNAME[0]} as log category";
}

function an_initial_LOGGING.logStuffResult_SUCCESS_done_leaves_the_log_category_blank_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT}) is not empty after emptying log category stack";

  LOGGING.logStuff INFO -n "test";
  LOGGING.logCompletedNoNested SUCCESS "done";
  LOGGING.peekLogCategory;
  local _category="${RESULT}";
  Assert.isEmpty "${_category}" "LOGGING.logStuff INFO -n 'test' followed by LOGGING.logCompletedNoNested 'done' don't leave the log category stack empty";
}

function LOGGING.peekLogCategory_returns_the_empty_string_if_the_log_category_stack_is_empty_test() {
  empty_log_category;
  LOGGING.peekLogCategory;
  local _actual="${RESULT}";
  Assert.isEmpty "${_actual}" "LOGGING.peekLogCategory does not return the empty string when the stack is empty";
}

function LOGGING.isNewCategoryNeeded_returns_true_if_log_category_stack_is_empty_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT}) is not empty after emptying log category stack";

  LOGGING.isNewLogCategoryNeeded "${FUNCNAME[0]}";
  local -i _rescode=$?;
  Assert.isTrue ${_rescode} "LOGGING.isNewLogCategoryNeeded returned FALSE when the stack is empty";
}

function LOGGING.isNewCategoryNeeded_returns_false_if_the_top_of_the_log_category_stack_already_is_the_current_log_category_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT}) is not empty after emptying log category stack";

  LOGGING.pushLogCategory "sample";
  LOGGING.isNewLogCategoryNeeded "sample";
  local -i _rescode=$?;
  Assert.isFalse ${_rescode} "LOGGING.isNewLogCategoryNeeded returned TRUE if the top of the log category stack already is the current log category";
}

function LOGGING.logInProgress_INFO_pushes_the_function_name_as_log_category_test() {
  empty_log_category;
  Assert.isTrue $? "Log category (${RESULT}) is not empty after emptying log category stack";

  LOGGING.logInProgress INFO " ";
  LOGGING.peekLogCategory;
  local _category="${RESULT}";
  Assert.isNotEmpty "${_category}" "LOGGING.logInProgress INFO ' ' does not push the log category";
  Assert.areEqual "${FUNCNAME[0]}" "${_category}" "LOGGING.logInProgress INFO ' ' does not push ${FUNCNAME[0]} as log category";
}

function log_category_is_the_name_of_the_function_by_default_test() {
  logInfo -n "This is a INFO message";
  getLogCategory;
  local _category="${RESULT}";
  logResult SUCCESS "done";
  Assert.contains "${_category}" "${FUNCNAME[0]}" "Log category (${_category}) is not the function name ${FUNCNAME[0]} by default";
}

function log_category_is_the_name_of_the_function_by_default_test() {
  logInfo -n "This is a INFO message";
  getLogCategory;
  local _category="${RESULT}";
  logResult SUCCESS "done";
  Assert.contains "${_category}" "${FUNCNAME[0]}" "Log category (${_category}) is not the function name ${FUNCNAME[0]} by default";
}

function nested_log_category_is_the_name_of_the_function_by_default_test() {
  logInfo -n "This is a INFO message";
  getLogCategory;
  local _parentCategory="${RESULT}";
  Assert.contains "${_parentCategory}" "${FUNCNAME[0]}" "Category (${_parentCategory}) is not the function name ${FUNCNAME[0]} by default";
  logInfo "This is a nested message";
  getLogCategory;
  local _childCategory="${RESULT}";
  logResult SUCCESS "done";
  Assert.contains "${_childCategory}" "${FUNCNAME[0]}" "Category (${_childCategory}) is not the function name ${FUNCNAME[0]} by default";
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
