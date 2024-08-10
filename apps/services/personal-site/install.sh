#!/bin/bash

kubectl create secret generic wordpress-password \
    --namespace personal-site \
    --from-literal=wordpress-password=$(openssl rand -base64 20) \
    --dry-run=client \
    --output yaml | \
kubeseal --format yaml --cert ./.sealed-secrets.pub > apps/services/personal-site/app/sealed-secrets.yaml

kubectl create secret generic externaldb-password \
    --namespace personal-site \
    --from-literal=mariadb-password=$(openssl rand -base64 20) \
    --dry-run=client \
    --output yaml | \
kubeseal --format yaml --cert ./.sealed-secrets.pub | tee -a apps/services/personal-site/app/sealed-secrets.yaml
