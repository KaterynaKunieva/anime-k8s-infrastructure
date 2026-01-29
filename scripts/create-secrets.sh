#!/bin/bash

# Script for creating Kubernetes Secrets
# Run ONCE before the first deployment
#
# Usage:
#   ./create-secrets.sh
#
# Or with custom passwords:
#   POSTGRES_PASSWORD=mypass MONGO_PASSWORD=mypass ./create-secrets.sh

set -e

echo "=== Creating Kubernetes Secrets ==="

NAMESPACE="anime-project"

# Default values
POSTGRES_USER="${POSTGRES_USER:-user}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(openssl rand -base64 16)}"
MONGO_USER="${MONGO_USER:-root}"
MONGO_PASSWORD="${MONGO_PASSWORD:-$(openssl rand -base64 16)}"

# PostgreSQL Secret
echo "Creating postgresql-secret in namespace $NAMESPACE..."
kubectl create secret generic postgresql-secret \
  --from-literal=username="$POSTGRES_USER" \
  --from-literal=password="$POSTGRES_PASSWORD" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# MongoDB Secret
echo "Creating mongodb-secret in namespace $NAMESPACE..."
kubectl create secret generic mongodb-secret \
  --from-literal=username="$MONGO_USER" \
  --from-literal=password="$MONGO_PASSWORD" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
