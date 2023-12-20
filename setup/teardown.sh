#!/bin/bash

echo cleaning up helm
rm -rf ~/.helm/cache/archive/*
rm -rf ~/.helm/repository/cache/*
# Refreash repository configurations
helm repo update

echo killing kind
kind delete cluster --name kind-local-dev

echo killing minikube
minikube stop
minikube delete --all
minikube purge
docker rmi gcr.io/k8s-minikube/kicbase:v0.0.42
echo all done
