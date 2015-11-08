function checkInput() {
  local _flags=$(extractFlags $@);
  logDebug -n "Checking input";
  for _flag in ${_flags}; do
    case ${_flag} in
      -h | --help | -v | -vv | -f | --my-flag)
	 ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
}
