# sudo cp scripts/talosctlwrapper.sh /usr/local/bin/talosctlwrapper 

# Create and seal the secrets
talosctl gen secrets -o projects/talos/secrets.yaml.env
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml.env \
  --output-types talosconfig \
  --output ~/.talos/config \
  talos-homelab https://192.168.1.133:6443
talosctl --talosconfig=~/.talos/config config endpoint 192.168.1.170 192.168.1.162 192.168.1.155
kubectl create secret generic talos-secrets \
  --from-file=projects/talos/secrets.yaml.env \
  --dry-run=client \
  --output yaml > /tmp/talos-secrets.yaml.env
kubeseal --cert ./.sealed-secrets.pub --format yaml < /tmp/talos-secrets.yaml.env > projects/talos/sealed-secrets.yaml.env
talosctl kubeconfig \
  --nodes 192.168.1.133 \
  --endpoints 192.168.1.133 \
  --talosconfig ~/.talos/config > ~/.kube/config-talos

# bigrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/bigrig.yaml \
  talos-homelab https://192.168.1.170:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.170 \
  --file /tmp/bigrig.yaml \
  --config-patch @projects/talos/install-patches/bigrig.yaml
talosctl bootstrap \
  --nodes 192.168.1.170 \
  --endpoints 192.168.1.170

# tiffrig
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/tiffrig.yaml \
  talos-homelab https://192.168.1.155:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.155 \
  --file /tmp/tiffrig.yaml \
  --config-patch @projects/talos/install-patches/tiffrig.yaml 

# oppenheimer
talosctl gen config \
  --with-secrets projects/talos/secrets.yaml.env \
  --output-types controlplane \
  --output /tmp/oppenheimer.yaml \
  talos-homelab https://192.168.1.162:6443
talosctl apply-config \
  --insecure \
  --nodes 192.168.1.162 \
  --file /tmp/oppenheimer.yaml \
  --config-patch @projects/talos/install-patches/oppenheimer.yaml
