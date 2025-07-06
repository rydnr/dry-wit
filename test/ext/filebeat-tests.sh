#!/usr/bin/env dry-wit

DW.import filebeat

function addLogFile_when_comment_present_test() {
  local tmp
  tmp=$(mktemp)
  echo '#        - /var/log/*.log' > "$tmp"
  configureFilebeatToAddLogFileToForward '/var/log/app.log' "$tmp" < "$tmp"
  local res=$?
  grep -q '/var/log/app.log' "$tmp"
  local found=$?
  rm -f "$tmp"
  Assert.isTrue ${res} 'configureFilebeatToAddLogFileToForward failed'
  Assert.isTrue ${found} 'Log file not added'
}

function addLogFile_when_line_present_test() {
  local tmp
  tmp=$(mktemp)
  echo '        - /var/log/*.log' > "$tmp"
  configureFilebeatToAddLogFileToForward '/var/log/app.log' "$tmp" < "$tmp"
  local res=$?
  grep -q '/var/log/app.log' "$tmp"
  local found=$?
  rm -f "$tmp"
  Assert.isTrue ${res} 'configureFilebeatToAddLogFileToForward failed'
  Assert.isTrue ${found} 'Log file not added'
}

setScriptDescription "Runs tests for filebeat.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
