#!/bin/bash

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--url)
      URL="$2"
      shift
      shift
      ;;
    -n|--namespace)
      NAMESPACE="$2"
      shift
      shift
      ;;
    -p|--projectname)
      PROJECTNAME="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Ensure required arguments are set
if [ -z "$PROJECTNAME" ]; then
  PROJECTNAME="$NAMESPACE"
fi
if [ -z "$NAMESPACE" ]; then
  NAMESPACE="$PROJECTNAME"
fi
if [ -z "$URL" ]; then
  echo "URL is required, defaulting to '*'"
  URL="*"
fi
if [ -z "$PROJECTNAME" ] && [ -z "$NAMESPACE" ]; then
  echo "Project name or namespace is required"
  exit 1
fi

# Generate self-signed cert
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=$URL"

# Create k8s secret yaml and seal it
kubectl create secret tls selfsigned-tls \
    --key=/tmp/tls.key \
    --cert=/tmp/tls.crt \
    --namespace $NAMESPACE \
    --dry-run=client \
    --output yaml | \
kubeseal --format=yaml --cert=./.sealed-secrets.pub > projects/$PROJECTNAME/app/selfsigned-tls-sealed.yaml

# Cleanup
rm /tmp/tls.key /tmp/tls.crt 