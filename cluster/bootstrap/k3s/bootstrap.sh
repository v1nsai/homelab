#!/bin/sh

set -e

echo "Setting up primary server 1"
k3sup install --host 192.168.1.170 \
--user doctor_ew \
--ssh-key ~/.ssh/homelab \
--cluster \
--local-path kubeconfig \
--context default \
--k3s-extra-args "--disable traefik"

echo "Fetching the server's node-token into memory"

export NODE_TOKEN=$(k3sup node-token --host 192.168.1.170 --user doctor_ew --ssh-key ~/.ssh/homelab)

echo "Setting up additional server: 2"
k3sup join \
--host 192.168.1.155 \
--server-host 192.168.1.170 \
--server \
--node-token "$NODE_TOKEN" \
--user doctor_ew \
--ssh-key ~/.ssh/homelab \
--k3s-extra-args "--disable traefik" &

echo "Setting up additional server: 3"
k3sup join \
--host 192.168.1.162 \
--server-host 192.168.1.170 \
--server \
--node-token "$NODE_TOKEN" \
--user doctor_ew \
--ssh-key ~/.ssh/homelab \
--k3s-extra-args "--disable traefik" &

