#!/bin/bash

set -e

mc alias set myminio http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
mc admin user add myminio $PULSE_USER $PULSE_PASS
mc admin policy create myminio pulse-bucket-policy bucket_policy.json
