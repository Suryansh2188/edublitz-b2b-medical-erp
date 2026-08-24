#!/bin/bash

set -e

echo "=========================================="
echo " Deploying Kubernetes Application"
echo "=========================================="

# Kubernetes manifest directory
K8S_DIR="./k8s"

# Check kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

# Check Kubernetes connection
echo ""
echo "[1/8] Checking Kubernetes cluster..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Cannot connect to Kubernetes cluster."
    echo "Check your kubeconfig / AWS EKS configuration."
    exit 1
fi

echo "Kubernetes cluster connection successful."

# --------------------------------------------------
# Namespace
# --------------------------------------------------
echo ""
echo "[2/8] Applying Namespace..."

kubectl apply -f "$K8S_DIR/namespace/namespace.yaml"

# --------------------------------------------------
# Secret
# --------------------------------------------------
echo ""
echo "[3/8] Applying Secret..."

kubectl apply -f "$K8S_DIR/secrets/app-secrets.yaml"

# --------------------------------------------------
# ConfigMap
# --------------------------------------------------
echo ""
echo "[4/8] Applying ConfigMap..."

kubectl apply -f "$K8S_DIR/configmaps/app-config.yaml"

# --------------------------------------------------
# Service
# --------------------------------------------------
echo ""
echo "[5/8] Applying Service..."

for file in "$K8S_DIR/services"/*.yaml; do
    [ -f "$file" ] || continue
    echo "Applying: $file"
    kubectl apply -f "$file"
done


# --------------------------------------------------
# Deployment
# --------------------------------------------------
echo ""
echo "[6/8] Applying Deployment..."

for file in "$K8S_DIR/deployments"/*.yaml; do
    [ -f "$file" ] || continue
    echo "Applying: $file"
    kubectl apply -f "$file"
done

# --------------------------------------------------
# HPA
# --------------------------------------------------
echo ""
echo "[7/8] Applying HPA..."

for file in "$K8S_DIR/hpa"/*.yaml; do
    [ -f "$file" ] || continue
    echo "Applying: $file"
    kubectl apply -f "$file"
done

# --------------------------------------------------
# Ingress
# --------------------------------------------------
echo ""
echo "[7/8] Applying ingress..."

kubectl apply -f "$K8S_DIR/ingress/ingress.yaml"

echo ""
echo "=========================================="
echo " Deployment completed successfully!"
echo "=========================================="

echo ""
echo "Namespaces:"
kubectl get namespaces

echo ""
echo "Pods:"
kubectl get pods -A 

echo ""
echo "Deployments:"
kubectl get deployments -A