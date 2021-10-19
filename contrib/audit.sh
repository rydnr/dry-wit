#!/usr/bin/env bash

# From https://gist.github.com/wlib/093f8b8f670016813073a4c4f8b28e81
#
# Just so we can skip the first command - running the first argument
SKIP=true

function prompt {
  if [[ "$SKIP" == true ]]; then
    SKIP=false
    return
  fi

  if [[ -n "$BASH_COMMAND" ]]; then
    # Show the command in green with a simple -> prompt
    echo -n -e "-> \x1B[0;32m"
    echo -n $BASH_COMMAND
    echo -e "\x1B[0m"

    # Loop user input until a valid answer comes
    while true; do
      # Ask for only a single character of input, so the user does not need to type an extra enter
      read -n1 -s -p "Run command? [Y/n] "
      echo

      case "$REPLY" in
        "y" | "Y" | "" )
          break
          ;;
        "n" | "N" )
          # Bright red indication that that script stopped
          echo -e "\x1B[1;31mStopped!\x1B[0m"
          exit 1
          ;;
        * )
          echo "Please answer by typing n (for no), y (for yes), or Enter (also for yes)"
          ;;
      esac
    done
  fi
}

# Allow debugging in the file that is being source'd
set -o functrace
# Run the prompt function before each command
trap prompt DEBUG

# Run the first argument
source "$1"
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
