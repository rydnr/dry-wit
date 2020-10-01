#!/bin/bash dry-wit
# Copyright 2020-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function evalConstant_works_for_predefined_colors_test() {
  local _expected=GRAY;
  local _colorName=NO_COLOR;
  DW.getGlobalVariableName COLOR "${_colorName}";
  local _constant="${RESULT}";
  evalConstant ${_constant};
  local -i _rescode=$?;
  local _actual="${RESULT}";
  Assert.isTrue ${_rescode} "evalConstant ${_constant} returned false";
  Assert.areEqual "${_expected}" "${_actual}" "evalConstant ${_constant} failed";
}

setScriptDescription "Runs all tests implemented for constant.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
