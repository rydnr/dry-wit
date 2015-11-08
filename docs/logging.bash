logInfo -n "Calculating next prime number ...";
...
if [ $? -eq 0 ]; then
  logInfoResult SUCCESS "done";
else
  logInfoResult FAILURE "Too optimistic";
fi
