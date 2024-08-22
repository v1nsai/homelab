#!/bin/bash

source apps/data-science/kubeflow/.env
set -e

# TODO make a gitops way to do this with a k8s job or something
sudo snap install juju --channel=3.4/stable
sudo cat /etc/rancher/k3s/k3s.yaml | juju add-k8s k3s-homelab --client
juju bootstrap k3s-homelab uk8sx
juju add-model kubeflow
juju deploy kubeflow --trust --channel=1.9/stable
juju config dex-auth static-username=admin
juju config dex-auth static-password="$PASS"

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubeflow-ingress
  namespace: kubeflow
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/description: Machine Learning Ops Platform
    gethomepage.dev/group: Data Science
    gethomepage.dev/icon: https://www.kubeflow.org/docs/images/logos/kubeflow.png
    gethomepage.dev/name: Kubeflow
    cert-manager.io/cluster-issuer: homelab-issuer
spec:
  rules:
    - host: kubeflow.internal
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: istio-ingressgateway-workload
                port: 
                  number: 80
  tls:
    - hosts:
        - kubeflow.internal
      secretName: homelab-tls
EOF