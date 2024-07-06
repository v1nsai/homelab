#!/bin/bash

set -e
source projects/fluxcd/secrets.env

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
  --personal