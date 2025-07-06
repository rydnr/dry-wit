#!/usr/bin/env dry-wit

DW.import cache

function cache_returns_cached_result_test() {
  CALLS=0
  function _inc1() {
    CALLS=$((CALLS+1))
    export RESULT=${CALLS}
    return 0
  }
  cache _inc1
  local first="${RESULT}"
  cache _inc1
  local second="${RESULT}"
  Assert.areEqual "${first}" "${second}" "cache did not return cached result"
  Assert.areEqual 1 "${CALLS}" "function ran more than once"
}

function uncache_allows_reexecution_test() {
  CALLS=0
  function _inc2() {
    CALLS=$((CALLS+1))
    export RESULT=${CALLS}
    return 0
  }
  uncache _inc2
  cache _inc2
  cache _inc2
  Assert.areEqual 1 "${CALLS}" "function should run only once before uncache"
  uncache _inc2
  cache _inc2
  Assert.areEqual 2 "${RESULT}" "function did not run after uncache"
}

setScriptDescription "Runs tests for cache.dw"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
