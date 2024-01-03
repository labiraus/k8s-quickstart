# Helm

## Overview

Helm provides a flexible manner for handling a lot of kubernetes manifests in a manner more consistent with development on a large project. Each program that is deployed needs to have a number of different components configured, so there is generally a single helm chart per program which describes all of the dependencies. The key features being used here are the parameterisation of manifests and library charts. 

### Parameterisation

Helm charts are paremeterised and are built from templates with values filled in from a values.yaml configuration. These values are the global defaults for the program being deployed, and can be overridden with environment specific configurations in a values-dev.yaml and values-prod.yaml.

### Library Charts

Because a lot of services will need all the same components configured in the same way with slightly different values, library charts provide a master template which can be imported into multiple helm deployments. In this repo all of the golang applications have the same library chart allowing common functionality to be abstracted out and managed in one location.