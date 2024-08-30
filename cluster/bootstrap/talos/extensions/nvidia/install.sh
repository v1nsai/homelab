# allow running privileged containers in nvidia namespace
kubectl apply -f cluster/bootstrap/talos/extensions/nvidia/runtimeclass.yaml
kubectl create ns nvidia-device-plugin
kubectl label --overwrite namespace nvidia-device-plugin \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/enforce-version=latest \
    pod-security.kubernetes.io/warn=privileged \
    pod-security.kubernetes.io/warn-version=latest \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/audit-version=latest

# label GPU nodes
kubectl label nodes bigrig nvidia.com/gpu.present=true

# Install nvidia runtimeclass
kubectl apply -f cluster/bootstrap/talos/extensions/nvidia/runtimeclass.yaml

# Install nvidia device plugin
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade --install nvidia-device-plugin nvdp/nvidia-device-plugin \
    --create-namespace \
    --namespace nvidia-device-plugin \
    --set=runtimeClassName=nvidia

# Set nvidia default container runtime
talosctl patch machineconfig \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --patch-file cluster/bootstrap/talos/extensions/nvidia/set-default-runtime.yaml
