#!/bin/bash
set -e

echo "=== Installing NGINX Ingress Controller ==="

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Get LoadBalancer IP (or NodePort)
echo "=== NGINX Ingress Controller installed ==="
kubectl get svc -n ingress-nginx ingress-nginx-controller
