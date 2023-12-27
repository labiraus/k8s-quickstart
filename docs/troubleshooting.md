# Troubleshooting

This document outlines common mistakes, diagnostic scripts, and likely solutions related to pulling this repo and running it as per instructions not working straight away. If you run into problems that aren't documented here and solve them, please add to this file.

## Installation

Installation begins when you begin trying to get things working and ends when you've got a kubernetes cluster up and running. This section is primarily focussed on the installation of wsl and minikube as they're most likely to cause headaches.

### Windows

The <setup/windows-install.sh> script needs to be run as an administrator in a bash shell. The simplest way to do this is to run git bash as administrator.

If curl for docker-buildx doesn't work then download it manually following <https://github.com/docker/buildx?tab=readme-ov-file#installing> - docker-buildx needs to be installed on whatever machine you're running skaffold from rather than the machine that has the docker daemon running on.

### WSL2

When you try to run wsl, calling wsl directly will take you to the default version. Check the versions on your machine with:

> wsl -l

If you see a version you don't like or if you want to teardown the existing installation and start again then you can uninstall it with:

> wsl --unregister Ubuntu-22.04

To set the newly installed Ubuntu-22.04 as the default, run the following:

> wsl --set-version Ubuntu-22.04 2

To enter wsl simply run `wsl` and to exit run `exit`

### Docker Startup 

To check the status of docker.service use the following

> systemctl status docker.service

To pull the docker.service logs use the following (exit with q)

> journalctl -u docker.service | less -R

If it complains about a startup conflict then it may be that the startup command (ExecStart) may be trying to set the -H host flag and conflicting with the /etc/docker/daemon.json file, check that the systemd docker.service ExecStart startup command has the host file set properly

> cat /lib/systemd/system/docker.service | grep ExecStart

`ExecStart=/usr/bin/dockerd`

### Connecting to Docker

If you try to do `docker ps` from windows and get the following response

`error during connect: Get "http://localhost:2375/v1.24/containers/json": dial tcp [::1]:2375: connectex: No connection could be made because the target machine actively refused it.`

This error can be a number of different things:
1) Docker isn't runnning on WSL
2) Socat isn't running on WSL

To check if docker is running on WSL, you can do the following:

> wsl -- docker ps

If this doesn't return a response with the first line `CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES` then it means that docker isn't running. If docker runs then open a wsl session and, from a second terminal, try `docker ps` again. If it works now, then the wsl session wasn't being kept alive in the background and you need to run

> wsl

> screen

> Enter

> [Ctrl]+[A] [D]

If running `docker ps` from a windows terminal doesn't work but it does work on wsl then socat probably isn't running, restart it with:

> sudo service socat-startup start

## Deployment

Deployment covers everything from when you have a kubernetes cluster online that you can communicate with `kubectl get pods` and covers anything that might go wrong with the initial setup script or skaffold deployment pipeline

### Deploying to minikube with skaffold

If, after you have minikube set up properly on docker, you get something like the following error during skaffold run

`getting imageID for reactapp:ae09852: error during connect: Get "https://[::1]:32771/v1.24/images/reactapp:ae09852/json": dial tcp [::1]:32771: connectex: No connection could be made because the target machine actively refused it.`

`[::1]` means that the minikube config for the docker daemon is IPv6 instead of IPv4. This is probably because your docker host is set to tcp://localhost:2375 instead of tcp://127.0.0.1:2375 (yes it matters)

> minikube ssh

> sudo journalctl -u docker.service

If you have an error message like: 

`Dec 22 12:53:31 minikube dockerd[932]: time="2023-12-22T12:53:31.414410804Z" level=error msg="Handler for POST /v1.42/images/create returned error: Get \"https://registry-1.docker.io/v2/\": dial tcp: lookup registry-1.docker.io on 192.168.49.1:53: server misbehaving"`

Then it might indicate that your minikube docker daemon can't contact registry-1.docker.io to pull images because it can't access the internet. To diagnose this you can check if it's network connectivity with:

> ping 8.8.8.8

This problem may be caused by a misconfigured docker NAT. When the minikube CLI runs `minikube start` it will create a docker network adaptor called 'minikube'. Check first whether you have ingress set up with:

> minikube addons enable ingress

> minikube addons enable ingress-dns

You can test whether docker's connecting to the internet at all by running the following in wsl

> MINIKUBE_ID=$(docker ps -a --format '{{.ID}} {{.Image}}' | grep 'gcr.io/k8s-minikube/kicbase' | awk '{print $1}' | head -n 1)

> docker inspect --format='{{.NetworkSettings}}' $MINIKUBE_ID

> MINIKUBE_NETWORK=$(docker network ls --format '{{.ID}} {{.Name}}' | grep 'minikube' | awk '{print $1}')

> docker network inspect $MINIKUBE_NETWORK

> docker run --rm busybox ping -c 4 8.8.8.8

### x-kubernetes-validations

During istio setup when activating kubernetes gateway api you may get the following error message:

`error: error validating "STDIN": error validating data: [ValidationError(CustomResourceDefinition.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.controllerName): unknown field "x-kubernetes-validations"`

This implies that your minikube installation is out of date. Try updating to minikube 1.32.0 or later

## Running

Running covers everything that might go wrong with either accessing or altering the cluster once it has deployed successfully for the first time.

### DNS Host

Ensure that you've read <dns-host.md>. After this you should be able to hit the landing page at <http://local.k8s-demo.com/>. Note that https is not set up on the current iteration of the starterkit.

### Minikube Tunnel

Ensure that minikube tunnel is running. -c will cleanup old tunnels. -p will specify the cluster name which can be looked up with `minikube profile`

> minikube tunnel -c -p <cluster-name>

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
- `kubectl get HTTPRoute reactapp`
  - Check the hostname
- `kubectl get Service reactapp`
- `kubectl get ServiceAccount reactapp`
- `kubectl get Pod -o wide`

If there's nothing there then you may not have run `skaffold run`. 

If all of that works then you should be able to connect to the cluster and get the landing page with the following:

> curl -s -I -HHost:reactapp.example.com "http://127.0.0.1/"

### Pod

To check the logs on a pod, get the pod name and then look up the logs

> kubectl get pods
> kubectl logs <pod-name>

Pod to pod calls are managed by kubernetes Services. 

### Docker

In order to allow docker to copy from go-common for a golang docker build, the context needs to be the ./apps folder. To test the build, run the following:

> docker build -t testbuild -f ./apps/webserverapi/dockerfile ./apps

### Helm libraries

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
