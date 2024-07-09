#!/bin/bash

kubectl -n flux-system port-forward svc/capacitor 9000:9000 > /dev/null 2>&1 &