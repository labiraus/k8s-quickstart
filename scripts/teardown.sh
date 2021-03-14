#!/bin/bash

docker stop local-dev-control-plane
docker rm local-dev-control-plane 

read -p "Hit any key to end"
