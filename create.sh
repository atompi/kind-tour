#!/bin/bash

WORKDIR=$(pwd)

# create cluster
kind create cluster --config=config.yaml
kubectl label nodes kind-worker node_role=sys-node

sleep 30

# load images
kind load docker-image registry.k8s.io/ingress-nginx/opentelemetry-1.25.3:v20240813-b933310d
kind load docker-image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4
kind load docker-image registry.k8s.io/ingress-nginx/controller:v1.11.3
kind load docker-image registry.k8s.io/defaultbackend-amd64:1.5

kind load docker-image grafana/grafana-image-renderer:latest
kind load docker-image quay.io/kiwigrid/k8s-sidecar:1.28.0
kind load docker-image grafana/grafana:11.3.0
kind load docker-image quay.io/prometheus-operator/admission-webhook:v0.77.2
kind load docker-image quay.io/prometheus-operator/prometheus-config-reloader:v0.77.2
kind load docker-image quay.io/prometheus-operator/prometheus-operator:v0.77.2
kind load docker-image quay.io/prometheus/alertmanager:v0.27.0
kind load docker-image quay.io/prometheus/prometheus:v2.55.0
kind load docker-image quay.io/thanos/thanos:v0.36.1
kind load docker-image quay.io/prometheus/node-exporter:v1.8.2
kind load docker-image registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.13.0
kind load docker-image quay.io/brancz/kube-rbac-proxy:v0.18.0
kind load docker-image curlimages/curl:7.85.0
kind load docker-image bats/bats:v1.4.1
kind load docker-image busybox:1.31.1

kind load docker-image kubernetesui/dashboard-auth:1.2.2
kind load docker-image kubernetesui/dashboard-api:1.10.1
kind load docker-image kubernetesui/dashboard-web:1.6.0
kind load docker-image kubernetesui/dashboard-metrics-scraper:1.2.1

kind load docker-image registry.k8s.io/metrics-server/metrics-server:v0.7.2

kind load docker-image kong:3.6

kind load docker-image atompi/go-httpbin:v2.15.0
kind load docker-image nginx:1.26.2
kind load docker-image atompi/hugo:0.117.0
kind load docker-image atompi/varnish:7.3.0
kind load docker-image tarampampam/webhook-tester:1.1.0

# install metrics-server
kubectl apply -f manifests/metrics-server/high-availability.yaml

# install ingress-nginx
kubectl create ns ingress-nginx
cd $WORKDIR/charts/ingress-nginx/certs
kubectl create secret tls -n ingress-nginx atompi.cc-ingress-secret --cert=./atompi.cc.pem --key=./atompi.cc-key.pem --dry-run=client -o yaml > ./atompi.cc-ingress-secret.ingress-nginx.yaml
kubectl apply -f ./atompi.cc-ingress-secret.ingress-nginx.yaml
cd $WORKDIR/charts/ingress-nginx
rm -rf ingress-nginx
tar -xf ingress-nginx-4.11.3.tgz
helm -n ingress-nginx install ingress-nginx -f ./values.yaml ./ingress-nginx

sleep 120

# install monitoring
kubectl create ns monitoring
cd $WORKDIR/charts/kube-prometheus-stack
rm -rf kube-prometheus-stack
tar -xf kube-prometheus-stack-65.8.1.tgz
helm install -n monitoring kube-prometheus-stack -f ./values.yaml ./kube-prometheus-stack

# install kubernetes-dashboard
kubectl create ns kubernetes-dashboard
cd $WORKDIR/charts/kubernetes-dashboard
rm -rf kubernetes-dashboard
tar -xf kubernetes-dashboard-7.10.0.tgz
rm -f kubernetes-dashboard/templates/networking/ingress.yaml
cp ingress.yaml kubernetes-dashboard/templates/networking/ingress.yaml
helm -n kubernetes-dashboard install kubernetes-dashboard -f ./values.yaml ./kubernetes-dashboard

# install apps
cd $WORKDIR/manifests/apps
kubectl apply -f ./hugo/hugo.yaml
kubectl apply -f ./httpbin/httpbin.yaml
kubectl apply -f ./varnish/configmap.yaml
kubectl apply -f ./varnish/varnish.yaml
kubectl apply -f ./webhook-tester/webhook-tester.yaml
kubectl apply -f ./gateway/configmap-nginx-conf-core-d.yaml
kubectl apply -f ./gateway/configmap-nginx-conf-conf-d.yaml
kubectl apply -f ./gateway/configmap-nginx-conf.yaml
kubectl apply -f ./gateway/gateway.yaml
