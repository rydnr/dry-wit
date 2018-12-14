#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function retrieveOwnIp_test() {
  local _ip;
  local -i _rescode;

  DW.import net;

  retrieveOwnIp;
  _rescode=$?;
  _ip="${RESULT}";
  Assert.isTrue $? "retrieveOwnIp failed";
  Assert.isNotEmpty "${_ip}" "IP is empty";
}

setScriptDescription "Runs all tests implemented for net.dw.";
