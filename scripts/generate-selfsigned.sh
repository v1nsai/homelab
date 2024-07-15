#!/bin/bash

set -e

openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /tmp/$1-key.pem \
    -out /tmp/$1-cert.crt \
    -subj "/CN=$1"

kubectl create secret tls selfsigned-tls \
    --key /tmp/$1-key.pem \
    --cert /tmp/$1-cert.crt \
    --namespace $1

rm /tmp/$1-key.pem /tmp/$1-cert.crt