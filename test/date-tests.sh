#!/usr/bin/env dry-wit

DW.import date

function date2jd_known_date_test() {
  date2jd 1970 1 1
  Assert.areEqual 40587 "${RESULT}" "date2jd 1970-1-1 should be 40587"
}

function date2jds_known_timestamp_test() {
  date2jds 1970 1 1 0 0 0
  Assert.areEqual $((40587*86400)) "${RESULT}" "date2jds epoch"
}

function jd2date_round_trip_test() {
  date2jd 2000 3 1
  local jd="${RESULT}"
  jd2date "${jd}"
  Assert.areEqual "2000 3 1" "${RESULT}" "jd2date round trip failed"
}

function jds2date_round_trip_test() {
  date2jds 2000 3 1 4 5 6
  local ts="${RESULT}"
  jds2date "${ts}"
  Assert.areEqual "2000 3 1 4 5 6" "${RESULT}" "jds2date round trip failed"
}

setScriptDescription "Runs tests for date.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
