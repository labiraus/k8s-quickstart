#!/bin/bash

name="${1:-local-dev}"

choco install -y docker-desktop --pre 

choco install -y kind --pre 

choco install -y kubernetes-helm --pre 

choco install -y skaffold --pre 

choco install -y linkerd2 --pre 

cat <<EOF | kind create cluster --name local-dev --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

linkerd check --pre

linkerd install | kubectl apply -f -

linkerd check

# installing ingress for kind
linkerd inject - | kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

linkerd dashboard & 

skaffold dev