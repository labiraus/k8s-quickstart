#!/bin/bash

# Adds kubernetes-dashboard repo
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# Uses helm to install dashboard on 
helm install local-dev kubernetes-dashboard/kubernetes-dashboard

# Adds dashboard login permission to 
if ! kubectl get clusterrolebindings.rbac.authorization.k8s.io cluster-admin -o wide | grep local-dev; then
    kubectl patch clusterrolebindings.rbac.authorization.k8s.io cluster-admin  --type='json' -p='[{"op": "add", "path": "/subjects/-", "value": {"name": "system:serviceaccount:default:local-dev-kubernetes-dashboard", "kind": "User", "apiGroup": "rbac.authorization.k8s.io" } }]'
fi

echo "Waiting for dashboard"
kubectl wait -n default --for=condition=ready deployment/local-dev-kubernetes-dashboard --timeout=120s

# Opening up port 8443 to kubernetes-dashboard
DASHBOARD=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=local-dev" -o jsonpath="{.items[0].metadata.name}")
kubectl -n default port-forward $DASHBOARD 8443:8443 &
start https://127.0.0.1:8443

echo Use the following token to log into the kubernetes dashboard:
kubectl describe secret $(kubectl get secret | awk '/-kubernetes-dashboard-token-/ {print $1;exit}') | grep token:

read -p "Hit any key to end"