# nvidia
talosctl upgrade \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --image factory.talos.dev/installer/aefe418d4647eb3ecb93d2c5d583c663aa54c790165493b0414bf01442d93897:v1.7.5
  # --image ghcr.io/siderolabs/installer:v1.7.5
  # --reboot-mode powercycle
  # --stage
talosctl patch machineconfig \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --patch-file projects/talos/extensions/nvidia/gpu-worker-patch.yaml

## allow running privileged containers in nvidia namespace
kubectl apply -f projects/talos/nvidia/runtimeclass.yaml
kubectl create ns nvidia-device-plugin
kubectl label --overwrite namespace nvidia-device-plugin \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/enforce-version=latest \
    pod-security.kubernetes.io/warn=privileged \
    pod-security.kubernetes.io/warn-version=latest \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/audit-version=latest

## label GPU nodes
kubectl label nodes bigrig nvidia.com/gpu.present=true

helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade --install nvidia-device-plugin nvdp/nvidia-device-plugin \
    --create-namespace \
    --namespace nvidia-device-plugin \
    --set=runtimeClassName=nvidia
