#!/bin/bash
# Publish rotary-dial to the nakomis CodeArtifact Cargo registry.
#
# Usage:
#   ./scripts/publish-crate.sh           — publish to sandbox
#   ./scripts/publish-crate.sh prod      — publish to prod
#
# Authentication is handled automatically by the credential-provider in
# .cargo/config.toml, which calls `aws codeartifact get-authorization-token`.
# Make sure your AWS credentials are valid before running.
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    INDEX="sparse+https://artifacts.nakomis.com/cargo/cargo/"
    CRED_PROVIDER="cargo:token-from-stdout aws codeartifact get-authorization-token --domain nakomis --domain-owner 637423226886 --region eu-west-2 --query authorizationToken --output text"
    ;;
  sandbox)
    # config.toml already points at sandbox; no override needed.
    INDEX=""
    CRED_PROVIDER=""
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

CARGO_ARGS=(publish -p rotary-dial --registry nakomis_codeartifact)

if [[ -n "$INDEX" ]]; then
  CARGO_ARGS+=(--config "registries.nakomis_codeartifact.index='${INDEX}'")
  CARGO_ARGS+=(--config "registries.nakomis_codeartifact.credential-provider='${CRED_PROVIDER}'")
fi

echo "==> Publishing rotary-dial to nakomis_codeartifact (${ENV})..."
cargo "${CARGO_ARGS[@]}"
echo "==> Done."
