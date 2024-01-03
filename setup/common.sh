#!/bin/bash

export IS_MAC=$([ "$(uname -s)" == "Darwin" ] && echo true || echo false)
export IS_LINUX=$([ "$(uname -s)" == "Linux" ] && echo true || echo false)
export IS_UBUNTU=$(grep 'Ubuntu' /etc/os-release >/dev/null 2>&1 && echo true || echo false)
export IS_AL2=$(grep 'Amazon Linux 2' /etc/os-release >/dev/null 2>&1 && echo true || echo false)
export IS_JENKINS=$([ ! -z "${BUILD_NUMBER}" ] && echo true || echo false)
export ARCH=$([ "$(uname -m)" == "x86_64" ] && echo "amd64" || echo "arm64")

if ${IS_MAC} || ${IS_UBUNTU}; then
  INSTALL_DIR="$(realpath ~)/erslocal"
  BIN_DIR="${INSTALL_DIR}/bin"
  mkdir -p ${BIN_DIR}
else
  INSTALL_DIR="/usr/local"
  BIN_DIR="/usr/local/bin"
fi
