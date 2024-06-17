#!/bin/bash

set -e
source projects/velero/.env

if [ -z "$BUCKET" ]; then
    echo "Please set BUCKET in projects/velero/.env"
    exit 1
fi

# echo "Installing velero CLI..."
# wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.2/velero-v1.13.2-linux-amd64.tar.gz
# tar -xvf velero-v1.13.2-linux-amd64.tar.gz
# sudo mv velero-v1.13.2-linux-amd64/velero /usr/local/bin/
# rm -rf velero-v1.13.2-linux-amd64*
# echo 'source <(velero completion bash)' >>~/.bashrc

echo "Configuring AWS IAM user..."
cat > projects/velero/velero-policy.json <<EOF
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
cat > projects/velero/velero.env <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF
aws iam create-user --user-name velero
aws iam put-user-policy \
  --user-name velero \
  --policy-name velero \
  --policy-document file://projects/velero/velero-policy.json
aws iam create-access-key --user-name velero > ~/.aws/velero-user.json
AWS_SECRET_ACCESS_KEY=$(jq -r '.AccessKey.SecretAccessKey' ~/.aws/velero-user.json)
AWS_ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' ~/.aws/velero-user.json)
REGION=$(aws configure get region)

echo "Installing velero..."
velero install \
    # --use-restic \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.9.2 \
    --bucket $BUCKET \
    --backup-location-config region=$REGION \
    --snapshot-location-config region=$REGION \
    --secret-file projects/velero/velero.env

echo "Setting up volume backup exclusions..."
kubectl -n jellyfin annotate pod/plex-plex-media-server-0 backup.velero.io/backup-volumes-excludes=the-goods

echo "Scheduling backups..."
velero schedule create nightly --schedule="0 3 * * *" --ttl 168h0m0s

echo "Adding backup rules..."
kubectl apply -f projects/velero/change-storageclass.yaml

# restore a namespace from backup
# NAMESPACE="nextcloud"
# RESTORE_DATE=$(date -d "1 days ago" +%Y%m%d)
# BACKUP_NAME=$(aws s3 ls s3://$BUCKET/backups/ | grep $RESTORE_DATE | awk '{print $2}' | tr -d "/")
# velero restore create --from-backup $BACKUP_NAME --include-namespaces $NAMESPACE

# velero backup create torrents-$(date +%Y%m%d) --include-namespaces plex --include-resources persistentvolumeclaims
# velero restore create torrents-plex --from-backup torrents-$(date +%Y%m%d) --namespace  #--namespace-mappings plex:jellyfin

velero backup create nextcloud-test --include-namespaces nextcloud