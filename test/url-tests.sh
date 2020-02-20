#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function urlEncode_works_test() {
  DW.import url;
  local _expectedEncodedUrl="https%3A%2F%2Fwww.example.com";
  local _targetUrl='https://www.example.com';
  local _actualEncodedUrl="$(urlEncode "${_targetUrl}")";
  local _rescode=$?;
  Assert.isTrue ${_rescode} "urlEncode \"${_targetUrl}\" failed";
  Assert.areEqual "${_expectedEncodedUrl}" "${_actualEncodedUrl}" "urlEncode \"${_targetUrl}\" returned an invalid value (${_actualEncodedValue})";
}

function extractPathSegmentFromUrl_works_test() {
  DW.import url;
  local _expectedPathSegment="segment0";
  local _targetUrl='https://www.example.com/segment0/segment1/segment2/lastSegment?queryParamName0=queryParamValue0&queryParamName1=queryParamValue1;part';
  extractPathSegmentFromUrl "${_targetUrl}" 0;
  local _rescode=$?;
  local _actualPathSegment="${RESULT}";
  Assert.isTrue ${_rescode} "extractPathSegmentFromUrl \"${_targetUrl}\" 0 failed";
  Assert.areEqual "${_expectedPathSegment}" "${_actualPathSegment}" "extractPathSegmentFromUrl \"${_targetUrl}\" 0 returned an invalid value (${_actualPathSegment})";
  _expectedPathSegment="segment1";
  extractPathSegmentFromUrl "${_targetUrl}" 1;
  _rescode=$?;
  _actualPathSegment="${RESULT}";
  Assert.isTrue ${_rescode} "extractPathSegmentFromUrl \"${_targetUrl}\" 1 failed";
  Assert.areEqual "${_expectedPathSegment}" "${_actualPathSegment}" "extractPathSegmentFromUrl \"${_targetUrl}\" 1 returned an invalid value (${_actualPathSegment})";
}

setScriptDescription "Runs all tests implemented for url.dw";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
