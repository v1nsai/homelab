#!/bin/bash

set -e


if [ -z "$1" ]; then
    echo "Deleting all namespaces in Terminating state..."
    NAMESPACES=($(kubectl get ns --no-headers | awk '$2=="Terminating" {print $1}'))
    for NAMESPACE in "${NAMESPACES[@]}"; do
        echo "Deleting namespace $NAMESPACE..."
        kubectl get ns $NAMESPACE -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -
    done
    exit 0
fi

NAMESPACE=$1

# list all resources in namespace
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $NAMESPACE

read -sn1 -p "Force delete namespace $NAMESPACE? [y/N] " CONFIRM
if [ "$CONFIRM" == "y" ]; then
    echo "Deleting namespace $NAMESPACE..."
    kubectl get ns $NAMESPACE -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -
    exit 0
fi
