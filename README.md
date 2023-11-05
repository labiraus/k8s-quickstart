# k8s-quickstart

A simple quickstart demo for local microservice development

The idea is to create an out of the box kubernetes cluster with containerized code, ingress control, service mesh, and automatic deployment.
This repository was designed to enable a developer with minimal understanding of infrastructure or platform engineering to go from developing single isolated applications to networking multiple applications together in a local development environment that could accurately mirror production.

## Repo structure

This repository has been designed to separate code in an easily readable format for demonstration purposes rather than to as a recommended structure. Specifically it doesn't represent good Go repo management (further details see: <https://golang.org/doc/gopath_code>)

All microservices are contained in a folder within the `/apps` folder. They each have a dockerfile that describes how to build that specific microservice

The `/kubernetes` configuration is found in the kubernetes folder. This can be split into multiple configuration files that are registered with skaffold.

The `/helm` charts are found in the helm folder. This contains a standard golang microservice chart that sets up fluentd for both logging and stats.

The `/scripts` folder contains bash scripts that allow you to starup/teardown an environment and perform some of the more common operations that are not simple cli calls.

## Quickstart

To try this out, clone it into $GOPATH/src/k8s-quickstart

### Windows

install chocolatey: <https://chocolatey.org/install>

Run the bash script: `scripts/windows-install.sh` with elevated permissions

### Linux

Due to the variety of distributions of Linux, there's no single way to install all of the tools required.
As such, this system will require:

* docker: <https://docs.docker.com/engine/install/>
* kind: <https://kind.sigs.k8s.io/docs/user/quick-start/#installation>
* kubernetes-helm: <https://helm.sh/docs/intro/install/>
* skaffold: <https://skaffold.dev/docs/install/>
* istio: <https://istio.io/latest/docs/setup/getting-started//>
* linkerd2: <https://linkerd.io/2.10/getting-started/>

### Skaffold

To install the k8s-quickstart run `skaffold run`
This will cause scaffold to:

* Build the web and user programs in docker
* Deploy the kubernetes components to the k8s-quickstart kubernetes namespace
* Deploy the newly built docker containers

Running `skaffold dev` will run the skaffold deployment and then monitor for any changes to source files, redeploying whenever a change is made.

### Scripts

The scripts folder has a number of useful scripts for interacting with kubernetes and containers

#### Setup

Once all the tools are installed and docker is running, the setup script will create a kind cluster and install istio or linkerd and nginx
Run the bash script: `scripts/setup-istio.sh`
Run the bash script: `scripts/setup-linkerd.sh`
Throughout the cluster name `local-dev` is used.

#### Attach

To attach to a running process and see the console output run the attach bash script with the name of one of the services: `scripts/attach.sh web`

`skaffold dev` will also display the console output of all deployed microservices

#### Shell

To connect to a container that has bash installed, run: `scripts/shell.sh <name>`
The script will find the pod name and execute /bin/bash. To work, the pod deployment must have spec.template.spec.containers.tty and spec.template.spec.containers.stdin set to true in the kubernetes yaml definition. This has been setup on the `web` deployment.

#### Port-Forward

To connect to a specific port in a container that is not exposed via the nginx ingress controller, that port can be manually forwarded. This lasts for the duration of the command.
Kubernetes port forwarding to a pod requires you to use the specific pod deployment name, which changes every time it's re-deployed. Use `scripts/port-forward <name> <port>`

#### Teardown

Since the entire cluster is build into and deployed in Docker, it can very easily be wiped clean to start again.
Run the bash script: `scripts/teardown.sh`
Default cluster name is local-dev which can be overridden by passing in a name as a parameter. The kind cluster with this name will be taken offline and deleted
All tool installations will remain

#### Dashboard

To access the Linkerd dashboard run: `linkerd viz dashboard`
The dashboard will only be accessible as long as the command is running
If you get an error that linkerd viz is not installed then you'll need to install it on your cluster with `linkerd viz install | kubectl apply -f -`

To access the Kubernetes dashboard run the bash script: `scripts/dashboard.sh`
You will need to use the token printed to console to log into the dashboard
The dashboard will only be accessible as long as the command is running

## Features

### Docker

<https://docs.docker.com/desktop/>

Docker is a containerization system. In this solution it is being used to package up container images of the code and, ultimately, host the kubernetes cluster

### Kubernetes

<https://kubernetes.io/docs/home/>

Kubernetes (k8s) is the present front runner for container orchestration. In a production environment it manages a single Cluster which may span multiple physical/virtual machines (Nodes) which each contain a number of Pods which host containers. Kubernetes is then responsible for managing these Nodes and Pods, recreating them if they fail and allowing them to communicate with one another.

In this solution, kubernetes Namespaces are used to group together development code

### Helm

<https://helm.sh/docs/>

Helm is a simple package manager for kubernetes. In this solution it is used for straight forward installation of off the shelf kubernetes components.

### Kind

<https://kind.sigs.k8s.io/>
Kind (Kubernetes IN Docker) is a tool for running a kubenetes cluster in docker using containers as nodes. It is a local development and testing tool that allows a developer to mirror a production structure on their local machine.

### Linkerd

<https://linkerd.io/2/overview/>
Linkerd is a service mesh for kubernetes which provides observability, debugging, and security within a node. At time of writing there are a number of prominent service mesh solutions including Istio and Consul. Linkerd is demonstrated here as it requires the smallest amount of configuration.

Once Linkerd has been installed on a kubernetes cluster, all pods that are deployed to a namespace with linkerd auto inject enabled will automatically be meshed. The namespace needs to have the following added to its metadata:
"annotations": { linkerd.io/inject: enabled }

### Ingress Nginx

<https://kubernetes.github.io/ingress-nginx/>

Nginx is a production grade ingress control system and the frontrunner in its classification. In this solution it is used to load balance and forward traffic from localhost to the appropriate api.
Nginx has been added to this quickstart solution as it is likely that code deployed into a production environment will sit behind a similar ingress controller.

### Skaffold

<https://skaffold.dev/docs/>

Skaffold is a very simple local development command line CI/CD specifically for Kubernetes. It monitors local files for changes, automatically rebuilds builds containers and deploys them to cluster. It requires very little configuration and allows developers to rapidly prototype their code in cluster.

### Scratch Containers

<https://hub.docker.com/_/scratch/>

In order to reduce container size and attack footprint, this solution provides a dockerfile that builds Go deployments within a scratch container.

Credit Chemidy:
<https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324>
<https://github.com/chemidy/smallest-secured-golang-docker-image>

## Points of note

Building and maintaining a kubernetes solution such as this requires an broad understand of a lot of the fundaments of the underlying technologies and systems that are being deployed. As such anyone wishing to be able to build and manage a microservices system will need to invest the time into understanding all of the moving parts.
However the point of this quickstart is to allow a developer to skip all of that and get straight to the point: develop code now, understand infrastructure later.

With this in mind, the following are the specific areas that will need tweaking/duplicating to add more microservices/connectivity.

### kubernetes/k8s-quickstart.yml

This file contains the desired state of all of the code deployed to kubernetes. A developer needs to pay particular attention to three types of resources (denoted by a sections "kind"): Deployment, Service, and Ingress

#### Deployment

A deployment declares how many pods containing instances of a microservice should be deployed, and what resources they should be provided with.

* metadata.name: Name of the deployment, not of the code to be deployed
* spec.replicas: How many instances of the code should be deployed
* spec.selector.matchLabels.app: Name of the code to be deployed
* spec.template.metadata.labels.app: Name of the code to be deployed
* spec.template.spec.containers: Parameters of the code to be deployed
* * image: Docker image of the code
* * ports.containerPort: port(s) to be exposed for inbound traffic

#### Service

Not to be confused with a microservice, a service allows a code in one pod to talk to code in another. It essentially routes traffic sent to a named endpoint to a port on a pod. In this example services are routed using CoreDNS

* metadata.name: Name of the service - this will be used as url path to route traffic. Eg: service-name
* spec.selector.app: Name of the code to be deployed
* spec.ports.port: Port internal traffic will connection. Eg if port is 80: <http://service-name:80> (<https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/>)
* spec.ports.targetPort: Port exposed on the destination container

#### Ingress

An ingress ties the ingress provider (ingress-nginx) to a service allowing connections in from the outside world.

* spec.rules.http.paths.path: matches inbound paths depending on pathType
* spec.rules.http.pths.backend.service.name: Name of the service

### user/dockerfile

This file provides instructions to Docker on how to build the Go code's scratch container and will only need changing to add in local dependencies.

It works by:

* First creating a generic builder - golang:alpine
* Setting up for and creating internal certificates
* Moving source code from the local file system into the container
* Building the Go executable
* Creating a scratch container
* Transferring the Go executable and internal certificates

### skaffold.yml

This file contains the configuration for skaffold to automatically build and deploy code.

* build.artifacts.image: Name of the docker image to be created. This will correspond to the a deployment's spec.template.spec.containers.image in quickstart.yml
* build.artifacts.image.docker.dockerfile: Name of the dockerfile to build the image from
