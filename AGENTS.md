This repo contains fluxcd resources for deploying kubernetes workloads over gitops. 

./cluster/bootstrap contains the scripts used to bootstrap the initial Talos Kubernetes cluster and fluxcd
./cluster/addons contain the fluxcd kustomizations used to deploy apps that extend the cluster, such as storage, load balancing, ingress, GPU, backups and other capabilities

./apps contains configurations for deployed resources

./diagrams contains the python diagrams library code to generate the diagrams in the README

./scripts contains all the helper scripts to do this or that

Keep in mind that many apps that are configured here may not be deployed, check the .sourceignore file for removed deployments.