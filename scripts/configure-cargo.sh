#!/bin/bash
# Configure local Cargo to authenticate against the nakomis CodeArtifact registry.
# Run this once per session (tokens expire after 12 hours).
# Usage:
#   ./scripts/configure-cargo.sh           — configures for sandbox
#   ./scripts/configure-cargo.sh prod      — configures for prod
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    export AWS_PROFILE=nakom.is
    DOMAIN=nakomis
    ENDPOINT="https://artifacts.nakomis.com/cargo/"
    ;;
  sandbox)
    export AWS_PROFILE=nakom.is-sandbox
    DOMAIN=nakomis-sandbox
    ENDPOINT="https://artifacts.sandbox.nakomis.com/cargo/"
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

REGISTRY=nakomis-codeartifact

echo "==> Getting CodeArtifact auth token for ${ENV} (profile: ${AWS_PROFILE})..."
TOKEN=$(aws codeartifact get-authorization-token \
  --domain "$DOMAIN" \
  --query authorizationToken \
  --output text)

CARGO_CONFIG="${HOME}/.cargo/config.toml"
CARGO_CREDS="${HOME}/.cargo/credentials"

echo "==> Writing registry index to ${CARGO_CONFIG}..."
# Remove any existing nakomis-codeartifact registry block then append the new one.
python3 - "$CARGO_CONFIG" "$REGISTRY" "$ENDPOINT" <<'PYEOF'
import sys, re, os

config_path, registry, endpoint = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(os.path.dirname(config_path), exist_ok=True)

content = open(config_path).read() if os.path.exists(config_path) else ""
# Remove existing block for this registry
content = re.sub(
    rf'\[registries\.{re.escape(registry)}\][^\[]*',
    '',
    content,
    flags=re.DOTALL,
).rstrip()

block = f'\n\n[registries.{registry}]\nindex = "sparse+{endpoint}"\n'
open(config_path, 'w').write(content + block)
PYEOF

echo "==> Writing auth token to ${CARGO_CREDS}..."
python3 - "$CARGO_CREDS" "$REGISTRY" "$TOKEN" <<'PYEOF'
import sys, re, os

creds_path, registry, token = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(os.path.dirname(creds_path), exist_ok=True)

content = open(creds_path).read() if os.path.exists(creds_path) else ""
content = re.sub(
    rf'\[registries\.{re.escape(registry)}\][^\[]*',
    '',
    content,
    flags=re.DOTALL,
).rstrip()

block = f'\n\n[registries.{registry}]\ntoken = "Bearer {token}"\n'
open(creds_path, 'w').write(content + block)
PYEOF

echo "==> Done. Cargo is configured to use ${REGISTRY} → ${ENDPOINT}"
echo "    Token valid for 12 hours."
