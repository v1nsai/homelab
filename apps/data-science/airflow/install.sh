#!/bin/bash

set -e

WEBSERVER_SECRET=$(openssl rand -base64 32)
kubectl create secret generic webserver-secret \
    --from-literal=webserver-secret-key=${WEBSERVER_SECRET} \
    --namespace=airflow \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > apps/data-science/airflow/app/sealed-secrets.yaml

# if db migrations won't start, run this command in one of the wait-for-migrations containers
# airflow db migrate