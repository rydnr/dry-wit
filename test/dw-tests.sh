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

Runs all tests implemented for dry-wit itself.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the errors.
## dry-wit hook
function defineErrors() {
  addError "PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H" "The _parseCommonInput method does not support -h";
}

## Tests for dry-wit's _parseCommonInput.
function _parseCommonInput_test() {

  _parseCommonInput "-h";
  assertNoErrorThrown PARSECOMMONINPUT_DOES_NOT_SUPPORT_SMALL_H;
}

function _other_test() {
  echo "other test";
}
