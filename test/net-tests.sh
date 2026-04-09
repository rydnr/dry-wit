#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import net

function retrieveOwnIp_works_test() {
  local _originalRetrieveIfaces
  _originalRetrieveIfaces="$(typeset -f retrieveIfaces)"
  local _originalRetrieveIp
  _originalRetrieveIp="$(typeset -f retrieveIp)"
  local _expectedIp="192.0.2.10"

  function retrieveIfaces() {
    export RESULT="eth0"
    return ${TRUE}
  }

  function retrieveIp() {
    export RESULT="${_expectedIp}"
    return ${TRUE}
  }

  if retrieveOwnIp; then
    Assert.areEqual "${_expectedIp}" "${RESULT}" "Unexpected IP"
  else
    Assert.fail "retrieveOwnIp failed"
  fi

  eval "${_originalRetrieveIfaces}"
  eval "${_originalRetrieveIp}"
}

setScriptDescription "Runs all tests implemented for net.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
