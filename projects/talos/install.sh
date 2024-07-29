# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper 

# Create and seal the secrets
talosctl gen secrets -o projects/talos/secrets.yaml
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types talosctl \
  --output ~/.talos/config \
  talos-homelab https://192.168.1.133:6443
talosctl --talosconfig=~/.talos/config config endpoint 192.168.1.170 192.168.1.162 192.168.1.155
kubectl create secret generic talos-secrets \
  --from-file=projects/talos/secrets.yaml \
  --dry-run=client \
  --output yaml > /tmp/talos-secrets.yaml
kubeseal --cert ./.sealed-secrets.pub --format yaml < /tmp/talos-secrets.yaml > projects/talos/sealed-secrets.yaml

# bigrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  talos-homelab https://192.168.1.170:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.170 \
  --file /tmp/bigrig.yaml \
  --config-patch @projects/talos/install-patches/bigrig-patch.yaml
talosctl bootstrap \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170

# tiffrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/tiffrig.yaml \
  talos-homelab https://192.168.1.155:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.155 \
  --file /tmp/tiffrig.yaml \
  --config-patch @projects/talos/install-patches/tiffrig-patch.yaml

# oppenheimer
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml \
  --output-types controlplane \
  --output /tmp/oppenheimer.yaml \
  talos-homelab https://192.168.1.162:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.162 \
  --file /tmp/oppenheimer.yaml \
  --config-patch @projects/talos/install-patches/oppenheimer-patch.yaml
