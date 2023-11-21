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

echo all done
