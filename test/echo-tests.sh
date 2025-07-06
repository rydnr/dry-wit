#!/usr/bin/env dry-wit

DW.import echo
DW.import color

function echoColorizedText_with_color_disabled_prints_plain_text_test() {
  ENABLE_COLOR=${FALSE}
  local output="$(echoColorizedText "done")"
  Assert.areEqual "done" "${output}" "Output should be plain text when colors disabled"
}

function echoColorizedTextWithColor_with_n_option_no_color_test() {
  ENABLE_COLOR=${FALSE}
  local output="$(echoColorizedTextWithColor -n RED "ok")"
  Assert.areEqual "ok" "${output}" "-n output incorrect"
}

function echoInColor_without_color_support_prints_plain_text_test() {
  ENABLE_COLOR=${FALSE}
  local output="$(echoInColor BLUE "hello")"
  Assert.areEqual "hello" "${output}" "echoInColor should print plain text"
}

setScriptDescription "Runs tests for echo.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
