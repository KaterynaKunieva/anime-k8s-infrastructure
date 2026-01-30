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
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-123456789}"

MONGO_USER="${MONGO_USER:-root}"
MONGO_PASSWORD="${MONGO_PASSWORD:-$(openssl rand -base64 16)}"

MAIL_USER="${MAIL_USERNAME:-user}"
MAIL_PASSWORD="${MAIL_PASSWORDWORD:-$(openssl rand -base64 16)}"

ADMIN_EMAIL="${ADMIN_EMAIL:admin@animedomain.com}"

RABBIT_USER="${RABBIT_USER:-rabbit}"
RABBIT_PASSWORD="${RABBIT_PASSWORD:-$(openssl rand -base64 16)}"

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

# Rabbit MQ Secret
echo "Creating rabbitmq-secret..."
kubectl create secret generic rabbitmq-secret \
  --from-literal=username="$RABBITMQ_USER" \
  --from-literal=password="$RABBITMQ_PASSWORD" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Mail Secret
echo "Creating mail-secret..."
kubectl create secret generic mail-secret \
  --from-literal=username="$MAIL_USER" \
  --from-literal=password="$MAIL_PASSWORD" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Admin email
kubectl create secret generic mail-secret \
  --from-literal=admin-email="$ADMIN_EMAIL" \
  -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -