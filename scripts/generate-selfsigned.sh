#!/bin/bash

set -e

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $1-key.pem -out $1-cert.crt -subj "/CN=$1/O=myorganization"
# kubectl create secret tls selfsigned-tls --key bigrig.local-key.pem --cert bigrig.local-cert.crt