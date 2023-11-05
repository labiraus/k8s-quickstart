# Istio

## Overview

Istio is a service mesh

## Installation

### Chocolatey

`https://istio.io/latest/docs/setup/install/istioctl/`

> choco install -y istio
> istioctl install --set profile=demo -y
> kubectl label namespace default istio-injection=enabled

### Helm

`https://istio.io/latest/docs/setup/install/helm/`

> helm repo add istio https://istio-release.storage.googleapis.com/charts
> helm repo update
