#!/usr/bin/env dry-wit

DW.import color

function buildColor_creates_variables_test() {
  buildColor MYCLR 31 41
  Assert.areEqual "\\033[0;31m" "${MYCLR_FG}" "Foreground escape incorrect"
  Assert.areEqual "\\033[41m" "${MYCLR_BG}" "Background escape incorrect"
}

function setSuccessColor_and_getSuccessColor_round_trip_test() {
  setSuccessColor MYCLR
  getSuccessColor
  Assert.areEqual MYCLR "${RESULT}" "getSuccessColor didn't return MYCLR"
}

function getColorValue_returns_escape_code_test() {
  buildColor ANOTHER 32 42
  getColorValue ANOTHER
  Assert.areEqual "\\033[0;32m" "${RESULT}" "getColorValue wrong"
}

setScriptDescription "Runs tests for color.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
