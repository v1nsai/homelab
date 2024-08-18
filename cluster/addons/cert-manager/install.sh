#!/bin/bash

set -e

# generate local CA key
openssl genrsa -des3 -out tls.key 2048
openssl req -x509 -new -nodes -key tls.key -sha256 -days 1825 -out tls.crt

# Trust the CA
## macos
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" tls.crt 

## linux
sudo apt-get install -y ca-certificates
sudo cp tls.crt /usr/local/share/ca-certificates/tls.crt
sudo update-ca-certificates

# Create and seal kubernetes secret
kubectl create secret generic tls-ca --from-file=tls.crt --from-file=tls.key -n kube-system