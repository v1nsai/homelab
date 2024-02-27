#!/bin/bash

set -e

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=*"

kubectl create secret tls tls-selfsigned \
    --namespace $1 \
    --key /tmp/tls.key \
    --cert /tmp/tls.crt

rm /tmp/tls.key /tmp/tls.crt
