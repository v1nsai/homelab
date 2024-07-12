#!/bin/bash

set -e
source projects/fluxcd/fluxcd.env

echo "Installing fluxcd..."
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_REPO" ]; then
  echo "GITHUB_TOKEN, GITHUB_USER and GITHUB_REPO must be set in projects/fluxcd/secrets.env"
  exit 1
fi
flux bootstrap github \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=develop \
  --path=projects/fluxcd/ \
  --personal \
  --components-extra image-reflector-controller,image-automation-controller

echo "Installing weave gitops UI..."
if [ -z "$WW_DASH_PASS" ]; then
    WW_DASH_PASS="$(openssl rand -base64 20)"
    echo "$WW_DASH_PASS" | tee -a ./projects/fluxcd/fluxcd.env
fi
gitops create dashboard ww-gitops \
  --password=$WW_DASH_PASS \
  --export > ./projects/fluxcd/flux-system/weave-gitops.yaml
