# Troubleshooting

## Install

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
