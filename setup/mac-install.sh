#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../common.sh
set -e

MINIKUBE_VERSION=1.32.0
K8S_VERSION=v1.28.3
BASE_URL=${YUM_REPO}/tarballs/minikube
CACHE_TAR=minikube-cache-${ARCH}-${K8S_VERSION}.tar.gz

K9S_VERSION=v0.28.2
K9S_BASE_URL=${YUM_REPO}/tarballs/k9s

KUBECTL_BASE_URL=${YUM_REPO}/tarballs/kubectl

if ${IS_MAC}; then
  MINIKUBE_BINARY=v${MINIKUBE_VERSION}/minikube-darwin-arm64
  KUBECTL_BINARY=${K8S_VERSION}/darwin-arm64/kubectl
  K9S_TAR=${K9S_VERSION}/k9s_Darwin_arm64.tar.gz
else
  MINIKUBE_BINARY=v${MINIKUBE_VERSION}/minikube-linux-${ARCH}
  KUBECTL_BINARY=${K8S_VERSION}/${ARCH}/kubectl
  K9S_TAR=${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz
fi

if ! ${BIN_DIR}/minikube version 2>/dev/null | grep -q "v${MINIKUBE_VERSION}"; then
  echo "Installing minikube"
  sudo wget -q ${BASE_URL}/${MINIKUBE_BINARY} -O ${BIN_DIR}/minikube
  sudo chmod +x ${BIN_DIR}/minikube

  if ${IS_JENKINS}; then
    sudo ln -sf ${BIN_DIR}/minikube /usr/bin/minikube
    wget -q ${BASE_URL}/${CACHE_TAR} -O /tmp/minikube_cache.tgz
    rm -rf ~/.minikube/cache
    mkdir -p ~/.minikube/cache
    tar -zxf /tmp/minikube_cache.tgz -C ~/.minikube
    rm /tmp/minikube_cache.tgz
  fi
fi

if ! ${BIN_DIR}/k9s version 2>/dev/null | grep -q "${K9S_VERSION}"; then
  echo "Installing k9s"
  # k9s version output includes ansi colour so the sed removes the ansi colour sequences
  wget -q ${K9S_BASE_URL}/${K9S_TAR} -O /tmp/k9s.tgz;
  sudo tar zxf /tmp/k9s.tgz -C ${BIN_DIR} k9s;
  rm /tmp/k9s.tgz;
  if ${IS_JENKINS}; then
    sudo ln -sf ${BIN_DIR}/k9s /usr/bin/k9s
  fi
fi

if ! ${BIN_DIR}/kubectl version 2>/dev/null | grep -q "Client Version: ${K8S_VERSION}"; then
  echo "Installing kubectl"
  sudo wget -q ${KUBECTL_BASE_URL}/${KUBECTL_BINARY} -O ${BIN_DIR}/kubectl
  sudo chmod +x ${BIN_DIR}/kubectl
  if ${IS_JENKINS}; then
    sudo ln -sf ${BIN_DIR}/kubectl /usr/bin/kubectl
  fi
fi