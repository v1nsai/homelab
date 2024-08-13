#!/bin/bash

set -e

# Install k3sup
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

# visudo command to remove password for sudo group

# Generate bootstrap script
k3sup plan \
  cluster/bootstrap/k3s/nodes.json \
  --user doctor_ew \
  --servers 3 \
  --server-k3s-extra-args "--disable traefik" \
  --background > cluster/bootstrap/k3s/bootstrap.sh
chmod +x cluster/bootstrap/k3s/bootstrap.sh

# add --ssh-key ~/.ssh/homelab to the commands in the bootstrap.sh script

# Run bootstrap script
cluster/bootstrap/k3s/bootstrap.sh

mv kubeconfig ~/.kube/config