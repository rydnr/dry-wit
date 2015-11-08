function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export DOCKER_NOT_INSTALLED="docker is not installed. See http://www.docker.org";
  export REPOSITORY_IS_MANDATORY="The repository argument is mandatory";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    DOCKER_NOT_INSTALLED \
    REPOSITORY_IS_MANDATORY \
  );
  export ERROR_MESSAGES;
}
