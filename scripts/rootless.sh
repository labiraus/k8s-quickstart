echo Ensure docker daemon is not running
sudo systemctl disable --now docker.service docker.socket
sudo systemctl stop docker.service docker.socket

echo Setup rootless docker without ip tables
dockerd-rootless-setuptool.sh install --skip-iptables

echo add ip tables
sed -i s/--iptables=false// ~/.config/systemd/user/docker.service

echo Reload docker daemon
loginctl enable-linger $(whoami)
# systemctl --user daemon-reload
# systemctl --user restart docker.service
# sudo systemctl enable docker

echo Enable rootless docker to contact the internet
sudo crudini --set /etc/wsl.conf network generateResolvConf false
sudo rm /etc/resolv.conf && echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
# Generate a private key
openssl genpkey -algorithm RSA -out key.pem

# Generate a public certificate
openssl req -new -key key.pem -x509 -out cert.pem -subj "/C=US/ST=New York/L=Brooklyn/O=Example Brooklyn Company/CN=www.examplebrooklyn.com"

DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="-p 0.0.0.0:2375:2375/tcp" \
  dockerd-rootless.sh \
  -H tcp://0.0.0.0:2375 \
  --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem