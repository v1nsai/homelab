#!/bin/bash

set -e
source cluster/addons/velero/.env
REGION=$(aws configure get region)

if [ -z "$BUCKET" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Please create an IAM user and set the BUCKET, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in cluster/addons/velero/.env"
    exit 1
fi

echo "Configuring AWS IAM user policy..."
cat > /tmp/velero-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}"
            ]
        }
    ]
}
EOF

# aws iam create-user --user-name velero
# aws iam put-user-policy \
#   --user-name velero \
#   --policy-name velero \
#   --policy-document file:///tmp/velero-policy.json
# aws iam create-access-key --user-name velero > ~/.aws/velero-user.json
# AWS_SECRET_ACCESS_KEY=$(jq -r '.AccessKey.SecretAccessKey' ~/.aws/velero-user.json)
# AWS_ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' ~/.aws/velero-user.json)

# echo "Installing velero CLI..."
# wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.2/velero-v1.13.2-linux-amd64.tar.gz
# tar -xvf velero-v1.13.2-linux-amd64.tar.gz
# sudo mv velero-v1.13.2-linux-amd64/velero /usr/local/bin/
# rm -rf velero-v1.13.2-linux-amd64*
# echo 'source <(velero completion bash)' >>~/.bashrc

echo "Creating backup location secrets..."
source cluster/addons/velero/.env
cat > cluster/addons/velero/s3-credentials.env <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF
BACKUPLOCATION_SECRET_NAME="backuplocation-credentials"
BACKUPLOCATION_SECRET_KEY="cloud"
kubectl create secret generic $BACKUPLOCATION_SECRET_NAME \
    --namespace velero \
    --from-file $BACKUPLOCATION_SECRET_KEY=cluster/addons/velero/s3-credentials.env \
    --dry-run=client \
    --output yaml | \
kubeseal --cert ./.sealed-secrets.pub --format yaml > cluster/addons/velero/app/sealed-secrets.yaml

# Install before restoring a cluster without fluxcd
# helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
# helm repo update
# cat cluster/addons/velero/app/helmrelease.yaml | yq '.spec.values' > /tmp/values.yaml
# helm install velero vmware-tanzu/velero \
#     --namespace velero \
#     --values /tmp/values.yaml
