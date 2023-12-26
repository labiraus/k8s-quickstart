#!/bin/bash

choco upgrade -y chocolatey

choco install -y docker-cli
choco upgrade -y docker-cli

mkdir "C:\\Program Files\\Docker\\cli-plugins"
curl -L -o "C:\\Program Files\\Docker\\cli-plugins\\docker-buildx.exe" https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.windows-amd64.exe

#choco install -y kind
#choco upgrade -y kind

choco install -y minikube
choco upgrade -y minikube

choco install -y kubernetes-helm
choco upgrade -y kubernetes-helm

choco install -y skaffold
choco upgrade -y skaffold

#choco install -y linkerd2
#choco upgrade -y linkerd2

choco install -y istioctl
choco upgrade -y istioctl