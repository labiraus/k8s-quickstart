#!/bin/bash

echo Creating minikube cluster

minikube start

echo Pulling istio into helm repo

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

echo Installing Isto helm chart
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm install istiod istio/istiod -n istio-system --wait

echo Create ingress gateway
kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait


echo Running Skaffold

skaffold run

echo Done!
