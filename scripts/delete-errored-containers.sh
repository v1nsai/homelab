#!/bin/bash

kubectl get pods --all-namespaces --field-selector=status.phase=Failed -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | while read namespace pod; do kubectl delete pod "$pod" -n "$namespace"; done