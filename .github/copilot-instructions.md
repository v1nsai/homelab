# Copilot Instructions

## Repository Purpose
- This repo houses the FluxCD GitOps definitions for a Talos Linux Kubernetes homelab. Keep manifests production-ready for a single-operator environment and prefer pragmatic reliability over experimentation.

## Core Layout
- `cluster/bootstrap/talos/`: Talos configuration, secrets generation snippets, and system extension workflows. Reference `install.sh` plus `install-patches/` when touching bootstrap flows.
- `cluster/bootstrap/fluxcd/`: Flux bootstrap scripts; requires a local `fluxcd.env` with `GITHUB_REPO`, `GITHUB_USER`, and `GITHUB_TOKEN` before automation can run.
- `cluster/addons/`: Storage (Longhorn, Rook Ceph, NFS, External Snapshotter), ingress (Traefik), and GPU (Nvidia device plugin/operator) stacks. Respect folder-specific overlays and values.
- `apps/`: Application Helm/Kustomize projects. Enable/disable deployment by editing `.sourceignore` entries; never delete folders just to turn apps off.
- `scripts/`: Utility scripts (self-signed certs, Flux reconciliation helpers, Talos wrappers). Prefer reusing these instead of reimplementing logic inside manifests.

## Deployment Expectations
- Talos cluster spans three named nodes (`bigrig`, `tiffrig`, `oppenheimer`) with GPU availability only on `bigrig`. GPU-specific workloads must tolerate scheduling limits.
- System extensions are built via `factory.talos.dev` and applied through `cluster/bootstrap/talos/extensions/extensions.sh`. When adding new extensions, follow the existing comment-guarded blocks and document required upgrade commands.
- Flux bootstrap installs Sealed Secrets and the Weave Flux UI. When secret material is required, add or update an `install.sh` inside the relevant app folder so operators can regenerate the values before deployment.
- Use `scripts/generate-selfsigned.sh` to refresh TLS assets; the script already seals secrets, so only adjust if persistence of raw certs is required.

## Operational Guidance
- To verify app rollouts, prefer `flux get -n flux-system kustomization watch-projects` or `flux get -n <namespace> helmrelease <app>`; keep docs consistent with these commands.
- Network diagrams live in `diagrams/homelab.ipynb`; regenerate diagrams through that notebook when topology changes instead of embedding manual graphics.
- Assume Longhorn, Rook, and Traefik are baseline capabilities; new workloads should integrate with these providers unless explicitly justified otherwise.
