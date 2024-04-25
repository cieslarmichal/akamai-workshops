# akamai-workshops

## Setup

export TF_VAR_token=your-secret-linode-token-created-at-the-start-of-this-guide

export KUBECONFIG=$(pwd)/lke-cluster-config.yaml

## Deploy

kubectl apply -f app.yaml

kubectl apply -f daemon.yaml

## Check k8s resources

k9s
k9s -n kube-system

## Update with latest image

kubectl rollout restart deployment/workshops
