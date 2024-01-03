# Kubernetes

## Overview

<https://kubernetes.io/docs/home/>

Kubernetes (k8s) is the present front runner for container orchestration. In a production environment it manages a single Cluster which may span multiple physical/virtual machines (Nodes) which each contain a number of Pods which host containers. Kubernetes is then responsible for managing these Nodes and Pods, recreating them if they fail and allowing them to communicate with one another.

Kubernetes uses a declarative configuration in yaml (a superset of json) where the required resources are described and it's left to the kubernetes control plane - the set of programs dedicated to managing the cluster - to create these resources, check that they're not malfunctioning, and recreate them when they fail.

Resources include not only the pods containing code, but also the deployments that ensure the right number are created, services which allow pods to talk to one another, httproutes that route calls from the outward facing gateway to the correct services, and much much more.

## Scripts

The ./kubernetes contains manifests that can be run on a cluster to create resources. A manifest can contain the definition for multiple resources delimited with `---`. A manifest can be included in the CI/CD pipeline, or run directly with the following command:

> kubectl apply -f ./kubernetes/test.yml

All of the resources in a manifest can be deleted with the following command:

> kubectl delete -f ./kubernetes/test.yml

## Kubernetes Gateway API

The kubernetes gateway api is the new (Q4 2023) way of configuring cluster ingress <https://gateway-api.sigs.k8s.io/>. It ties together the infrastructure level GatewayClass, the cluster level Gateway, and then HTTPRoutes that map urls to specific services and down to pods.

When looking up information about kubernetes ingress, older documentation will refer to implementation specific ingress controllers. Kubernetes Gateway API is designed to be generic across all platforms so the GatewayClass is managed by the provider specific kubernetes platform, and we use the same vendor agnostic Gateway.

## Notes

The source.sh script at the root of this project adds aliases the k alias for kubectl in a bash terminal, this is typically stored in a .bashrc file or similar. To add the alias to your terminal run:

> source source.sh