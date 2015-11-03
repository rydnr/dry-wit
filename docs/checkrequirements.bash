function checkRequirements() {
  checkReq docker DOCKER_NOT_INSTALLED;
  checkReq realpath REALPATH_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
}
