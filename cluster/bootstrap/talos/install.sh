# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper 

# Create secrets
talosctl gen secrets -o cluster/bootstrap/talos/secrets.yaml.env # adding .env to make git ignore it
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types talosconfig \
  --output talosconfig \
  talos-homelab https://192.168.1.133:6443
mv talosconfig ~/.talos/config # can't use ~/ in talosconfig path
kubeseal --cert ./.sealed-secrets.pub --format yaml 

# DO NOT RUN until at least one node has been booted using apply-config below
talosctl bootstrap \
  --nodes 192.168.1.196 \
  --endpoints 192.168.1.196
talosctl kubeconfig \
  --nodes 192.168.1.196 \
  --endpoints 192.168.1.196 

# bigrig
talosctl gen config \
  --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  --force \
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
  --force \
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
  --force \
  talos-homelab https://192.168.1.162:6443
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
  talos-homelab https://192.168.1.186:6443
talosctl apply-config \
  --nodes 192.168.1.186 \
  --file /tmp/ASUSan.yaml \
  --config-patch @cluster/bootstrap/talos/install-patches/ASUSan.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/longhorn/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/metrics-server/patch.yaml \
  --config-patch @cluster/bootstrap/talos/extensions/local-path-provisioner/patch.yaml

# vm VM
VM_IPS=( 192.168.121.56 192.168.121.196 )
for VM_IP in "${VM_IPS[@]}"; do
  talosctl gen config \
    --with-secrets cluster/bootstrap/talos/secrets.yaml.env \
    --output-types controlplane \
    --output /tmp/vm.yaml \
    --force \
    talos-homelab https://$VM_IP:6443
  talosctl apply-config \
    --insecure \
    --nodes $VM_IP \
    --file /tmp/vm.yaml \
    --config-patch @cluster/bootstrap/talos/install-patches/vm.yaml
done
