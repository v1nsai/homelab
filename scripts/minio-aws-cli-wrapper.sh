#!/bin/bash

# sudo cp scripts/minio-aws-cli-wrapper.sh /usr/local/bin/minio-aws-cli
set -e

export AWS_CA_BUNDLE="/Users/doctor_ew/code/homelab/cluster/addons/minio/secrets/ca.crt"
aws --endpoint-url https://minio-api.internal/ "$@"