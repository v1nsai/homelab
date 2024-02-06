#!/bin/bash

set -e

# helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
#     --create-namespace \
#     --namespace kubernetes-dashboard \
#     --set web.containers.args='{--token-ttl=0}' 

kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kube-dash
  namespace: kubernetes-dashboard
  annotations:
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - oppenheimer.local
    secretName: selfsigned-tls
  rules:
  - host: oppenheimer.local
    http:
      paths:
      - path: /dashboard
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port:
              number: 443
EOF

# kubectl apply -f - <<EOF
# apiVersion: v1
# kind: Service
# metadata:
#   name: kube-dash
#   namespace: kube-system
# spec:
#   type: NodePort
#   ports:
#     - port: 443
#       targetPort: 8443
#       nodePort: 32222
#   selector:
#     app.kubernetes.io/name: kubernetes-dashboard
# EOF