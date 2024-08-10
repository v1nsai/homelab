#!/bin/bash

set -e
source cluster/bootstrap/fluxcd/fluxcd.env

echo "Installing fluxcd..."
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN, GITHUB_USER and GITHUB_REPO must be set in cluster/bootstrap/fluxcd/secrets.env"
  exit 1
fi
flux bootstrap github \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=develop \
  --path=cluster/bootstrap/fluxcd/ \
  --personal \
  --components-extra image-reflector-controller,image-automation-controller

echo "Installing weave gitops UI..."
if [ -z "$WW_DASH_PASS" ]; then
    WW_DASH_PASS="$(openssl rand -base64 20)"
    echo "WW_DASH_PASS='$WW_DASH_PASS'" | tee -a ./cluster/bootstrap/fluxcd/fluxcd.env
fi
gitops create dashboard ww-gitops \
  --password=$WW_DASH_PASS \
  --export > ./cluster/bootstrap/fluxcd/extensions/weave-gitops.yaml

read -sn1 -p "Generate a tls cert and key for sealed secrets? [y/n]" GENERATE
if [ "$GENERATE" == "y" ]; then
  echo "Generating tls cert and key for sealed secrets..."
  mkdir -p ./cluster/bootstrap/fluxcd/secrets
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./cluster/bootstrap/fluxcd/secrets/tls.pem \
    -out ./cluster/bootstrap/fluxcd/secrets/tls.crt \
    -subj "/CN=sealed-secrets/O=sealed-secrets"
fi

# get sealed secret keys from safe place (bitwarden)
kubectl create secret tls sealed-secrets-key \
  --cert=cluster/bootstrap/fluxcd/secrets/tls.crt \
  --key=cluster/bootstrap/fluxcd/secrets/tls.pem \
  --namespace flux-system