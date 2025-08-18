#!/bin/bash

set -e

# generate local CA key
openssl genrsa -des3 -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1825 -out ca.crt

# Trust the CA
## macos
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" cluster/addons/cert-manager/ca.crt

## linux
sudo apt-get install -y ca-certificates
sudo cp ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates

# Create and seal kubernetes secret
kubectl create secret generic homelab-ca \
    --from-file=ca.crt \
    --from-file=ca.key \
    --namespace kube-system \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./sealed-secrets.pub --format yaml > cluster/addons/cert-manager/homelab-ca-sealed.yaml

# Add CA to cluster
cat <<EOF > /tmp/homelab-ca.yaml
apiVersion: v1alpha1
kind: TrustedRootsConfig
name: homelab-ca
certificates: |
$(cat cluster/addons/cert-manager/ca.crt | sed 's/^/  /')
EOF

talosctl patch machineconfig --nodes 192.168.1.154,192.168.1.161,192.168.1.152 --patch @/tmp/homelab-ca.yaml