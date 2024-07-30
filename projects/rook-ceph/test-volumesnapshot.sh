#!/bin/bash

# Set variables
STORAGE_CLASS="cephfs"
CSI_DRIVER="ceph-filesystem"

# Function to wait for resource creation
wait_for_resource() {
    echo "Waiting for $1 $2 to be created..."
    while ! kubectl get $1 $2 &>/dev/null; do
        sleep 2
    done
    echo "$1 $2 created successfully."
}

# Create PVC
cat <<EOF | kubectl apply -f -
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
EOF

wait_for_resource pvc test-pvc

# Create test Pod
cat <<EOF | kubectl apply -f -
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
EOF

wait_for_resource pod test-pod

# Wait for the pod to be ready
echo "Waiting for test-pod to be ready..."
kubectl wait --for=condition=ready pod/test-pod --timeout=60s

# Create VolumeSnapshot
cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: test-snapshot
spec:
  volumeSnapshotClassName: ceph-filesystem
  source:
    persistentVolumeClaimName: test-pvc
EOF

wait_for_resource volumesnapshot test-snapshot

# Create new PVC from snapshot
cat <<EOF | kubectl apply -f -
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
EOF

wait_for_resource pvc restored-pvc

# Create verify Pod
cat <<EOF | kubectl apply -f -
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

wait_for_resource pod verify-pod

# Wait for the verify pod to be ready
echo "Waiting for verify-pod to be ready..."
kubectl wait --for=condition=ready pod/verify-pod --timeout=60s

# Check the logs of verify-pod
echo "Checking the logs of verify-pod:"
kubectl logs verify-pod

echo "Script completed. If you see 'Hello, Kubernetes!' above, the VolumeSnapshot test was successful."