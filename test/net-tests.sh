#!/usr/bin/env dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

DW.import net

function retrieveOwnIp_works_test() {
  if retrieveOwnIp; then
    Assert.isNotEmpty "${RESULT}" "IP is empty"
  else
    Assert.fail "retrieveOwnIp failed"
  fi
}

setScriptDescription "Runs all tests implemented for net.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
