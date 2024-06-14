# Akamai Workshops - Linode Kubernetes

## Setup

reference: <https://blog.kr4ntz.com/linode/2023/03/24/Terraform-Linode-LKE.html>

export TF_VAR_token=your-secret-linode-token-created-at-the-start-of-this-guide

terraform apply

terraform output -raw kubeconfig | base64 -d > lke-cluster-config.yaml

export KUBECONFIG=$(pwd)/lke-cluster-config.yaml

## Deploy

kubectl apply -f app.yaml

kubectl apply -f daemon.yaml

## Check k8s resources

kubectl get pods
kubectl get pods -n kube-system
kubectl get pods -n longhorn-system

## Update with latest image

kubectl rollout restart deployment/workshops

## Install longhorn

curl -sSfL <https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/scripts/environment_check.sh> | bash

helm repo add longhorn <https://charts.longhorn.io>
helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.6.1

kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80

helm repo add ingress-nginx <https://kubernetes.github.io/ingress-nginx>
helm repo add jetstack <https://charts.jetstack.io>
help repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true

kubectl get pvc
kubectl get storageclass

## NFS

kubectl exec -it webben-8498d89886-s9t76 -- bash

df
