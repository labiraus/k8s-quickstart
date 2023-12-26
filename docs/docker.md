# Docker

## Overview

This repo is based around building a local development kubernetes environment. A number of different alternatives were attempted but running kubernetes on docker via kind, minikube, or k3s was the most stable option. In order to run any of these, a linux based docker environment is required.

## Docker Desktop

On windows, docker desktop requires a license for large companies. For solo developers, small businesses, and large businesses that are prepared to pay for licensing, Docker Desktop is by far the best option and makes everything much easier. When run it allows the use of linux containers by running within a linux virtual machine. 

Using docker engine on windows will not work for this system as it can only run windows containers. If you use docker desktop then you'll need to set it to use linux containers. If you don't want to use docker desktop then you can instead get linux containers by running docker on Windows Subsystem for Linux (wsl).

## WSL2

WSL-2 is a major advancement over WSL that came out in may 2019, and when looking up information on it, check whether it's for wsl or wsl2.

Whenever you want to run a linux command on WSL from within a windows terminal you can either open up the wsl terminal with `wsl` or pipe the command directly into wsl:

> wsl -- <command>

Whilst docker is able to be run and interacted with on the wsl instance that it is installed, it can also be exposed over a local tcp port. This allows the windows docker cli to connect to the linux docker engine using the DOCKER_HOST environment variable.

### WSL2 Docker Installation

Setting up WSL2 is relatively straightforward on modern windows following <https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9> and <https://nickjanetakis.com/blog/install-docker-in-wsl-2-without-docker-desktop>. The highlights of which are:

- To share Docker daemon between windows and WSL, it is configured to use a tcp socket
- So that sharing and privileged access without sudo are possible, the docker group is configured to have the same group ID across all WSL instances
- For simplicity, docker is launched inside wsl rather than a Windows-based Docker client
- screen is used to keep docker alive after the wsl session has ended

In order to install wsl and docker, first install ubuntu 22.04 on wsl with the `wsl-install.ps1` script, then exit and run the `wsl-setup.sh` script. 

> bash setup/wsl-install.sh

> exit

> wsl -- setup/wsl-setup.sh

The first script will install the windows docker-cli which requires elevated permissions, then set the docker host and install ubuntu-22.04. The installation will create a unbuntu wsl-2 instance and log into it for the first time so that a new username and password can be setup. Exit this, then run the second script which will install docker on wsl. After this you should be able to communicate with the linux based dockerd running on wsl from the windows system.

The reason why `wsl-install.ps1` is a powershell script rather than a bash script is that the below command is needed to set the DOCKER_HOST variable system wide. This allows all tools on the windows system to communicate with the wsl docker host, rather than being an environment variable.  

> setx /M DOCKER_HOST "tcp://localhost:2375"

Because docker is tied to the wsl session, we use `screen` to keep it alive when a wsl session is closed. To start a screen session run `screen` then use `Ctrl-A` and `D` to leave it running in the background. To reattach to a running screen run `screen -r`

> wsl
> screen
> [Enter]
> [Ctrl]+[A] [D]
> exit