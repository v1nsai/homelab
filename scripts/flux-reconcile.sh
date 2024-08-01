#!/bin/bash

set -e

flux reconcile source git homelab
flux reconcile kustomization add-projects-folder

APPNAME="$1"
if [ ! -z "$APPNAME" ]; then
  NAMESPACE="$2"
    if [ -z "$NAMESPACE" ]; then
        NAMESPACE=$APPNAME
    fi
  flux reconcile -n $NAMESPACE kustomization $APPNAME
  flux reconcile -n $NAMESPACE helmrelease $APPNAME
fi
