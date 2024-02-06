#!/bin/bash

set -e

helm repo add windmill https://windmill-labs.github.io/windmill-helm-charts/
helm upgrade --install windmill windmill/windmill \
    --namespace windmill \
    --create-namespace \
    --set app.autoscaling.enabled=true \
    --set ingress.enabled=true \
    --set ingress.className=traefik \
    --set "ingress.annotations.traefik\.ingress\.kubernetes\.io/router\.tls=true" \
    --set "ingress.annotations.traefik\.ingress\.kubernetes\.io/router\.pathmatcher=Path('windmill')" \
    --set "ingress.annotations.traefik\.ingress\.kubernetes\.io/router\.tls\.domains\.0\.main='windmill.local'"

# kubectl apply -f - <<EOF
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: windmill-app-ingress
#   namespace: windmill  
# spec:
#   rules:
#     - host: bigrig.local
#       http:
#         paths:
#           - path: /windmill
#             pathType: Exact
#             backend:
#               service:
#                 name:  windmill-app
#                 port:
#                   number: 8000
# EOF