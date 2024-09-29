#!/bin/bash

# bitnami secrets
# cat <<EOF > /tmp/secret-values.yaml
# jenkinsUser: doctor_ew
# jenkinsPassword: $(openssl rand -base64 20)
# EOF

# kubectl create secret generic jenkins-secret \
#     --namespace jenkins \
#     --from-file=/tmp/secret-values.yaml \
#     --dry-run=client \
#     --output yaml | \
# kubeseal --cert ./.sealed-secrets.pub --format yaml > ./apps/services/jenkins/app/sealed-secrets.yaml

# official helm chart secrets
cat <<EOF > /tmp/secret-values.yaml
controller:
    admin:
        username: doctor_ew
        password: $(openssl rand -base64 20)
EOF
kubectl create secret generic secret-values \
    --namespace jenkins \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./apps/services/jenkins/app/sealed-secrets.yaml