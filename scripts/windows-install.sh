#!/bin/bash

choco upgrade -y chocolatey

choco install -y docker-desktop
choco upgrade -y docker-desktop

choco install -y kind
choco upgrade -y kind

choco install -y minikube
choco upgrade -y minikube

choco install -y kubernetes-helm
choco upgrade -y kubernetes-helm

choco install -y skaffold
choco upgrade -y skaffold

choco install -y linkerd2
choco upgrade -y linkerd2

choco install -y istioctl
choco upgrade -y istioctl

"C:\Program Files\Docker\Docker\Docker Desktop.exe" &