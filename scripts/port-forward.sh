#!/bin/bash

SERVICE="${1}"
PORT="${2:-8080}"

POD=$(kubectl get pods -n k8s-quickstart -l "app=$SERVICE" -o jsonpath="{.items[0].metadata.name}")
echo $POD
kubectl port-forward -n k8s-quickstart pods/$POD $PORT
