#!/bin/bash

SERVICE="${1}"

POD=$(kubectl get pods -n k8s-quickstart -l "app=$SERVICE" -o jsonpath="{.items[0].metadata.name}")

kubectl attach -n k8s-quickstart $POD -i