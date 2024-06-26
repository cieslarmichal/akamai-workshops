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

## Prometheus Operator

helm repo add prometheus-community <https://prometheus-community.github.io/helm-charts>
helm repo update

helm upgrade --install prometheus -f prometheus-values.yaml prometheus-community/kube-prometheus-stack

kubectl --namespace default get pods -l "release=prometheus"

kubectl port-forward svc/prometheus-grafana 3000:80

default username: admin
default password: prom-operator

<https://github.com/prometheus-community/helm-charts/?tab=readme-ov-file>

## Loki

<https://grafana.com/docs/loki/latest/setup/install/helm/>

helm repo add grafana <https://grafana.github.io/helm-charts>
helm repo update

helm upgrade --install --create-namespace --namespace logging -f ./loki-values.yaml loki grafana/loki

helm upgrade --install --wait --create-namespace --namespace logging logging-operator oci://ghcr.io/kube-logging/helm-charts/logging-operator

```bash
kubectl -n logging apply -f - <<"EOF"
apiVersion: logging.banzaicloud.io/v1beta1
kind: Logging
metadata:
  name: default-logging-simple
spec:
  fluentd: {}
  fluentbit: {}
  controlNamespace: logging
EOF
```

```bash
kubectl -n logging apply -f - <<"EOF"
apiVersion: logging.banzaicloud.io/v1beta1
kind: Output
metadata:
 name: loki-output
spec:
 loki:
   url: http://loki:3100
   configure_kubernetes_labels: true
   buffer:
     timekey: 1m
     timekey_wait: 30s
     timekey_use_utc: true
EOF
```

```bash
kubectl -n logging apply -f - <<"EOF"
apiVersion: logging.banzaicloud.io/v1beta1
kind: Flow
metadata:
  name: loki-flow
spec:
  filters:
    - tag_normaliser: {}
    - parser:
        remove_key_name_field: true
        reserve_data: true
        parse:
          type: nginx
  match:
    - select:
        labels:
          app.kubernetes.io/name: log-generator
  localOutputRefs:
    - loki-output
EOF
```

helm upgrade --install --wait --create-namespace --namespace logging log-generator oci://ghcr.io/kube-logging/helm-charts/log-generator

In Grafana UI, add Loki datasource with URL: <http://loki.logging:3100>
