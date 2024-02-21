#!/bin/bash

set -e

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --create-namespace \
    --namespace kubernetes-dashboard \
    --set web.containers.args='{--token-ttl=0}'

scripts/selfsigned-tls-secret.sh kubernetes-dashboard

kubectl apply -f - <<EOF
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ingressroute
  namespace: kubernetes-dashboard
spec:
  entryPoints:
    - kubernetes-dashboard
  routes:
    - match: HostSNI(`*`)
      kind: Rule
      services:
        - name: kubernetes-dashboard
          kind: Service
          port: 443
  tls:
    secretName: tls-selfsigned
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    entrypoints:
      kubernetes-dashboard:
        address: :13443
EOF

# kubectl apply -f - <<EOF
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: kube-dash
#   namespace: kubernetes-dashboard
#   annotations:
#     traefik.ingress.kubernetes.io/router.tls: "true"
# spec:
#   ingressClassName: traefik
#   tls:
#   - hosts:
#     - oppenheimer.local
#     secretName: selfsigned-tls
#   rules:
#   - host: oppenheimer.local
#     http:
#       paths:
#       - path: /dashboard
#         pathType: Prefix
#         backend:
#           service:
#             name: kubernetes-dashboard
#             port:
#               number: 443
# EOF