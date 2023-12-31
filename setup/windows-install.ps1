choco upgrade -y chocolatey

choco install -y docker-cli
choco upgrade -y docker-cli

mkdir "C:\\Program Files\\Docker\\cli-plugins"
curl -L -o "C:\\Program Files\\Docker\\cli-plugins\\docker-buildx.exe" https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.windows-amd64.exe

curl -L -o "C:\\ProgramData\\chocolatey\bin\\kind.exe" https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64

choco install -y minikube
choco upgrade -y minikube

choco install -y kubernetes-helm
choco upgrade -y kubernetes-helm

choco install -y skaffold
choco upgrade -y skaffold

choco install -y istioctl
choco upgrade -y istioctl