#!/bin/bash

set -e

helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm upgrade --install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --create-namespace \
    --version v4.7.0 \
    --values projects/csi-driver-nfs/values.yaml
