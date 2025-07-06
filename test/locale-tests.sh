#!/usr/bin/env dry-wit

DW.import locale

function LOCALE.getModuleName_returns_LOCALE_test() {
  LOCALE.getModuleName
  Assert.areEqual LOCALE "${RESULT}" "Module name should be LOCALE"
}

function isLocaleFileAvailable_returns_true_when_file_exists_test() {
  local tmp
  tmp=$(mktemp -d)
  export AVAILABLE_LOCALES_FOLDER="${tmp}"
  touch "${tmp}/en"
  isLocaleFileAvailable en_US
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "File should be detected"
}

function isLocaleSupported_when_locale_present_test() {
  local tmp
  tmp=$(mktemp -d)
  export AVAILABLE_LOCALES_FOLDER="${tmp}"
  touch "${tmp}/en"
  export SUPPORTED_LOCALES_FILE="${tmp}/supported"
  echo "en_US.UTF-8 UTF-8" > "${SUPPORTED_LOCALES_FILE}"
  isLocaleSupported en_US UTF-8
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "Locale should be supported"
}

function localeRequiresEncodingSuffix_detects_need_test() {
  local tmp
  tmp=$(mktemp -d)
  export SUPPORTED_LOCALES_FILE="${tmp}/supported"
  echo "en_US.UTF-8 UTF-8" > "${SUPPORTED_LOCALES_FILE}"
  localeRequiresEncodingSuffix en_US UTF-8
  local res=$?
  rm -rf "${tmp}"
  Assert.isTrue ${res} "Encoding suffix should be required"
}

setScriptDescription "Runs tests for locale.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
