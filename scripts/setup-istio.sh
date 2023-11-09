#!/bin/bash

echo Creating minikube cluster

minikube start -p custom --extra-config=apiserver.service-node-port-range=1-65535

# Add ingress 
minikube addons enable ingress -p custom

echo Adding Kubernetes Gateway API CRD
# This may not be needed in the future
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0" | kubectl apply -f -; }

echo Pulling istio into helm repo

# Add istio to helm
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

echo Installing Istio with helm
# Install istio helm chart
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default --wait
helm install istiod istio/istiod -n istio-system --wait
kubectl label namespace default istio-injection=enabled

echo Create ingress gateway
kubectl create namespace istio-ingress
helm install istio-ingressgateway istio/gateway -n istio-ingress
kubectl wait --for=condition=ready pods -n istio-ingress -l app=istio-ingressgateway

echo Running Skaffold
skaffold run

echo All deployed - starting tunnel
minikube tunnel -c -p custom

