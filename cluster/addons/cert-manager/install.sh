#!/bin/bash

set -e

# generate local CA key
openssl genrsa -des3 -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1825 -out ca.crt

# Trust the CA
## macos
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ca.crt 

## linux
sudo apt-get install -y ca-certificates
sudo cp ca.crt /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates

# Create and seal kubernetes secret
kubectl create secret generic tls-ca --from-file=ca.crt --from-file=ca.key -n kube-system