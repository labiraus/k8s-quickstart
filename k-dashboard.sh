#!/bin/bash

name="${1:-local-dev}"

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

helm install $name kubernetes-dashboard/kubernetes-dashboard

# Adds dashboard login permission to 
if ! kubectl get clusterrolebindings.rbac.authorization.k8s.io cluster-admin -o wide | grep $name; then
    kubectl patch clusterrolebindings.rbac.authorization.k8s.io cluster-admin  --type='json' -p='[{"op": "add", "path": "/subjects/-", "value": {"name": "system:serviceaccount:default:'$name'-kubernetes-dashboard", "kind": "User", "apiGroup": "rbac.authorization.k8s.io" } }]'
fi

DASHBOARD=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=$name" -o jsonpath="{.items[0].metadata.name}")

kubectl wait -n default --for=condition=ready pod $DASHBOARD --timeout=90s

kubectl -n default port-forward $DASHBOARD 8443:8443 &
start https://127.0.0.1:8443
echo Use the following token to log into the kubernetes dashboard:
kubectl describe secret $(kubectl get secret | awk '/-kubernetes-dashboard-token-/ {print $1;exit}') | grep token:

read -p "Hit any key to end"