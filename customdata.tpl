#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker adminuser
sudo docker login -u "devacr20240724" -p "5GceqB05Gxl/tJCcCPAvJL2KY9rZzsZe/YywGSHt3A+ACRBT485I" devacr20240724.azurecr.io
sudo docker pull devacr20240724.azurecr.io/nginx:latest
sudo docker run --name nginx-container -d -p 8080:80 nginx