#!/bin/bash

set -e

# kubectl patch storageclass nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet \
    --set controller.dnsPolicy=ClusterFirstWithHostNet \
    --set node.dnsPolicy=ClusterFirstWithHostNet \
    --set externalSnapshotter.enabled=true \
    --set driver.name=nfs.csi.k8s.io 
    # --set controller.runOnControlPlane=true \
    # --set controller.replicas=2

MountVolume.SetUp failed for volume "pvc-1517830f-3016-4793-8c7c-ad04b444f9c1" : mount failed: exit status 32 Mounting command: mount Mounting arguments: -t nfs -o vers=3 10.152.183.242:/export/pvc-1517830f-3016-4793-8c7c-ad04b444f9c1 /var/snap/microk8s/common/var/lib/kubelet/pods/bf9c6c4e-f3b5-4706-877b-d8cb8eee066a/volumes/kubernetes.io~nfs/pvc-1517830f-3016-4793-8c7c-ad04b444f9c1 Output: mount.nfs: Connection timed out

kubectl get pods -n nextcloud -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.volumes[*]}{.persistentVolumeClaim.claimName}{"\n"}{end}{end}' | grep nextcloud

helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set driver.name="nfs.csi.k8s.io" \
    --set controller.name="csi-nfs-controller" \
    --set rbac.name=nfs \
    --set serviceAccount.controller=csi-nfs-controller-sa \
    --set serviceAccount.node=csi-nfs-node-sa \
    --set node.name=csi-nfs-node \
    --set node.livenessProbe.healthPort=39653