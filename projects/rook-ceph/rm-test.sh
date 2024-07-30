#!/bin/bash

kubectl delete -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: $STORAGE_CLASS
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["/bin/sh", "-c", "echo 'Hello, Kubernetes!' > /data/test.txt && sleep 3600"]
    volumeMounts:
    - name: test-volume
      mountPath: /data
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: test-pvc
---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
spec:
  volumeSnapshotClassName: ceph-filesystem
  source:
    persistentVolumeClaimName: test-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: $STORAGE_CLASS
  resources:
    requests:
      storage: 1Gi
  dataSource:
    name: test-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
---
apiVersion: v1
kind: Pod
metadata:
  name: verify-pod
spec:
  containers:
  - name: verify-container
    image: busybox
    command: ["/bin/sh", "-c", "cat /data/test.txt && sleep 3600"]
    volumeMounts:
    - name: restored-volume
      mountPath: /data
  volumes:
  - name: restored-volume
    persistentVolumeClaim:
      claimName: restored-pvc
EOF