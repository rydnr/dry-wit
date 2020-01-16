#!/bin/bash

cp ../src/modules/*.dw ~/.dry-wit/src/modules/ 2> /dev/null;
cp ../src/dry-wit* ~/.dry-wit/src/ 2> /dev/null;

for _f in *-tests.sh; do
  rm -f /tmp/${_f}* 2> /dev/null
  ./${_f};
  cat /tmp/${_f}* 2> /dev/null
done
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
