#!/bin/bash

set -e

# git clone git@github.com:kubernetes-csi/external-snapshotter.git projects/external-snapshotter/external-snapshotter
cd projects/external-snapshotter/external-snapshotter
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
