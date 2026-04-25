#!/bin/bash
# Publish the rotary-dial crate to the nakomis CodeArtifact Cargo registry.
# Usage:
#   ./scripts/publish-crate.sh           — publishes to sandbox
#   ./scripts/publish-crate.sh prod      — publishes to prod
set -e

ENV="${1:-sandbox}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Configuring Cargo for ${ENV}..."
"${SCRIPT_DIR}/configure-cargo.sh" "$ENV"

echo "==> Publishing rotary-dial to nakomis-codeartifact (${ENV})..."
cd "$SCRIPT_DIR/.."
cargo publish -p rotary-dial --registry nakomis-codeartifact

echo "==> Published successfully."
