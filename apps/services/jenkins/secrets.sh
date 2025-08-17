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

# Harbor secret
source apps/services/jenkins/.env
cat <<EOF > /tmp/harbor-secret.json
{
    "auths": {
        "harbor.internal": {
        "username": "robot\$jenkins",
        "password": "${HARBOR_PASSWORD}"
        }
    }
}
EOF
kubectl create secret generic harbor-docker-config \
    --namespace jenkins \
    --from-file=config.json=/tmp/harbor-secret.json \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml | tee -a ./apps/services/jenkins/app/sealed-secrets.yaml

# kubectl -n jenkins delete secret harbor-docker-config || true
# kubectl -n jenkins create secret generic harbor-docker-config \
#   --from-file=config.json=/tmp/dockercfg/config.json