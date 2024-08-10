#!/bin/bash

set -e

STORAGECLASS="$1"
if [ -z "$STORAGECLASS" ]; then
  echo "Usage: storageclass-test.sh <storageclass>"
  exit 1
fi

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "sh", "-c", "echo 'Hello, Kubernetes! I am a test pod!' > /data/index.html && sleep infinity" ]
      volumeMounts:
        - name: test-volume
          mountPath: /data
  volumes:
    - name: test-volume
      persistentVolumeClaim:
        claimName: test-pvc
EOF

read -sn1 -p "Delete test resources? [y/N] " DELETE
if [ "$DELETE" = "y" ]; then
  kubectl delete pod test-pod --grace-period=0 --force
  kubectl delete pvc test-pvc --grace-period=0 --force
fi