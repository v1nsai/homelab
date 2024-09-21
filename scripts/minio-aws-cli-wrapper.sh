#!/bin/bash

# sudo cp scripts/minio-aws-cli-wrapper.sh /usr/local/bin/minio-aws-cli
set -e

aws \
    --ca-bundle /Users/doctor_ew/code/homelab/apps/services/minio/secrets/ca.crt \
    --endpoint-url https://minio-api.internal/ \
    "$@"