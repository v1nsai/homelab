#!/bin/bash

set -e


echo "Deleting remaining resources in $1..."
export NAMESPACE="$1"

# list all resources in namespace
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $NAMESPACE
# TODO add some awk/sed fu to automate deleting all the resources from the previous command
kubectl get ns $NAMESPACE -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -


# echo "Removing finalizers from namespace $NAMESPACE..."
# kubectl get namespace -o json $NAMESPACE > stuck.json
# jq '.spec.finalizers = []' stuck.json > stuck.nofinalizers.json
# kubectl proxy &
# PROXY_PID=$!
# curl -k -H "Content-Type: application/json" -X PUT --data-binary @stuck.nofinalizers.json http://127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize

# echo "Cleaning up..."
# kill $PROXY_PID
# rm stuck.json

# kubectl delete namespace $NAMESPACE --wait=false --grace-period=0 --force
# kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n $NAMESPACE | awk '{print $1}' | xargs -n 1 kubectl delete -n $NAMESPACE --grace-period=0 --force
