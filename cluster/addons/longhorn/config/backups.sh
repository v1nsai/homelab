#!/bin/bash

set -e
source cluster/addons/longhorn/.env
REGION=$(aws configure get region)

if [ -z "$BUCKET" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Please create an IAM user and set the BUCKET, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in cluster/addons/longhorn/.env"
    exit 1
fi

echo "Creating backup location secrets..."
source cluster/addons/longhorn/.env
kubectl create secret generic backup-target-credentials \
    --namespace longhorn-system \
    --from-literal AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    --from-literal AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    --dry-run=client \
    --output yaml | kubeseal --cert ./.sealed-secrets.pub --format yaml > cluster/addons/longhorn/app/sealed-secrets.yaml
