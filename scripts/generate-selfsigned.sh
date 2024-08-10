#!/bin/bash

set -e

# Generate self-signed cert
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=*"

# Create k8s secret yaml and seal it
kubectl create secret tls selfsigned-tls \
    --key=/tmp/tls.key \
    --cert=/tmp/tls.crt \
    --namespace $NAMESPACE \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > sealed-secret.yaml

# Cleanup
rm /tmp/tls.key /tmp/tls.crt 