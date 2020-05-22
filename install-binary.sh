#!/usr/bin/env bash

# borrowed from https://github.com/technosophos/helm-template

PROJECT_NAME="helm-unittest"
PROJECT_GH="DataDog/$PROJECT_NAME"

: ${HELM_PLUGIN_PATH:="$HELM_PLUGIN_DIR/helm-unittest"}

# Convert the HELM_PLUGIN_PATH to unix if cygpath is
# available. This is the case when using MSYS2 or Cygwin
# on Windows where helm returns a Windows path but we
# need a Unix path
if type cygpath &> /dev/null; then
  HELM_PLUGIN_PATH=$(cygpath -u $HELM_PLUGIN_PATH)
fi

if [[ $SKIP_BIN_INSTALL == "1" ]]; then
  echo "Skipping binary install"
  exit
fi

# installFile verifies the SHA256 for the file, then unpacks and
# installs it.
installFile() {
  echo "Preparing to install into ${HELM_PLUGIN_PATH}"
  make install
  echo "$PROJECT_NAME installed into $HELM_PLUGIN_PATH"
}

# fail_trap is executed if an error occurs.
fail_trap() {
  result=$?
  if [ "$result" != "0" ]; then
    echo "Failed to install $PROJECT_NAME"
    echo "For support, go to https://github.com/kubernetes/helm"
  fi
  exit $result
}

# testVersion tests the installed client to make sure it is working.
testVersion() {
  # To avoid to keep track of the Windows suffix,
  # call the plugin assuming it is in the PATH
  PATH=$PATH:$HELM_PLUGIN_PATH
  untt -h
}

# Execution

#Stop execution on any error
trap "fail_trap" EXIT
set -e
installFile
testVersion