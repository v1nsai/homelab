#!/bin/bash

set -e
source projects/traefik/kubernetes/.env

helm upgrade --install traefik traefik/traefik \
    --create-namespace \
    --namespace traefik \
    --set certResolvers.letsencrypt-prod.email="${EMAIL}" \
    --set certResolvers.letsencrypt-prod.storage="/data/acme.json" \
    --set certResolvers.letsencrypt-prod.httpChallenge.entryPoint="web" \
    --set certResolvers.letsencrypt-staging.email="${EMAIL}" \
    --set certResolvers.letsencrypt-staging.storage="/data/acme.json" \
    --set certResolvers.letsencrypt-staging.httpChallenge.entryPoint="web" \
    --set certResolvers.letsencrypt-staging.caServer="https://acme-staging-v02.api.letsencrypt.org/directory"