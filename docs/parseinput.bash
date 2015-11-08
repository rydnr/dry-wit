function parseInput() {
  local _flags=$(extractFlags $@);
  for _flag in ${_flags}; do
    case ${_flag} in
      -f | --my-flag)
        shift;
        export MY_FLAG="${1}";
        shift;
        ;;
      *) shift;
        ;;
    esac
  done
}
