#!/bin/bash

set -e

helm repo add localstack-repo https://helm.localstack.cloud
helm upgrade --install localstack localstack-repo/localstack \
    --namespace localstack \
    --create-namespace \
    --set service.type=LoadBalancer \
    --set ingress.enabled=true \
    --set ingress.hosts[0].host=localstack.internal \
    --set ingress.hosts[0].paths[0].path=/ \
    --set ingress.hosts[0].paths[0].pathType=Prefix

alias aws="AWS_ENDPOINT_URL=http://localstack.internal:4566 awslocal"
