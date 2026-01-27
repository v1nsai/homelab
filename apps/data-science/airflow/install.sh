#!/bin/bash

set -e

POSTGRES_PASSWORD=$(openssl rand -base64 32)
kubectl create secret generic postgres-password \
    --from-literal=POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
    --from-literal=POSTGRES_USER=airflow \
    --from-literal=POSTGRES_DB=airflow \
    --namespace=airflow \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub >> apps/data-science/airflow/app/sealed-secrets.yaml

CONNECTION_STRING="postgresql://airflow:${POSTGRES_PASSWORD}@postgres.airflow.svc.cluster.local:5432/airflow"
kubectl create secret generic airflow-database \
    --from-literal=connection="${CONNECTION_STRING}" \
    --namespace=airflow \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub >> apps/data-science/airflow/app/sealed-secrets.yaml
