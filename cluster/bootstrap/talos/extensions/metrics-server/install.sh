#!/bin/bash

set -e

# Install patch on all nodes
talosctl patch machineconfig \
    --endpoints 192.168.1.133 \
    --nodes 192.168.1.162,192.168.1.155,192.168.1.170 \
    --patch-file cluster/bootstrap/talos/extensions/metrics-server/patch.yaml

# Install kubelet serving cert approver and metrics-server
kubectl apply -f https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
