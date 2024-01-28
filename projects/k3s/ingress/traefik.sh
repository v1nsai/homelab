#!/bin/bash

set -e

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik \
    --namespace kube-system