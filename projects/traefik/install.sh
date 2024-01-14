#!/bin/bash

set -e

# source projects/traefik/secrets.env

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik \
    --set service.type=NodePort