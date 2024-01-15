#!/bin/bash

set -e

kubectl get secret -n $1 $2 -o jsonpath='{.data'$3'}' | base64 --decode
echo ""
