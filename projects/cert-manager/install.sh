#!/bin/bash

set -e
# source projects/cert-manager/secrets.env

echo "Installing cert-manager, this may take a few minutes..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
    --debug \
    --namespace cert-manager \
    --create-namespace \
    --version v1.12.7 \
    --set installCRDs=true \
    --set webhook.enabled=true\
    --set webhook.hostNetwork=true \
    --set webhook.securePort=10255
    
echo "Setting up ClusterIssuers for staging and prod..."
kubectl apply -f projects/cert-manager/clusterissuers.yaml
