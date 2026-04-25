#!/bin/bash
# Obtain a CodeArtifact auth token and write it to ~/.cargo/credentials.
# The registry index URL lives in each project's .cargo/config.toml — this
# script only handles the credential (tokens expire after 12 hours).
# Usage:
#   ./scripts/configure-cargo.sh           — authenticate against sandbox
#   ./scripts/configure-cargo.sh prod      — authenticate against prod
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    export AWS_PROFILE=nakom.is
    DOMAIN=nakomis
    ;;
  sandbox)
    export AWS_PROFILE=nakom.is-sandbox
    DOMAIN=nakomis-sandbox
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

REGISTRY=nakomis-codeartifact
CARGO_CREDS="${HOME}/.cargo/credentials"

echo "==> Getting CodeArtifact auth token for ${ENV} (profile: ${AWS_PROFILE})..."
TOKEN=$(aws codeartifact get-authorization-token \
  --domain "$DOMAIN" \
  --query authorizationToken \
  --output text)

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

echo "==> Done. Token for ${REGISTRY} (${ENV}) written. Valid for 12 hours."
