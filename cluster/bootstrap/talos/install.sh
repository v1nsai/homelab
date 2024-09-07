# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper 

# Create secrets
VIP_ADDRESS="192.168.1.133"
talosctl gen secrets -o cluster/bootstrap/talos/secrets.yaml.env # adding .env to make git ignore it
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types talosconfig \
  --output talosconfig \
  talos-homelab https://$VIP_ADDRESS:6443
mv talosconfig ~/.talos/config # can't use ~/ in talosconfig path
kubeseal --cert ./.sealed-secrets.pub --format yaml 

# DO NOT RUN until at least one node has been booted using apply-config below
NODE="192.168.1.155"
talosctl bootstrap \
  --nodes $NODE \
  --endpoints $NODE
talosctl kubeconfig \
  --nodes $NODE \
  --endpoints $NODE 

# bigrig
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  --force \
  talos-homelab https://$VIP_ADDRESS:6443
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
  --force \
  talos-homelab https://$VIP_ADDRESS:6443
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
  --force \
  talos-homelab https://$VIP_ADDRESS:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.162 \
  --file /tmp/oppenheimer.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/oppenheimer.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml

# ASUSan
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/ASUSan.yaml \
  --force \
  talos-homelab https://$VIP_ADDRESS:6443
talosctl apply-config \
  --nodes 192.168.1.186 \
  --file /tmp/ASUSan.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/ASUSan.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml

talosctl patch machineconfig \
  --nodes 192.168.1.155,192.168.1.162 \
  --endpoints 192.168.1.133 \
  --patch-file cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --patch-file cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --patch-file cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml
