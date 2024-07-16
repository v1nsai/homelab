#!/bin/bash

set -e

flux reconcile source git homelab
flux reconcile kustomization add-projects-folder
