#!/bin/bash
# Publish rotary-dial to the nakomis CodeArtifact Cargo registry.
#
# Usage:
#   ./scripts/publish-crate.sh           — publish to sandbox
#   ./scripts/publish-crate.sh prod      — publish to prod
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    DOMAIN=nakomis
    DOMAIN_OWNER=637423226886
    INDEX="sparse+https://artifacts.nakomis.com/cargo/cargo/"
    ;;
  sandbox)
    DOMAIN=nakomis-sandbox
    DOMAIN_OWNER=975050268859
    INDEX="sparse+https://artifacts.sandbox.nakomis.com/cargo/cargo/"
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

CRED="cargo:token-from-stdout aws codeartifact get-authorization-token --domain ${DOMAIN} --domain-owner ${DOMAIN_OWNER} --region eu-west-2 --query authorizationToken --output text"

echo "==> Publishing rotary-dial to nakomis_codeartifact (${ENV})..."
cargo publish -p rotary-dial --registry nakomis_codeartifact \
  --config "registries.nakomis_codeartifact.index='${INDEX}'" \
  --config "registries.nakomis_codeartifact.credential-provider='${CRED}'"
echo "==> Done."
