#!/usr/bin/env dry-wit

DW.import jetty

function updateKeyStorePath_updates_value_test() {
  local tmp
  tmp=$(mktemp)
  echo '<Set name="KeyStorePath">old</Set>' > "$tmp"
  updateKeyStorePathInJettyConf '/new/path' "$tmp"
  local res=$?
  local line
  line=$(cat "$tmp")
  rm -f "$tmp"
  Assert.isTrue ${res} 'updateKeyStorePathInJettyConf failed'
  Assert.areEqual '<Set name="KeyStorePath">/new/path</Set>' "${line}" 'not replaced'
}

function supportForSni_rewrites_class_test() {
  local tmp
  tmp=$(mktemp)
  echo '<New id="sslContextFactory" class="org.eclipse.jetty.util.ssl.SslContextFactory">' > "$tmp"
  supportForSniInJettyConf "$tmp"
  local res=$?
  local line
  line=$(cat "$tmp")
  rm -f "$tmp"
  Assert.isTrue ${res} 'supportForSniInJettyConf failed'
  Assert.areEqual '<New id="sslContextFactory" class="org.eclipse.jetty.util.ssl.SslContextFactory$Server">' "${line}" 'class not updated'
}

function appendUpdateMark_appends_line_test() {
  local tmp
  tmp=$(mktemp)
  echo 'abc' > "$tmp"
  appendUpdateMarkInJettyConf "$tmp"
  local res=$?
  tail -n 1 "$tmp" | grep -q 'Updated by'
  local found=$?
  rm -f "$tmp"
  Assert.isTrue ${res} 'appendUpdateMarkInJettyConf failed'
  Assert.isTrue ${found} 'mark not appended'
}

setScriptDescription "Runs tests for jetty.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
