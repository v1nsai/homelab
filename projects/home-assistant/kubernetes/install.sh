#!/bin/bash

 set -e

helm repo add pajikos http://pajikos.github.io/home-assistant-helm-chart/
helm repo update
helm upgrade --install home-assistant pajikos/home-assistant \
    --create-namespace \
    --namespace home-assistant \
    --set service.type=LoadBalancer \
    --set service.port=80