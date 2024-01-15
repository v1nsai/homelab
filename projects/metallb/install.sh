#!/bin/bash

set -e

# source projects/metallb/secrets.env

helm upgrade --install metallb-system oci://registry-1.docker.io/bitnamicharts/metallb \
    --namespace metallb-system \
    --create-namespace

kubectl replace --raw "/api/v1/namespaces/cert-manager/finalize" -f ./cert-manager.json