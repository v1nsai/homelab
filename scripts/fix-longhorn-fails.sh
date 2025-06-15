#!/bin/bash

set -e

scaleDown() {
  echo "Scaling down all deployments, replicasets, and statefulsets in the namespace..."
    # Scale down all deployments in this namespace
  for deploy in $(kubectl get deploy -n "$namespace" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl scale deployment "$deploy" -n "$namespace" --replicas=0
  done

  echo "Scaling down standalone ReplicaSets (not owned by Deployments)..."
  for replicaset in $(kubectl get replicaset -n "$namespace" -o json | jq -r '.items[] | select(.metadata.ownerReferences == null) | .metadata.name'); do
    kubectl scale replicaset "$replicaset" -n "$namespace" --replicas=0
  done

  echo "Scaling down statefulsets..."
  for sts in $(kubectl get statefulsets -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl scale statefulset "$sts" -n "$ns" --replicas=0
  done
}

scaleUp() {
  echo "Scaling up all deployments, replicasets, and statefulsets in the namespace $namespace..."
  echo "Scaling all deployments in namespace $namespace back up to 1..."
  for deploy in $(kubectl get deploy -n "$namespace" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl scale deployment "$deploy" -n "$namespace" --replicas=1
  done

  echo "Scaling up standalone replicasets not owned by deployments in $namespace..."
  for replicaset in $(kubectl get replicaset -n "$namespace" -o json | jq -r '.items[] | select(.metadata.ownerReferences == null) | .metadata.name'); do
    kubectl scale replicaset "$replicaset" -n "$namespace" --replicas=1
  done

  echo "Scaling up statefulsets in namespace $ns..."
  for sts in $(kubectl get statefulsets -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl scale statefulset "$sts" -n "$ns" --replicas=1
  done
}

# Loop through all namespaces
for namespace in $(kubectl get namespace -o jsonpath='{.items[*].metadata.name}'); do
  echo "Checking namespace: $namespace"

  # Loop through all PVCs in the namespace
  for pvc in $(kubectl get pvc -n "$namespace" -o jsonpath='{.items[*].metadata.name}'); do
    # Get the volume name bound to the PVC
    volume_name=$(kubectl get pvc "$pvc" -n "$namespace" -o jsonpath='{.spec.volumeName}')

    # Skip if no volume name
    if [ -z "$volume_name" ]; then
      continue
    fi

    # Get the associated Longhorn volume's replicas
    replicas=$(kubectl get replicas.longhorn.io -n longhorn-system -o json | jq -r --arg volume "$volume_name" '.items[] | select(.spec.volumeName == $volume) | .metadata.name')

    for replica in $replicas; do
      # Check if failedAt is non-empty
      failed_at=$(kubectl get replicas.longhorn.io "$replica" -n longhorn-system -o jsonpath='{.spec.failedAt}')

      if [ -n "$failed_at" ]; then
        echo "Replica $replica is faulted (failedAt=$failed_at). Taking action in namespace $namespace..."

        scaleDown

        # Patch the replica to clear failedAt
        kubectl patch replicas.longhorn.io "$replica" -n longhorn-system --type='merge' -p '{"spec": {"failedAt": ""}}'
      fi
    done

    scaleUp

  done
done
