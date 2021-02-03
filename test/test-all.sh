#!/usr/bin/env bash

cp ../src/modules/*.dw ~/.dry-wit/src/modules/ 2> /dev/null;
cp ../src/dry-wit* ~/.dry-wit/src/ 2> /dev/null;

declare -i TOTAL_TESTS=0;
declare -i TOTAL_PASSED_TESTS=0;
declare -i TOTAL_FAILED_TESTS=0;

for _f in $(find . -name '*-tests.sh'); do
  rm -f /tmp/${_f}* 2> /dev/null
  ./${_f};
  if [[ -f "./.$(basename ${_f}).env" ]]; then
    source "./.$(basename ${_f}).env";
  fi
  TOTAL_TESTS=$((TOTAL_TESTS + TESTS_FOUND));
  TOTAL_PASSED_TESTS=$((TOTAL_PASSED_TESTS + PASSED_TESTS));
  TOTAL_FAILED_TESTS=$((TOTAL_FAILED_TESTS + FAILED_TESTS));
  cat /tmp/${_f}* 2> /dev/null
done
echo "Total tests: ${TOTAL_TESTS}";
echo "Passed tests: ${TOTAL_PASSED_TESTS}";
echo "Failed tests: ${TOTAL_FAILED_TESTS}";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
