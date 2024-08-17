#!/bin/bash

# necessary due to https://github.com/NVIDIA/k8s-device-plugin/issues/315
kubectl label node bigrig nvidia.com/gpu.present=true