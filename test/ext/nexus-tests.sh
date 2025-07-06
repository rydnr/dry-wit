#!/usr/bin/env dry-wit

DW.import nexus

function appendLogConfigDir_updates_file_test() {
  createTempFile
  local file="${RESULT}"
  appendLogConfigDirToNexusSystemProperties "${file}" "/var/log/nexus"
  local res=$?
  local line
  line="$(cat "${file}")"
  rm -f "${file}"
  Assert.isTrue ${res} "appendLogConfigDir failed"
  Assert.areEqual "nexus.log-config-dir=/var/log/nexus" "${line}" "line mismatch"
}

function appendWorkDir_updates_file_test() {
  createTempFile
  local file="${RESULT}"
  appendWorkDirInNexusSystemProperties "${file}" "/opt/work"
  local res=$?
  local line
  line="$(cat "${file}")"
  rm -f "${file}"
  Assert.isTrue ${res} "appendWorkDir failed"
  Assert.areEqual "nexus.work-dir=/opt/work" "${line}" "line mismatch"
}

function enableJettyHttpsConfig_inserts_line_test() {
  createTempFile
  local input="${RESULT}"
  echo 'nexus-args=foo' > "${input}"
  createTempFile
  local output="${RESULT}"
  enableJettyHttpsConfigInNexusCfg "${input}" "${output}"
  local res=$?
  local line
  line="$(cat "${output}")"
  rm -f "${input}" "${output}"
  Assert.isTrue ${res} "enableJettyHttpsConfigInNexusCfg failed"
  Assert.areEqual 'nexus-args=foo,${jetty.etc}/jetty-https.xml' "${line}" "line mismatch"
}

function appendHttpsConnectorPort_appends_line_test() {
  createTempFile
  local cfg="${RESULT}"
  appendHttpsConnectorPortToNexusCfg "${cfg}" 8443
  local res=$?
  local line
  line="$(cat "${cfg}")"
  rm -f "${cfg}"
  Assert.isTrue ${res} "appendHttpsConnectorPortToNexusCfg failed"
  Assert.areEqual 'application-port-ssl=8443' "${line}" "line mismatch"
}

function appendSslEtc_appends_line_test() {
  createTempFile
  local file="${RESULT}"
  appendSslEtcInNexusSystemProperties "${file}" "/etc/ssl"
  local res=$?
  local line
  line="$(cat "${file}")"
  rm -f "${file}"
  Assert.isTrue ${res} "appendSslEtcInNexusSystemProperties failed"
  Assert.areEqual 'ssl.etc=/etc/ssl' "${line}" "line mismatch"
}

function appendUpdateMarkInNexusSystemProperties_appends_mark_test() {
  createTempFile
  local file="${RESULT}"
  appendUpdateMarkInNexusSystemProperties "${file}"
  local res=$?
  local mark
  mark="$(tail -n 1 "${file}")"
  DW.getScriptName
  local script="${RESULT}"
  rm -f "${file}"
  Assert.isTrue ${res} "appendUpdateMarkInNexusSystemProperties failed"
  Assert.contains "${mark}" "Updated by ${script}" "missing mark"
}

function nexusSystemPropertiesAlreadyUpdated_detects_mark_test() {
  createTempFile
  local file="${RESULT}"
  DW.getScriptName
  local script="${RESULT}"
  echo "# Updated by ${script} at 0" > "${file}"
  nexusSystemPropertiesAlreadyUpdated "${file}"
  local res=$?
  rm -f "${file}"
  Assert.isTrue ${res} "nexusSystemPropertiesAlreadyUpdated failed"
}

function appendUpdateMarkInNexusCfg_appends_mark_test() {
  createTempFile
  local cfg="${RESULT}"
  appendUpdateMarkInNexusCfg "${cfg}"
  local res=$?
  local mark
  mark="$(tail -n 1 "${cfg}")"
  DW.getScriptName
  local script="${RESULT}"
  rm -f "${cfg}"
  Assert.isTrue ${res} "appendUpdateMarkInNexusCfg failed"
  Assert.contains "${mark}" "Updated by ${script}" "missing mark"
}

function nexusCfgAlreadyUpdated_detects_mark_test() {
  createTempFile
  local cfg="${RESULT}"
  DW.getScriptName
  local script="${RESULT}"
  echo "# Updated by ${script} at 0" > "${cfg}"
  nexusCfgAlreadyUpdated "${cfg}"
  local res=$?
  rm -f "${cfg}"
  Assert.isTrue ${res} "nexusCfgAlreadyUpdated failed"
}

setScriptDescription "Runs tests for nexus.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
