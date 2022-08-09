#!/bin/bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg-agent

# install docker on ubuntu
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# adjust user privileges 
sudo usermod -a -G docker $USER
sudo usermod -a -G docker ubuntu

# install docker-compose % adjust file permissions
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose
chmod +x /tmp/docker-compose
sudo mv /tmp/docker-compose /usr/local/bin/docker-compose

# add componets for wp and nginx
mkdir -p /var/opt/wp
mkdir -p /var/opt/wp/nginx
cd /var/opt/wp

echo "${dockercompose}" > docker-compose.yml
echo "${nginx_conf}" > nginx/server.conf

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# bring up docker compose in detached mode
docker-compose up -d