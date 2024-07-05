#!/bin/bash

set -e

echo "Installing Argo CD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argo-cd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --values projects/argo/argo-cd/values.yaml

echo "Deploying argocd image updater to kubernetes..."
kubectl apply \
    --filename https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml \
    --namespace argocd

echo "Installing argocd-image-updater binary..."
wget https://github.com/argoproj-labs/argocd-image-updater/releases/download/v0.13.1/argocd-image-updater-linux_amd64 -O /usr/bin/argocd-image-updater

echo "Running post install config..."
kubectl patch svc -n argocd argo-cd-argocd-server -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch configmap argocd-cm -n argocd --type merge --patch '{"data": {"resourceTrackingMethod": "annotation+label"}}'
