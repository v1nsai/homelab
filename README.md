# homelab
Configs for my containerized homelab.  Hope these can help someone and please feel free to add suggestions or improvements.

## Usage
For the most part you should be able to run the `projects/{project-name}/install.sh` script.  These scripts assume a Linux (Ubuntu) environment and that `microceph`, `microk8s`, `docker`, and `docker compose` are all installed.  On Ubuntu you can install these with:

```
sudo apt update && sudo apt install -y docker docker-compose-v2
sudo snap install microk8s --classic
sudo snap install microceph
```

## Network Diagram
This diagram was generated using the `mingrammer diagrams` lib for Python. Major work in progress, I'm still learning how the placement algorithm works so I don't end up having to hardcode all the positions and other hacky nonsense.

![homelab](https://github.com/v1nsai/homelab/blob/develop/projects/diagrams/homelab.png)
