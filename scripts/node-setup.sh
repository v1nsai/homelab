#!/bin/bash

### Basic prerequisites for a node in the cluster

set -e

sudo apt update
sudo apt upgrade -y
sudo apt install -y docker docker-compose-v2
sudo snap install microk8s --classic
sudo snap install microceph

# aliasing
echo "alias microceph='sudo microceph'" | tee -a ~/.bashrc
echo "alias ceph='sudo ceph'" | tee -a ~/.bashrc
echo "alias kubectl='microk8s kubectl'" | tee -a ~/.bashrc
echo "alias helm='microk8s helm'" | tee -a ~/.bashrc
