#!/bin/bash

source apps/data-science/kubeflow/.env
set -e

# TODO make a gitops way to do this with a k8s job or something
sudo snap install juju --channel=3.4/stable
sudo cat /etc/rancher/k3s/k3s.yaml | juju add-k8s k3s-homelab --client
juju bootstrap k3s-homelab uk8sx
juju deploy kubeflow --trust --channel=1.9/stable
juju config dex-auth static-username=admin
juju config dex-auth static-password="$PASS"