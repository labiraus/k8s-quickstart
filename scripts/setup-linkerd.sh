#!/bin/bash

echo Creating Kind Cluster

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

echo Installing Linkerd

linkerd check --pre

linkerd install | kubectl apply -f -

kubectl wait -n linkerd --for=condition=available deployment/linkerd-controller --timeout=120s

linkerd check

echo Installing Nginx and Viz

# installing ingress for kind
linkerd inject https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml | kubectl apply -f -

linkerd viz install | kubectl apply -f -

echo Waiting for Nginx to finish startup with 5 min timeout

kubectl wait -n ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

echo Running Skaffold

skaffold run

echo Done!
