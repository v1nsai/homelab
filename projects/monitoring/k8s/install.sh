#!/bin/bash

set -e

echo "Installing prometheus..."
git clone git@github.com:prometheus-operator/kube-prometheus.git projects/monitoring/k8s/kube-prometheus
kubectl create ns monitoring
kubectl apply --server-side -f projects/monitoring/k8s/kube-prometheus/manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f projects/monitoring/k8s/kube-prometheus/manifests/
kubectl patch svc grafana -n monitoring --type='json' -p '[{"op":"replace","path":"/spec/type","value":"LoadBalancer"}]'
# kubectl delete --ignore-not-found=true -f projects/monitoring/k8s/kube-prometheus/manifests/ -f projects/monitoring/k8s/kube-prometheus/manifests/setup

echo "Installing grafana..."
helm upgrade --install grafana-operator oci://ghcr.io/grafana/helm-charts/grafana-operator \
    --create-namespace \
    --namespace monitoring
kubectl apply -f projects/monitoring/k8s/grafana/grafana.yaml -f projects/monitoring/k8s/grafana/datasources.yaml -f projects/monitoring/k8s/grafana/dashboards.yaml -n monitoring
kubectl patch svc grafana-service -n monitoring --type='json' -p '[{"op":"replace","path":"/spec/type","value":"LoadBalancer"}]'
