#!/bin/bash

set -e

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm upgrade --install nvidia-gpu-operator nvidia/gpu-operator \
    --create-namespace \
    --namespace nvidia-gpu-operator \
    --values projects/nvidia-gpu-operator/values.yaml

# sudo vim /var/snap/microk8s/current/args/containerd.toml
# sudo systemctl restart snap.microk8s.daemon-containerd.service

# ignore tiffrig since GPU is too old
kubectl label node tiffrig nvidia.com/gpu.deploy.operands=false