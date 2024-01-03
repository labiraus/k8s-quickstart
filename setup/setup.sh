#!/bin/bash

echo -e "\e[34mAdding Kubernetes Gateway API CRD\e[0m"
# This may not be needed in the future, but Kubernetes Gateway API has only just come out of beta
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
    { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.0.0" | kubectl apply -f -; }

# Add istio to helm
echo -e "\e[34mPulling istio into helm repo\e[0m"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Install istio helm chart
echo -e "\e[34mInstalling Istio with helm\e[0m"
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default --wait
helm install istiod istio/istiod -n istio-system --wait

# Enable istio injection
echo -e "\e[34mAdding injection namespace\e[0m"
kubectl label namespace default istio-injection=enabled
kubectl create namespace k8s-demo
kubectl label namespace k8s-demo istio-injection=enabled

echo -e "\e[34mCreate ingress gateway (please be patient)\e[0m"
helm install istio-ingressgateway istio/gateway -n istio-ingress --wait

echo -e "\e[34mRunning Skaffold\e[0m"
skaffold run

echo -e "\e[34mAll deployed!\e[0m"
