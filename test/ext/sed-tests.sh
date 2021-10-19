#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

DW.import sed;

function safeSedReplacement_works_test() {
  local _text='$m^\\y/t(e)x+t[ ]';
  local _result;
  _result="$(echo "'foo'='|foo|'" | safeSedReplacement "|foo|" "${_text}")";
  local _rescode=$?;
  Assert.isTrue ${_rescode} "echo \"'foo'='|foo|'\" | safeSedReplacement \"|foo|\" \"${_text}\" failed";
  Assert.areEqual "'foo'='${_text}'" "${_result}" "echo \"'foo'='|foo|'\" | safeSedReplacement \"|foo|\" \"${_text}\" failed";
}

function safeSedReplacement_works_for_removing_text_test() {
  local _result;
  _result="$(echo "'foo'='|foo|'" | safeSedReplacement "|foo|" "")";
  local _rescode=$?;
  Assert.isTrue ${_rescode} "echo \"'foo'='|foo|'\" | safeSedReplacement \"|foo|\" \"\" failed";
  Assert.areEqual "'foo'=''" "${_result}" "echo \"'foo'='|foo|'\" | safeSedReplacement \"|foo|\" \"\" failed";
}

function safeMinusIReplacement_works_test() {
  local _text='$m^\\y/t(e)x+t[ ]';
  local _result;
  createTempFile;
  local _file="${RESULT}";
  echo "'foo'='|foo|'" > "${_file}";
  safeSedMinusIReplacement "|foo|" "${_text}" "${_file}";
  _result="$(cat "${_file}")";
  local _rescode=$?;
  Assert.isTrue ${_rescode} "safeSedReplacement \"|foo|\" \"${_text}\" [file] failed";
  Assert.areEqual "'foo'='${_text}'" "${_result}" "safeSedReplacement \"|foo|\" \"${_text}\" [file] failed";
}

function safeMinusIReplacement_works_for_removing_text_test() {
  local _result;
  createTempFile;
  local _file="${RESULT}";
  echo "'foo'='|foo|'" > "${_file}";
  safeSedMinusIReplacement "|foo|" "" "${_file}";
  _result="$(cat "${_file}")";
  local _rescode=$?;
  Assert.isTrue ${_rescode} "safeSedReplacement \"|foo|\" \"\" [file] failed";
  Assert.areEqual "'foo'=''" "${_result}" "safeSedReplacement \"|foo|\" \"\" [file] failed";
}

setScriptDescription "Runs all tests implemented for sed.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
