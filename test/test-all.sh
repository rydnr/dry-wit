#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_HOME="$(mktemp -d /tmp/dry-wit-test-home.XXXXXX)"
trap 'rm -rf "${TEST_HOME}"' EXIT

mkdir -p "${TEST_HOME}/.dry-wit/src/modules"
cp "${REPO_DIR}"/src/modules/*.dw "${TEST_HOME}/.dry-wit/src/modules/" 2>/dev/null
cp "${REPO_DIR}"/src/dry-wit* "${TEST_HOME}/.dry-wit/src/" 2>/dev/null

export HOME="${TEST_HOME}"
export PATH="${REPO_DIR}/src:${PATH}"

declare -i TOTAL_TESTS=0
declare -i TOTAL_PASSED_TESTS=0
declare -i TOTAL_FAILED_TESTS=0

cd "${SCRIPT_DIR}" || exit 1

for _f in $(find . -name '*-tests.sh'); do
  rm -f /tmp/${_f}* 2>/dev/null
  ./${_f}
  if [[ -f "./.$(basename ${_f}).env" ]]; then
    source "./.$(basename ${_f}).env"
  fi
  TOTAL_TESTS=$((TOTAL_TESTS + TESTS_FOUND))
  TOTAL_PASSED_TESTS=$((TOTAL_PASSED_TESTS + PASSED_TESTS))
  TOTAL_FAILED_TESTS=$((TOTAL_FAILED_TESTS + FAILED_TESTS))
  cat /tmp/${_f}* 2>/dev/null
done
echo "Total tests: ${TOTAL_TESTS}"
echo "Passed tests: ${TOTAL_PASSED_TESTS}"
echo "Failed tests: ${TOTAL_FAILED_TESTS}"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
