[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) ![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![dependabot auto-merging](https://github.com/v1nsai/homelab/actions/workflows/dependabot.yml/badge.svg)

# homelab
This is a mono repository for my homelab infrastructure.  I keep it production-ready within reason for a one-man hobby operation.

## Network Diagram
This diagram was generated using the `mingrammer diagrams` lib for Python from the code in the Jupyter Notebook at `projects/diagrams/homelab.ipynb`

![homelab](https://github.com/v1nsai/homelab/blob/develop/projects/diagrams/homelab.png)

## Cluster Hardware
* The configuration I use to deploy Talos Kubernetes Linux onto my home lab is in `projects/talos/`
* My cluster contains 3 control plane nodes a total of 28 CPUs, 64 GB of RAM, and 4GB of VRAM
* Talos Linux Kubernetes cluster with 3 nodes called bigrig, tiffrig and oppenheimer
* bigrig is my old gaming machine and the only machine with an Nvidia GPU
* tiffrig is nearly identical to my bigrig. I built to be my wife's gaming machine originally, but is using an older Nvidia card that is no longer supported by CUDA
* oppenheimer is an Intel NUC (I'm choosing to pronounce it "nuke").  They're great cheap low power servers with upgradeable RAM and SSD.  I plan to buy more NUCs and finish the Manhattan Project team.

## Cluster bootstrapping
* The `projects/talos/install.sh` contains commented code blocks to generate secrets and config, apply patches (see `projects/talos/install-patches`) and deploy nodes
* Talos system extension images are generated using https://factory.talos.dev and installed using the upgrade commands in `projects/talos/extensions/extensions.sh`
* Once system images have been installed, the `install.sh` script in each subfolder contains additional patches and upgrade commands specific to each extension.

## GitOps with FluxCD
* You can enable and disable apps by ignoring their project folders the `.sourceignore` file
* Create a `projects/fluxcd/fluxcd.env` file and define `GITHUB_REPO`, `GITHUB_USER` and `GITHUB_TOKEN`
* Run the `projects/fluxcd/install.sh`
* This will also install Sealed Secrets and Weave Flux UI
* Use the scripts `scripts/generate-selfsigned.sh` will generate a new selfsigned cert and key, create a kubernetes secret and encrypt it with sealed secrets.  You can remove the last line of the script if you want to store the certs somewhere before removing.
* If there is an `install.sh` file in the root of the project folder, run it.  It will generate necessary secrets before deployment
* Check the status of apps or the `watch-projects` kustomization in the Weave UI or with `flux get -n flux-system kustomization watch-projects` or `flux get -n <namespace> helmrelease <appname>`

## Cluster Addons
* Storage
    * Longhorn in `projects/longhorn`
    * Rook Ceph Operator in `projects/rook-ceph`
    * NFS in `projects/nfs`
    * External Snapshotter `projects/external-snapshotter`
* Ingress
    * Traefik in `projects/traefik`
* GPU
    * Nvidia K8s Device Plugin in `projects/nvidia-device-plugin`
    * Nvidia GPU Operator in `projects/nvidia-gpu-operator`