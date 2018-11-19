#!/bin/bash

cp ../src/modules/*.dw ~/.dry-wit/modules/;

for _f in *-tests.sh; do
  rm -f /tmp/${_f}* 2> /dev/null
  ./${_f};
  cat /tmp/${_f}* 2> /dev/null
done
