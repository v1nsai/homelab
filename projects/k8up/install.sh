#!/bin/bash

set -e
source projects/k8up/.env
REGION=$(aws configure get region)

if [ -z "$BUCKET" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Please create an IAM user and set the BUCKET, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in projects/k8up/.env"
    exit 1
fi

echo "Creating AWS IAM user config..."
cat > projects/k8up/k8up-policy.json <<EOF
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

# aws iam create-user --user-name k8up
# aws iam put-user-policy \
#   --user-name k8up \
#   --policy-name k8up \
#   --policy-document file://projects/k8up/k8up-policy.json
# aws iam create-access-key --user-name k8up > ~/.aws/k8up-user.json
# AWS_SECRET_ACCESS_KEY=$(jq -r '.AccessKey.SecretAccessKey' ~/.aws/k8up-user.json)
# AWS_ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' ~/.aws/k8up-user.json)
# rm projects/k8up/k8up-policy.json

echo "Creating backup location secrets..."
kubectl create secret generic backend-s3-credentials \
    --namespace k8up \
    --from-literal=access-key=$AWS_ACCESS_KEY_ID \
    --from-literal=secret-key=$AWS_SECRET_ACCESS_KEY \
    --dry-run=client \
    --output yaml | kubeseal --cert ./.sealed-secrets.pub --format yaml > projects/k8up/app/sealed-secrets.yaml
