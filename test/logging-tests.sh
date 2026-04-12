#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

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

function LOGGING.alignRightForWidth_finds_the_correct_offset_test() {
  local -i _termWidth=212;
  local _logMessage="[2020/06/11 18:28:52<logging-tests|myCategory>.] LOGGING.buildLogCategoryPrefix works";
  local _outcome="did not pass";
  LOGGING.processLogOutcomeTokens "${_outcome}";
  LOGGING.logOutcomeTokensLength;
  local -i _logOutcomeTokensLength=${RESULT};
  LOGGING.alignRightForWidth "${_logMessage}" ${_termWidth};
  local -i _rescode=$?;
  local -i _actual=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  local -i _expected=$((${_termWidth}-(${#_logMessage}+${_logOutcomeTokensLength})%${_termWidth} + 1));
  Assert.areEqual ${_expected} ${_actual} "LOGGING.alignRightForWidth doesn't find the correct offset in nested logging";
}

function LOGGING.alignRightForWidth_finds_the_correct_offset_in_nested_logging_test() {
  local -i _termWidth=212;
  local _message="This is a INFO message";
  local _logMessage="[2020/06/11 18:43:14<logging-tests|main:aeourch:3138465:.apurchoaekj/olekh:main:the_log_category_is_propagated_to_nested_logging_test>.] ${_message}";
  local _outcome="....";
  LOGGING.processLogOutcomeTokens "${_outcome}";
  LOGGING.logOutcomeTokensLength;
  local -i _logOutcomeTokensLength=${RESULT};
  LOGGING.alignRightForWidth "${_logMessage}" ${_termWidth};
  local -i _rescode=$?;
  local -i _actual=${RESULT};
  Assert.isTrue ${_rescode} "LOGGING.alignRightForWidth returned FALSE";
  local -i _expected=$((${_termWidth}-(${#_logMessage}+${_logOutcomeTokensLength})%${_termWidth} + 1));
  Assert.areEqual ${_expected} ${_actual} "LOGGING.alignRightForWidth doesn't find the correct offset in nested logging";
}

function LOGGING.retrieveBackend_falls_back_to_standard_for_unknown_values_test() {
  export LOGGING_BACKEND="unsupported-backend";

  LOGGING.retrieveBackend;

  Assert.areEqual "standard" "${RESULT}" "LOGGING.retrieveBackend should fall back to standard";
}

function LOGGING.retrieveBackend_keeps_supported_values_test() {
  export LOGGING_BACKEND="simple";

  LOGGING.retrieveBackend;

  Assert.areEqual "simple" "${RESULT}" "LOGGING.retrieveBackend should keep supported values";
}

function LOGGING.retrieveBackend_falls_back_to_standard_when_native_helper_is_missing_test() {
  export LOGGING_BACKEND="native-c";
  unset DW_NATIVE_LOGGER_BIN;

  LOGGING.retrieveBackend;

  Assert.areEqual "standard" "${RESULT}" "LOGGING.retrieveBackend should fall back when native helper is unavailable";
}

function LOGGING.retrieveBackend_keeps_native_backend_when_helper_is_available_test() {
  export LOGGING_BACKEND="native-c";
  export DW_NATIVE_LOGGER_BIN="$(mktemp /tmp/dry-wit-native-logger-test.XXXXXX)";
  printf '#!/usr/bin/env bash\nexit 0\n' > "${DW_NATIVE_LOGGER_BIN}";
  chmod +x "${DW_NATIVE_LOGGER_BIN}";

  LOGGING.retrieveBackend;
  local _actual="${RESULT}";

  rm -f "${DW_NATIVE_LOGGER_BIN}";
  unset DW_NATIVE_LOGGER_BIN;

  Assert.areEqual "native-c" "${_actual}" "LOGGING.retrieveBackend should keep native-c when helper exists";
}

function LOGGING.retrieveNativeLoggerTransport_falls_back_to_auto_for_unknown_values_test() {
  export DW_NATIVE_LOGGER_TRANSPORT="unsupported-transport";

  LOGGING.retrieveNativeLoggerTransport;

  Assert.areEqual "auto" "${RESULT}" "LOGGING.retrieveNativeLoggerTransport should fall back to auto";
}

function LOGGING.retrieveNativeLoggerTransport_keeps_supported_values_test() {
  export DW_NATIVE_LOGGER_TRANSPORT="spawn";

  LOGGING.retrieveNativeLoggerTransport;

  Assert.areEqual "spawn" "${RESULT}" "LOGGING.retrieveNativeLoggerTransport should keep supported values";
}

function LOGGING.retrieveRightAlignmentMode_falls_back_to_auto_for_unknown_values_test() {
  export LOGGING_RIGHT_ALIGNMENT_MODE="unsupported-mode";

  LOGGING.retrieveRightAlignmentMode;

  Assert.areEqual "auto" "${RESULT}" "LOGGING.retrieveRightAlignmentMode should fall back to auto";
}

function LOGGING.retrieveRightAlignmentMode_keeps_supported_values_test() {
  export LOGGING_RIGHT_ALIGNMENT_MODE="cursor";

  LOGGING.retrieveRightAlignmentMode;

  Assert.areEqual "cursor" "${RESULT}" "LOGGING.retrieveRightAlignmentMode should keep supported values";
}

function LOGGING.areHotPathChecksEnabled_is_enabled_by_default_test() {
  unset ENABLE_LOGGING_HOT_PATH_CHECKS;

  LOGGING.areHotPathChecksEnabled;

  Assert.isTrue $? "Hot-path checks should be enabled by default";
}

function LOGGING.areHotPathChecksEnabled_can_be_disabled_test() {
  export ENABLE_LOGGING_HOT_PATH_CHECKS=${FALSE};

  LOGGING.areHotPathChecksEnabled;

  Assert.isFalse $? "Hot-path checks should be disabled when requested";
}

function LOGGING.areSpansEnabled_is_disabled_by_default_test() {
  unset ENABLE_LOGGING_SPANS;

  LOGGING.areSpansEnabled;

  Assert.isFalse $? "Span profiling should be disabled by default";
}

function LOGGING.areSpansEnabled_can_be_enabled_test() {
  export ENABLE_LOGGING_SPANS=${TRUE};

  LOGGING.areSpansEnabled;

  Assert.isTrue $? "Span profiling should be enabled when requested";
}

function LOGGING.captureCurrentLogLineLength_uses_cached_prefix_length_test() {
  LOGGING.setLastLogPrefixLength 7;

  LOGGING.captureCurrentLogLineLength "hello";
  LOGGING.getCurrentLogLineLength;

  Assert.areEqual 12 "${RESULT}" "LOGGING.captureCurrentLogLineLength should add message length to prefix length";
}

function LOGGING.retrieveActiveLogLineLength_prefers_cached_length_test() {
  LOGGING.setCurrentLogLineLength 33;

  LOGGING.retrieveActiveLogLineLength;

  Assert.areEqual 33 "${RESULT}" "LOGGING.retrieveActiveLogLineLength should reuse cached line length";
}

setScriptDescription "Runs all tests implemented for logging.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
