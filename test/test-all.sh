#!/bin/bash

cp ../src/modules/*.dw ~/.dry-wit/src/modules/;
cp ../src/dry-wit* ~/.dry-wit/src/;

for _f in *-tests.sh; do
  rm -f /tmp/${_f}* 2> /dev/null
	echo "Running ./${_f}";
  ./${_f};
  cat /tmp/${_f}* 2> /dev/null
done
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
