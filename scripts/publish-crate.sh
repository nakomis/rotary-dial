#!/bin/bash
# Publish rotary-dial to the nakomis CodeArtifact Cargo registry.
#
# Usage:
#   ./scripts/publish-crate.sh           — publish to sandbox
#   ./scripts/publish-crate.sh prod      — publish to prod
#
# Authentication is handled by cargo:token-from-stdout in .cargo/config.toml.
# The script sets AWS_PROFILE so no manual profile selection is needed.
set -e

ENV="${1:-sandbox}"

case "$ENV" in
  prod)
    export AWS_PROFILE=nakom.is
    CARGO_ARGS=(publish -p rotary-dial --registry nakomis_codeartifact
      --config "registries.nakomis_codeartifact.index='sparse+https://artifacts.nakomis.com/cargo/cargo/'"
      --config "registries.nakomis_codeartifact.credential-provider='cargo:token-from-stdout aws codeartifact get-authorization-token --domain nakomis --domain-owner 637423226886 --region eu-west-2 --query authorizationToken --output text'"
    )
    ;;
  sandbox)
    export AWS_PROFILE=nakom.is-sandbox
    CARGO_ARGS=(publish -p rotary-dial --registry nakomis_codeartifact)
    ;;
  *)
    echo "Unknown environment: '$ENV'. Use 'sandbox' (default) or 'prod'." >&2
    exit 1
    ;;
esac

echo "==> Publishing rotary-dial to nakomis_codeartifact (${ENV})..."
cargo "${CARGO_ARGS[@]}"
echo "==> Done."
