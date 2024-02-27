#!/bin/bash

### Basic prerequisites for a node in the cluster

set -e

sudo apt update
sudo apt upgrade -y
sudo apt install -y docker docker-compose-v2
sudo snap install microk8s --classic
# sudo snap install microceph

# aliasing
sudo snap alias microk8s.kubectl kubectl
sudo snap alias microk8s.kubectl k
sudo snap alias microk8s.helm helm
# echo "alias ceph='sudo ceph'" | tee -a ~/.bashrc
# echo "alias microceph='sudo microceph'" | tee -a ~/.bashrc

# add user to group
sudo usermod -a -G microk8s $USER
sudo mkdir -p ~/.kube
sudo chown -f -R $USER ~/.kube

# enable microk8s addons
microk8s enable dns
microk8s enable hostpath-storage
microk8s enable ingress

# enable dashboard
microk8s enable dashboard
kubectl apply -f projects/microk8s/dashboard-ingress.yaml

# enable metallb
microk8s enable metallb:10.13.55.0/24
kubectl apply -f projects/microk8s/metallb-ingress.yaml

# enable traefik ingress
helm install traefik traefik/traefik \
    --namespace traefik \
    --create-namespace 