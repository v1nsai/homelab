#!/bin/bash

set -e
source apps/services/plex/.env

echo "Please enter your Plex Claim token:"
read -r PLEX_CLAIM
echo "Using Plex Claim token: $PLEX_CLAIM"
export PLEX_CLAIM

# generate the plex claim secret
kubectl create secret generic plex-claim \
  --from-literal=plex-claim=$PLEX_CLAIM \
  --namespace plex