#!/bin/bash

set -e

# pull certs from k8s secrets
kubectl get secret dind-client-tls \
    --namespace dind \
    --output jsonpath='{.data.tls\.crt}' \
    | base64 --decode > $HOME/.docker/talos-homelab/cert.pem
kubectl get secret dind-client-tls \
    --namespace dind \
    --output jsonpath='{.data.tls\.key}' \
    | base64 --decode > $HOME/.docker/talos-homelab/key.pem
kubectl get secret dind-client-tls \
    --namespace dind \
    --output jsonpath='{.data.ca\.crt}' \
    | base64 --decode > $HOME/.docker/talos-homelab/ca.pem

# create docker context
docker context create talos-homelab \
  --description "Remote docker daemon on Talos homelab" \
  --docker "host=tcp://dind.internal:2376,ca=$HOME/.docker/talos-homelab/ca.pem,cert=$HOME/.docker/talos-homelab/cert.pem,key=$HOME/.docker/talos-homelab/key.pem"

# force docker to resolve dind.internal properly on MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! grep -q "dind.internal" /etc/hosts; then
    SERVICE_IP=$(kubectl get svc dind-service --namespace dind -o jsonpath='{.spec.clusterIP}')
    echo "$SERVICE_IP dind.internal" | sudo tee -a /etc/hosts
  fi
fi