#!/bin/bash

set -e

kubectl port-forward -n $1 --address 0.0.0.0 svc/$2 $3
