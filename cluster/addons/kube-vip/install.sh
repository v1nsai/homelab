#!/bin/bash

set -e

echo "Creating RBAC settings..."
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

echo "Generating a manifest..."
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
# alias kube-vip="ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip"
alias kube-vip="docker run --network host --rm ghcr.io/kube-vip/kube-vip:$KVVERSION"

kube-vip manifest daemonset \
    --inCluster \
    --taint \
    --services \
    --arp \
    --servicesElection \
    --enableLoadBalancer 

    # --leaderElection \
