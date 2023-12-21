#!/bin/bash

set -e

# TODO DELETE FOR TESTING ONLY
kubectl delete -f projects/plex/blackbox.yaml || true
# helm uninstall csi-driver-nfs -n kube-system || true

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.214 \
    --set nfs.path=/mnt/blackbox

# helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
# helm repo update
# helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
#     --namespace kube-system \
#     --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet \
#     --set externalSnapshotter.enabled=true \
#     --set controller.runOnControlPlane=true \
#     --set controller.replicas=2 \
#     --set controller.dnsPolicy=ClusterFirstWithHostNet \
#     --set node.dnsPolicy=ClusterFirstWithHostNet \
#     --set kubeletDir="/var/snap/microk8s/common/var/lib/kubelet"

kubectl apply -f projects/plex/blackbox.yaml
kubectl logs --selector app=csi-nfs-controller -n kube-system -c nfs

# git clone git@github.com:munnerz/kube-plex.git projects/plex/kube-plex || true
# source projects/plex/.env
# kubectl create namespace plex || true
# helm install plex ./projects/plex/kube-plex/charts/kube-plex \
#     --namespace plex \
#     --set claimToken=$PLEX_CLAIM \
#     --set service.type=NodePort \
#     --set service.port=32400 \
#     --set persistence.data.claimName=blackbox-nfs-pvc

