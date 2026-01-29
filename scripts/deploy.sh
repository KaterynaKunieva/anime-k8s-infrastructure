#!/bin/bash

# Script to deploy the entire application to Kubernetes
#
# Usage:
#   ./deploy.sh              # Deploy with current versions
#   ./deploy.sh --dry-run    # Show what will be applied (without changes)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KUSTOMIZE_DIR="$PROJECT_ROOT/kustomize"
NAMESPACE="anime-project"

echo "=== Deploying Anime Application ==="
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl not found. Please install kubectl."
    exit 1
fi

# Check connection to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: No connection to Kubernetes cluster."
    echo "Execute: gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE"
    exit 1
fi

# Dry run mode
if [ "$1" == "--dry-run" ]; then
    echo "=== DRY RUN MODE ==="
    echo "The following resources will be created/updated:"
    echo ""
    kubectl kustomize "$KUSTOMIZE_DIR"
    exit 0
fi

# Check for secrets (if they don't exist)
echo "Checking secrets..."
if ! kubectl get secret postgresql-secret -n "$NAMESPACE" &> /dev/null; then
    echo "Secrets not found. Creating..."
    "$SCRIPT_DIR/create-secrets.sh"
fi

# Apply Kustomize configuration
echo ""
echo "Applying Kustomize configuration..."
kubectl apply -k "$KUSTOMIZE_DIR"

echo ""
echo "=== Deployment Completed ==="
echo ""
echo "Check status:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get services -n $NAMESPACE"
echo ""
echo "Logs:"
echo "  kubectl logs -f deployment/anime-api -n $NAMESPACE"
echo "  kubectl logs -f deployment/episode-api -n $NAMESPACE"
echo "  kubectl logs -f deployment/email-service -n $NAMESPACE"