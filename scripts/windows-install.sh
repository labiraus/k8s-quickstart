#!/bin/bash

choco upgrade chocolatey

choco install -y docker-desktop
choco upgrade docker-desktop

choco install -y kind
choco upgrade kind

choco install -y kubernetes-helm
choco upgrade kubernetes-helm

choco install -y skaffold
choco upgrade skaffold

choco install -y linkerd2
choco upgrade linkerd2

"C:\Program Files\Docker\Docker\Docker Desktop.exe" &