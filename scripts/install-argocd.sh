#!/bin/bash
set -e

echo "=== Installing Argo CD ==="

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD pods to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get Argo CD admin password
echo "=== Argo CD Admin Password ==="
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Get Argo CD server (NodePort)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="server")].nodePort}')
echo "=== Argo CD Server ==="
echo "Access Argo CD at: http://YOUR_MASTER_IP:$ARGOCD_PORT"
echo "Username: admin"
echo "Password: (see above)"
