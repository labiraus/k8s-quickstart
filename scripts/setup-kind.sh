#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}XXXXX${NC} Creating Kind Cluster ${RED}XXXXX${NC}"

cat <<EOF | kind create cluster --name kind-local-dev --config=-
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

echo -e "${RED}XXXXX${NC} Creating Istio namespaces ${RED}XXXXX${NC}"
kubectl create namespace istio-system
kubectl create namespace istio-ingress
kubectl label namespace default istio-injection=enabled --overwrite


echo -e "${RED}XXXXX${NC} Adding Kubernetes Gateway API CRD ${RED}XXXXX${NC}"
# This may not be needed in the future
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0" | kubectl apply -f -; }

echo -e "${RED}XXXXX${NC} Pulling istio into helm repo ${RED}XXXXX${NC}"
# Add istio to helm
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

echo -e "${RED}XXXXX${NC} Installing Istio with Helm ${RED}XXXXX${NC}"
# Install istio helm charts
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm install istiod istio/istiod -n istio-system --wait

echo -e "${RED}XXXXX${NC} Create ingress gateway ${RED}XXXXX${NC}"
# This fails if you -wait
helm install istio-ingressgateway istio/gateway -n istio-ingress
kubectl wait --for=condition=ready pods -n istio-ingress -l app=istio-ingressgateway

echo -e "${RED}XXXXX${NC} Running Skaffold ${RED}XXXXX${NC}"
skaffold run
