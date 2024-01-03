#!/bin/bash

# NOTE: Some tutorials may recommend using this script
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
# However it does not work on WSL 2 and just recommends getting docker desktop. 
# Instead, use the following script:


echo -e "\e[34mUpgrade apt\e[0m"
sudo apt update && sudo apt upgrade -y

echo -e "\e[34mClean up old versions of Docker\e[0m"
sudo apt remove docker docker-engine docker.io containerd runc

echo -e "\e[34mInstall dependencies\e[0m"
sudo apt install --no-install-recommends apt-transport-https ca-certificates curl gnupg2 -y

echo -e "\e[34mConfigure package repository\e[0m"
. /etc/os-release
curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update

echo -e "\e[34mInstall docker\e[0m"
sudo apt install socat docker-ce docker-ce-cli dbus-user-session docker-compose-plugin docker-buildx-plugin screen -y

echo -e "\e[34mAdd user to docker group and set up system wide group\e[0m"
sudo usermod -aG docker $USER
sudo groupmod -g 36257 docker

echo -e "\e[34mUSE LEGACY IP TABLES (1)\e[0m"
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy


echo -e "\e[31Setup shared docker socket\e[0m"
DOCKER_DIR=~/shared-docker
mkdir -pm o=,ug=rwx "$DOCKER_DIR"
sudo chgrp docker "$DOCKER_DIR"
touch $DOCKER_DIR/docker.sock

echo -e "\e[34mConfigure docker daemon to use shared socket\e[0m"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "hosts": ["unix://$DOCKER_DIR/docker.sock"]
}
EOF
echo "export DOCKER_HOST=\"unix://$DOCKER_DIR/docker.sock\"" >> ~/.bashrc

echo -e "\e[34mEnsure docker socket is exposed on port 2375\e[0m"
sudo tee /etc/init.d/socat-startup <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:          socat-startup
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start socat at boot time
# Description:       Enable service provided by socat.
### END INIT INFO
socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:$DOCKER_DIR/docker.sock &
# This is for kind
socat TCP-LISTEN:8080,fork TCP:172.19.255.201:80 &
EOF
sudo chmod +x /etc/init.d/socat-startup
sudo update-rc.d socat-startup defaults
sudo service socat-startup start

echo -e "\e[34mEdit docker.service pull config from /etc/docker/daemon.json\e[0m"
sudo sed -i 's|ExecStart=.*|ExecStart=/usr/bin/dockerd|' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

echo -e "\e[34mInstall docker buildkit\e[0m"
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/buildx/releases/download/v0.6.3/buildx-v0.6.3.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx


echo -e "\e[34mInstalling KinD directly onto wsl as it won't work cross platform\e[0m"
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
bash setup/kind.sh

echo -e "\e[34mStarting a screen session. Hit enter and then detatch with Ctrl+A D\e[0m"
read -p "Press enter to continue"
screen