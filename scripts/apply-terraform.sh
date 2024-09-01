#!/bin/bash

# Set error handling and logging
set -e
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
rm -rf terraform.log

# Apply terraform
terraform -chdir=$1 init -upgrade
terraform -chdir=$1 apply -auto-approve
