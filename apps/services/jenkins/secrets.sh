#!/bin/bash

cat <<EOF > /tmp/secret-values.yaml
jenkinsUser: doctor_ew
jenkinsPassword: $(openssl rand -base64 20)
EOF

kubectl create secret generic jenkins-secret \
    --from-file=/tmp/secret-values.yaml \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > ./projects/jenkins/app/sealed-secrets.yaml