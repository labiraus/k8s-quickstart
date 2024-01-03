#!/bin/bash

kind delete cluster

docker context use default

cat <<EOF | kind create cluster --config=-
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

echo -e "\e[34mAdding MetalLB\e[0m"
helm repo add metallb https://metallb.github.io/metallb
helm repo update
kubectl create namespace istio-ingress
helm install metallb metallb/metallb -n istio-ingress --wait


cat <<EOF | kubectl apply -f-
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: istio-ingress
spec:
  addresses:
  - 172.19.255.200-172.19.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: istio-ingress
EOF
