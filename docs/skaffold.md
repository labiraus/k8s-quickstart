# Skaffold

## Overview

Skaffold is a local dev ci/cd pipeline

## Installation

[Documentation|https://skaffold.dev/docs/install/]

### Chocolatey

`choco install -y skaffold`

This requires administrator access and installs skaffold as an app on your machine

### Docker

`docker run gcr.io/k8s-skaffold/skaffold:latest skaffold --help`

This will pull the docker image for skaffold but how do you point skaffold at your local toolset? That's going to need to be a whole separate thing.

Run skaffold in a container that can see your repo, then 