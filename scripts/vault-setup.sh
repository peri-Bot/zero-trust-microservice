#!/usr/bin/env bash
set -euo pipefail

KUBECTL="kubectl"

echo "Waiting for Vault pod to be ready..."
$KUBECTL wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=120s

echo "Enabling Kubernetes auth method..."
$KUBECTL exec vault-0 -- vault auth enable kubernetes 2>/dev/null || echo "  (already enabled)"

echo "📝 Writing Kubernetes auth config..."
$KUBECTL exec vault-0 -- sh -c '
  vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
'

echo "Creating secret at secret/data/database..."
$KUBECTL exec vault-0 -- vault kv put secret/database \
  username="zero-trust-user" \
  password="s3cur3-v4ult-p@ss" \
  host="postgres.default.svc.cluster.local" \
  port="5432" \
  dbname="microservice_db"

echo "Creating backend-policy..."
$KUBECTL exec vault-0 -- sh -c 'echo '"'"'path "secret/data/database" { capabilities = ["read"] }'"'"' | vault policy write backend-policy -'

echo "Creating Kubernetes auth role bound to backend-sa..."
$KUBECTL exec vault-0 -- vault write auth/kubernetes/role/backend \
  bound_service_account_names=backend-sa \
  bound_service_account_namespaces=default \
  policies=backend-policy \
  ttl=24h

echo "Vault setup complete!"
