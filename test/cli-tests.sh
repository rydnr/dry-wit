#!/bin/bash ../src/dry-wit-test
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# set -o xtrace

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2016-today ACM-SL
    Distributed this under the GNU General Public License v3.

Runs all tests implemented for cli.dw.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

import cli;

commandLineFlagCallbackCalled=${FALSE};

function commandLineFlagCallback() {
  commandLineFlagCallbackCalled=${TRUE};
}

function addCommandLineFlag_test() {
  addCommandLineFlag "f" "file" TRUE commandLineFlagCallback;
  parseInput "-f" "/tmp/1.txt";
  Assert.isTrue ${commandLineFlagCallbackCalled} "callback not called in parseInput";
}

