#!/bin/bash

export DOCKER_HOST=tcp://127.0.0.1:2375
setx /M DOCKER_HOST "tcp://127.0.0.1:2375"

wsl --unregister Ubuntu-22.04
wsl --update
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
