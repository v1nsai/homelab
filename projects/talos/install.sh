#!/bin/bash

set -e

cluster_ips=(192.168.1.170 192.168.1.162 192.168.1.155)

talosctl gen secrets -o projects/talos/secrets.yaml
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types talosctl \
  --output ~/.talos/config \
  talos-homelab https://192.168.1.133:6443
talosctl --talosconfig=~/.talos/config config endpoint 192.168.1.170 192.168.1.162 192.168.1.155

# bigrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  talos-homelab https://192.168.1.170:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.170 \
  --file /tmp/bigrig.yaml \
  --config-patch @projects/talos/install-patches/bigrig-patch.yaml
talosctl bootstrap \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170

# tiffrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/tiffrig.yaml \
  talos-homelab https://192.168.1.155:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.155 \
  --file /tmp/tiffrig.yaml \
  --config-patch @projects/talos/install-patches/tiffrig-patch.yaml

# oppenheimer
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/oppenheimer.yaml \
  talos-homelab https://192.168.1.162:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.162 \
  --file /tmp/oppenheimer.yaml \
  --config-patch @projects/talos/install-patches/oppenheimer-patch.yaml

# nvidia
talosctl patch machineconfig \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --patch-file projects/talos/nvidia/nvidia-patch.yaml
talosctl upgrade \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --image factory.talos.dev/installer/0412a9a6369c0fb55e913cdfcbf4ad6ca3fab6e56ab71198ec4b58ad7e7a4ddd:v1.7.5
  # --image ghcr.io/siderolabs/installer:v1.7.5
  # --reboot-mode powercycle
  # --stage

## allow running privileged containers in nvidia namespace
kubectl apply -f projects/talos/nvidia/runtimeclass.yaml
kubectl create ns nvidia-device-plugin
kubectl label --overwrite namespace nvidia-device-plugin \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/enforce-version=latest \
    pod-security.kubernetes.io/warn=privileged \
    pod-security.kubernetes.io/warn-version=latest \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/audit-version=latest

## label GPU nodes
kubectl label nodes bigrig nvidia.com/gpu.present=true

helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade --install nvidia-device-plugin nvdp/nvidia-device-plugin \
    --create-namespace \
    --namespace nvidia-device-plugin \
    --set=runtimeClassName=nvidia

