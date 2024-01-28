#!/bin/bash

### Run this script from master node ###

set -e

# curl -sfL https://get.k3s.io | sh -s - server \
#     --cluster-init
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL="https://$(hostname -I | awk '{print $1}'):6443"

servers=("ASUSan" "oppenheimer")
for server in "${servers[@]}"; do
    ssh $server "curl -sfL https://get.k3s.io | K3S_TOKEN='$K3S_TOKEN' sh -s - server \
        --server '$K3S_URL'"
done

# sudo cp projects/k3s/traefik-dashboard.yaml /var/lib/rancher/k3s/server/manifests/
