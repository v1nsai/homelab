#!/bin/bash

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf

# Set hostname and enable services at boot
sudo hostnamectl set-hostname $HOSTNAME
sudo systemctl enable --now crio kubelet

# Initialize the cluster on master node
sudo kubeadm init --config /etc/kubeadm/clusterconfig.yaml --upload-certs
# sudo kubeadm init phase upload-certs --upload-certs
# kubeadm token create --print-join-command
# add --control-plane and --certificate-key
sudo chmod 644 /etc/kubernetes/admin.conf
scp bigrig:/etc/kubernetes/admin.conf ~/.kube/config

# Configure flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Configure kube-vip
# set a common altname for the vip interfaces
sudo ip link property add dev enp10s0 altname eth0
sudo ip link property add dev eno1 altname eth0
# Install kube-vip
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
alias kube-vip="docker run --network host --rm ghcr.io/kube-vip/kube-vip:$KVVERSION"
kube-vip manifest daemonset \
    --interface eth0 \
    --address 192.168.1.133 \
    --inCluster \
    --taint \
    --controlplane \
    --services \
    --arp \
    --leaderElection > kube-vip.yaml
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml
kubectl apply -f kube-vip.yaml

# Make the kube-vip vip address the control plane endpoint
kubectl get configmap kubeadm-config -n kube-system -o yaml > kubeadm-config.yaml
awk '{if ($0 ~ /^[[:space:]]*clusterName: kubernetes$/) {print $0 "\n    controlPlaneEndpoint: 192.168.1.133:6443"} else {print}}' kubeadm-config.yaml > kubeadm-config.yaml.tmp
mv kubeadm-config.yaml.tmp kubeadm-config.yaml
kubectl apply -f kubeadm-config.yaml
rm -rf kubeadm-config.yaml

# Allow all control-plane nodes to run pods
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
