#!/bin/bash
# Publish rotary-dial to the nakomis CodeArtifact Cargo registry.
# Adapted from codeartifact/examples/codeartifact.sh.
#
# Usage:
#   ./scripts/publish-crate.sh           — publish to sandbox
#   ./scripts/publish-crate.sh prod      — publish to prod
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    AWS_PROFILE=nakom.is
    DOMAIN=nakomis
    DOMAIN_OWNER=637423226886
    REGION=eu-west-2
    INDEX="sparse+https://artifacts.nakomis.com/cargo/cargo/"
    ;;
  sandbox)
    AWS_PROFILE=nakom.is-sandbox
    DOMAIN=nakomis-sandbox
    DOMAIN_OWNER=975050268859
    REGION=eu-west-2
    INDEX="sparse+https://artifacts.sandbox.nakomis.com/cargo/cargo/"
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

echo "==> Authenticating to CodeArtifact (${ENV})..."
TOKEN=$(AWS_PROFILE="$AWS_PROFILE" aws codeartifact get-authorization-token \
  --domain "$DOMAIN" \
  --domain-owner "$DOMAIN_OWNER" \
  --region "$REGION" \
  --query authorizationToken \
  --output text)

export CARGO_REGISTRIES_NAKOMIS_CODEARTIFACT_INDEX="$INDEX"
export CARGO_REGISTRIES_NAKOMIS_CODEARTIFACT_TOKEN="Bearer ${TOKEN}"

echo "==> Publishing rotary-dial to nakomis_codeartifact (${ENV})..."
cargo publish -p rotary-dial --registry nakomis_codeartifact

echo "==> Done."
