This is dry-wit, a framework for bash scripts.

This project is useful when writing new scripts. It provides a common
layout and a toolbox of functions to help writing shell scripts from
scratch.

Since Bash is an interpreted language, you can review the contents of
dry-wit yourself.

Basically, in order to write dry-wit scripts you'll do the following:

- Copy or symlink the file 'dry-wit' in your /usr/local/bin folder.
- Put
#!/bin/bash /usr/local/bin/dry-wit
as the first line of your script.
- Write the mandatory functions:
usage()
checkRequirements()
defineEnv()
defineErrors()
checkInput()
main()

The usage() function takes care of the documentation of the script
itself, including parameters, flags, etc. The environment variables
and exit codes are managed automatically for you (as long as you
implement checkRequirements(), defineEnv() and defineErrors()).

checkInput() is responsible of validating the input parameters and
setting the global-scoped script variables. It would use the provided
built-in features to parse flags (better than 'getopts' since it
allows you to support both short- and long-version flags), included
the -v[v[v]] and -h|--help flags.

The main() function is the starting point of your script. You don't
need to care about anything but the funcional requirements of your
script.
