#!/usr/bin/env dry-wit

DW.import package

function isInstalled_returns_true_for_known_command_test() {
  isInstalled ls
  Assert.isTrue $? "ls should be installed"
}

function isInstalled_returns_false_for_unknown_command_test() {
  isInstalled no-such-command-xyz >/dev/null 2>&1
  Assert.isFalse $? "Unknown command should not be installed"
}

setScriptDescription "Runs tests for package.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
