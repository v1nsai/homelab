#!/bin/bash

set -e

PROJECT=$1
REPO_NAME=$(cat projects/$PROJECT/app/helmrepository.yaml | yq '.metadata.name')
REPO_URL=$(cat projects/$PROJECT/app/helmrepository.yaml | yq '.spec.url')
NAMESPACE=$(cat projects/$PROJECT/app.yaml | yq '.metadata.namespace')
CHART_NAME=$(cat projects/$PROJECT/app/helmrelease.yaml | yq '.spec.chart.spec.chart')
RELEASE_NAME=$(cat projects/$PROJECT/app/helmrelease.yaml | yq '.metadata.name')

echo "Project: $PROJECT"
echo "Repository Name: $REPO_NAME"
echo "Repository URL: $REPO_URL"
echo "Namespace: $NAMESPACE"

cat projects/$PROJECT/app/helmrelease.yaml | \
    yq '.spec.values' > /tmp/values.yaml

helm repo add $REPO_NAME $REPO_URL
helm repo update
helm upgrade --install $RELEASE_NAME $CHART_NAME/$REPO_NAME \
    --create-namespace \
    --namespace $NAMESPACE \
    --values /tmp/values.yaml