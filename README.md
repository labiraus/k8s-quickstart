# k8s-quickstart
A simple quickstart demo for local Go microservice development

The idea is to create an out of the box kubernetes cluster with containerized Go code, ingress control, service mesh, and automatic deployment.
This repository was designed to enable a Go developer with minimal understanding of infrastructure or platform engineering to go from developing single isolated Go applications to networking multiple applications together in a local development environment that could accurately mirror production.

This example is for demonstration purposes only and doesn't represent good Go repo management. For further details see: https://golang.org/doc/gopath_code


## Quickstart
To try this out, clone it into $GOPATH/src/k8s-quickstart


### Windows

install chocolatey: https://chocolatey.org/install

Run the bash script: `windows-startup.sh`
(If you do not run with elevated permissions, it will ask you to confirm installations)
Default cluster name is local-dev which can be overridden by passing in a name as a parameter.


## Teardown

Since the entire cluster is build into and deployed in Docker, it can very easily be wiped clean to start again.
Run the bash script: `teardown.sh`
Default cluster name is local-dev which can be overridden by passing in a name as a parameter. The kind cluster with this name will be taken offline and deleted
All tool installations will remain


## Dashboard

To access the Linkerd dashboard run: `linkerd dashboard`
The dashboard will only be accessible as long as the command is running

To access the Kubernetes dashboard run the bash script: `k-dashboard.sh`
You will need to use the token printed to console to log into the dashboard
The dashboard will only be accessible as long as the command is running


## Features

### Docker

https://docs.docker.com/desktop/

Docker is a containerization system. In this solution it is being used to package up container images of the code and, ultimately, host the kubernetes cluster


### Kubernetes

https://kubernetes.io/docs/home/

Kubernetes (k8s) is the present front runner for container orchestration. In a production environment it manages a single Cluster which may span multiple physical/virtual machines (Nodes) which each contain a number of Pods which host containers. Kubernetes is then responsible for managing these Nodes and Pods, recreating them if they fail and allowing them to communicate with one another.

In this solution, kubernetes Namespaces are used to group together development code


### Helm

https://helm.sh/docs/

Helm is a simple package manager for kubernetes. In this solution it is used for straight forward installation of off the shelf kubernetes components.


### Kind

https://kind.sigs.k8s.io/
Kind (Kubernetes IN Docker) is a tool for running a kubenetes cluster in docker using containers as nodes. It is a local development and testing tool that allows a developer to mirror a production structure on their local machine.


### Linkerd

https://linkerd.io/2/overview/
Linkerd is a service mesh for kubernetes which provides observability, debugging, and security within a node. At time of writing there are a number of prominent service mesh solutions including Istio and Consul. Linkerd is demonstrated here as it requires the smallest amount of configuration.

Once Linkerd has been installed on a kubernetes cluster, all pods that are deployed to a namespace with linkerd auto inject enabled will automatically be meshed. The namespace needs to have the following added to its metadata:
"annotations": { linkerd.io/inject: enabled }


### Ingress Nginx

https://kubernetes.github.io/ingress-nginx/

Nginx is a production grade ingress control system and the frontrunner in its classification. In this solution it is used to load balance and forward traffic from localhost to the appropriate api.
Nginx has been added to this quickstart solution as it is likely that code deployed into a production environment will sit behind a similar ingress controller.


### Skaffold

https://skaffold.dev/docs/

Skaffold is a very simple local development command line CI/CD specifically for Kubernetes. It monitors local files for changes, automatically rebuilds builds containers and deploys them to cluster. It requires very little configuration and allows developers to rapidly prototype their code in cluster.


### Scratch Containers

https://hub.docker.com/_/scratch/

In order to reduce container size and attack footprint, this solution provides a dockerfile that builds Go deployments within a scratch container.

Credit Chemidy:
https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324
https://github.com/chemidy/smallest-secured-golang-docker-image


## Points of note

Building and maintaining a kubernetes solution such as this requires an broad understand of a lot of the fundaments of the underlying technologies and systems that are being deployed. As such anyone wishing to be able to build and manage a microservices system will need to invest the time into understanding all of the moving parts.
However the point of this quickstart is to allow a developer to skip all of that and get straight to the point: develop code now, understand infrastructure later.

With this in mind, the following are the specific areas that will need tweaking/duplicating to add more microservices/connectivity.


### kubernetes/quickstart.yml

This file contains the desired state of all of the code deployed to kubernetes. A developer needs to pay particular attention to three types of resources (denoted by a sections "kind"): Deployment, Service, and Ingress


#### Deployment

A deployment declares how many pods containing instances of a microservice should be deployed, and what resources they should be provided with.

* metadata.name: Name of the deployment, not of the code to be deployed
* spec.replicas: How many instances of the code should be deployed
* spec.selector.matchLabels.app: Name of the code to be deployed
* spec.template.metadata.labels.app: Name of the code to be deployed
* spec.template.spec.containers: Parameters of the code to be deployed
** image: Docker image of the code
** ports.containerPort: port(s) to be exposed for inbound traffic


#### Service

Not to be confused with a microservice, a service allows a code in one pod to talk to code in another. It essentially routes traffic sent to a named endpoint to a port on a pod. In this example services are routed using CoreDNS

* metadata.name: Name of the service - this will be used as url path to route traffic. Eg: service-name
* spec.selector.app: Name of the code to be deployed
* spec.ports.port: Port internal traffic will connection. Eg if port is 80: http://service-name:80 (https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
* spec.ports.targetPort: Port exposed on the destination container


#### Ingress

An ingress ties the ingress provider (ingress-nginx) to a service allowing connections in from the outside world.

* spec.rules.http.paths.path: matches inbound paths depending on pathType
* spec.rules.http.pths.backend.service.name: Name of the service


## hello.Dockerfile

This file provides instructions to Docker on how to build the Go code's scratch container.

It works by:
* First creating a generic builder - golang:alpine
* Setting up for and creating internal certificates
* Moving source code from the local file system into the container
* Building the Go executable
* Creating a scratch container
* Transferring the Go executable and internal certificates

Lines 27-31 are the only lines that will potentially change from microservice to microservice. They relate to copying source code from the local directory to the directory pattern that Go expects.


## skaffold.yml

This file contains the configuration for skaffold to automatically build and deploy code.

* build.artifacts.image: Name of the docker image to be created. This will correspond to the a deployment's spec.template.spec.containers.image in quickstart.yml
* build.artifacts.image.docker.dockerfile: Name of the dockerfile to build the image from
