#!/bin/bash


choco install -y docker-cli
choco update -y docker-cli
export DOCKER_HOST="tcp://localhost:2375"

wsl --update
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
