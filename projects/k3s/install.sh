#!/bin/bash

### Run this script from master node ###

set -e

echo "Installing k3s on $(hostname)..."
curl -sfL https://get.k3s.io | sh -s - server \
    --cluster-init

echo "Getting token info..."
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL="https://$(hostname -I | awk '{print $1}'):6443"

echo ""
echo "Copy and paste the following command on other server nodes to join the cluster:"
echo "curl -sfL https://get.k3s.io | K3S_TOKEN='$K3S_TOKEN' sh -s - server \
    --server '$K3S_URL'"
echo ""
echo "Copy and paste the following command on agent nodes to join the cluster:"
echo "curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -"
echo ""

# uncomment to automatically install k3s on other servers from server names in ~/.ssh/config
# servers=("ASUSan" "oppenheimer")
# for server in "${servers[@]}"; do
#     echo "Installing k3s on $server..."
#     ssh $server "curl -sfL https://get.k3s.io | K3S_TOKEN='$K3S_TOKEN' sh -s - server \
#         --server '$K3S_URL'"
# done

sudo cp -f projects/k3s/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/
kubectl apply -f projects/k3s/traefik-config.yaml
