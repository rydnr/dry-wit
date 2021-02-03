This is dry-wit, a framework for bash scripts.

This project is useful when writing new scripts. It provides a common
layout and a toolbox of functions to help writing shell scripts from
scratch.

Since Bash is an interpreted language, you can review the contents of
dry-wit yourself.

Basically, in order to write dry-wit scripts you'll do the following:

- Clone this repository under ~/.dry-wit:
  git clone https://github.com/rydnr/dry-wit $HOME/.dry-wit

- Add ~/.dry-wit/src to your PATH:
echo 'export PATH=$PATH:$HOME/.dry-wit/src' >> $HOME/.bashrc

- Use this shebang in your scripts.
#!/usr/bin/env dry-wit

- Write the only mandatory function:
main()

The main() function is the starting point of your script. You don't need to care about anything but the funcional requirements of your script.

Note for Mac OS X users:

- MacOS X comes with an old version of Bash. dry-wit requires Bash 4+. To use a recent version, install homebrew, then bash, and run
chsh -s /usr/local/bin/bash
- Additionally, dry-wit requires the following brew formulae:
  - readlink
  - coreutils
  - pidof

brew install readlink
brew install coreutils
brew install pidof
