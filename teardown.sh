#!/bin/bash

name="${1:-local-dev}"

docker stop $name-control-plane
docker rm $name-control-plane 

read -p "Hit any key to end"
