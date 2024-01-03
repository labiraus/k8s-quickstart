# Minikube

## Overview

Minikube is a popular local kubernetes cluster provider.

## Issues

It only recognizes its own docker daemon, so if you've got local docker builds then pods will stall with status ImagePullBackOff 