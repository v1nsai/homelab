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

read -sn1 -p "Install secrets management with SOPS? [y/N]" SOPS
if [ "$SOPS" == "y" ]; then
  echo "Installing SOPS..."
  sudo curl -L https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64 -o /usr/local/bin/sops
  sudo chmod +x /usr/local/bin/sops

  export KEY_NAME="microk8s"
  export KEY_COMMENT="flux secrets"
  gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF

  # get fingerprint from output and put in KEY_FP
  gpg --list-secret-keys "${KEY_NAME}"
  # export KEY_FP
  gpg --export-secret-keys --armor "${KEY_FP}" |
  kubectl create secret generic sops-gpg \
    --namespace=flux-system \
    --from-file=sops.asc=/dev/stdin

  echo "Configuring in-cluster secrets decryption..."
  flux create kustomization sops-config \
    --source=flux-system \
    --path=./projects/ \
    --prune=true \
    --interval=10m \
    --decryption-provider=sops \
    --decryption-secret=sops-gpg

  # example usage
  # kubectl -n default create secret generic basic-auth \
  #   --from-literal=user=admin \
  #   --from-literal=password=change-me \
  #   --dry-run=client \
  #   -o yaml > basic-auth.yaml
  # sops --encrypt --in-place basic-auth.yaml
  # git add basic-auth.yaml && git commit -m "Encrypt basic-auth secret"
fi
