#!/bin/bash

minikube start --extra-config=apiserver.service-node-port-range=1-65535 --driver=docker --addons=ingress --driver=podman