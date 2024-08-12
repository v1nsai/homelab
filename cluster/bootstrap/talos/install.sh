# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper 

# Create and seal the secrets
talosctl gen secrets -o cluster/bootstrap/talos/secrets.yaml.env
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types talosconfig \
  --output talosconfig \
  talos-homelab https://192.168.1.133:6443
mv talosconfig ~/.talos/config # can't use ~/ in talosconfig path
# talosctl config endpoint 192.168.1.133 \
#   --talosconfig talosconfig
kubectl create secret generic talos-secrets \
  --from-file=cluster/bootstrap/talos/secrets.yaml.env \
  --dry-run=client \
  --output yaml > /tmp/talos-secrets.yaml.env
kubeseal --cert ./.sealed-secrets.pub --format yaml < /tmp/talos-secrets.yaml.env > cluster/bootstrap/talos/sealed-secrets.yaml.env

# DO NOT RUN until at least one node has been booted using apply-config below
talosctl bootstrap \
  --nodes 192.168.1.162 \
  --endpoints 192.168.1.162
talosctl kubeconfig \
  --nodes 192.168.1.162 \
  --endpoints 192.168.1.162 

# bigrig
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  talos-homelab https://192.168.1.170:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.170 \
  --file /tmp/bigrig.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/bigrig.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/nvidia/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml

# tiffrig
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/tiffrig.yaml \
  talos-homelab https://192.168.1.155:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.155 \
  --file /tmp/tiffrig.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/tiffrig.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml

# oppenheimer
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/oppenheimer.yaml \
  talos-homelab https://192.168.1.162:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.162 \
  --file /tmp/oppenheimer.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/oppenheimer.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml
