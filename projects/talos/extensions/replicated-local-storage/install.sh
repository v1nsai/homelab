# install iscsi-tools extension
# NOTE have to use --preserve whenever running upgrade to prevent data loss

# bigrig 
talosctl upgrade \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170 \
  --preserve \
  --image factory.talos.dev/installer/aefe418d4647eb3ecb93d2c5d583c663aa54c790165493b0414bf01442d93897:v1.7.5 # nvidia + iscsi-tools

# tiffrig
talosctl upgrade \
  --nodes 192.168.1.155 \
  --endpoints 192.168.1.155 \
  --preserve \
  --image factory.talos.dev/installer/c9078f9419961640c712a8bf2bb9174933dfcf1da383fd8ea2b7dc21493f8bac:v1.7.5

# oppenheimer
talosctl upgrade \
    --nodes 192.168.1.162 \
    --endpoints 192.168.1.162 \
    --preserve \
    --image factory.talos.dev/installer/c9078f9419961640c712a8bf2bb9174933dfcf1da383fd8ea2b7dc21493f8bac:v1.7.5

# patch nodes
talosctl patch machineconfig \
    --endpoints 192.168.1.133 \
    --nodes 192.168.1.162,192.168.1.155,192.168.1.170 \
    --patch-file projects/talos/extensions/hostpath/patch.yaml

# install openebs-jiva
kubectl create ns openebs
kubectl label ns openebs \
    pod-security.kubernetes.io/audit=privileged \
    pod-security.kubernetes.io/enforce=privileged \
    pod-security.kubernetes.io/warn=privileged
helm repo add openebs-jiva https://openebs-archive.github.io/jiva-operator
helm repo update
helm upgrade --install openebs-jiva openebs-jiva/jiva \
    --namespace openebs

# configure openebs-jiva
kubectl --namespace openebs apply --filename projects/talos/extensions/hostpath/config.yaml
kubectl --namespace openebs patch daemonset openebs-jiva-csi-node --type=json --patch '[{"op": "add", "path": "/spec/template/spec/hostPID", "value": true}]'