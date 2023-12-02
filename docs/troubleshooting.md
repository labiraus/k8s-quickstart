# Troubleshooting

## Installation errors

### x-kubernetes-validations

During istio setup when activating kubernetes gateway api you may get the following error message:

`error: error validating "STDIN": error validating data: [ValidationError(CustomResourceDefinition.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.controllerName): unknown field "x-kubernetes-validations"`

This implies that your minikube installation is out of date. Try updating to minikube 1.32.0 or later

## Unable to connect

### Minikube Tunnel

Ensure that minikube tunnel is running. -c will cleanup old tunnels. -p will specify the cluster name

`minikube tunnel -c -p <cluster-name>`

To check if your cluster is connected `curl localhost`

if you don't have a cluster you'll get the following:

`curl: (7) Failed to connect to localhost port 80 after 2250 ms: Connection refused`

if the cluster is running (whether or not the tunnel is running) you'll get the following:

`curl: (56) Recv failure: Connection was reset`

### Skaffold

Check that the gateway is BEFORE the deployment/setup etc in the skaffold.yaml

- `kubectl get gateway gateway -n istio-ingress`
  - The result of `PROGRAMMED=True` means that the gateway is configured properly.
  - `kubectl wait -n istio-ingress --for=condition=programmed gateways.gateway.networking.k8s.io gateway`
- `kubectl get HTTPRoute http`
  - Check the hostname
- `kubectl get Service reactapp`
- `kubectl get ServiceAccount reactapp`
- `kubectl get Pod -o wide`

If there's nothing there then you may not have run `skaffold run`

`curl -s -I -HHost:reactapp.example.com "http://localhost/"`

### Pod

To check the logs on a pod, get the pod name and then look up the logs

> kubectl get pods
> kubectl logs <pod-name>

Pod to pod calls are managed by kubernetes Services. 

## Docker

In order to allow docker to copy from go-common for a golang docker build, the context needs to be the ./apps folder. To test the build, run the following:

> docker build -t testbuild -f ./apps/webserverapi/dockerfile ./apps

## Helm libraries

If you make a chang to a helm library chart then you need to increment the version, increment the version in the places where it used, and then in each of the charts that it is used run:

> helm dependency update helm/<template-name>

Then verify with:

> helm dependency list helm/<template-name>

And test the chart with:

> helm template <template-name> helm/<template-name>

Your helm library name cannot have dashes in it

To check if your helm deployment is going to work:

> helm lint helm/<template-name>
> helm install --dry-run --debug my-release helm/<template-name>
