#!/bin/bash
# Shell functions for working with the nakomis CodeArtifact Cargo registry.
# Source this file in your project's scripts:
#
#   source /path/to/rotary-dial/examples/codeartifact.sh
#
# Available functions:
#   codeartifact_token [prod]       — echo a fresh bearer token (stdout)
#   cargo_authenticate [prod]       — export CARGO_REGISTRIES_NAKOMIS_CODEARTIFACT_TOKEN
#   cargo_publish <package> [prod]  — authenticate and publish a crate

_codeartifact_env() {
  local env="${1:-sandbox}"
  case "$env" in
    prod)
      echo "nakom.is nakomis"
      ;;
    sandbox)
      echo "nakom.is-sandbox nakomis-sandbox"
      ;;
    *)
      echo "Unknown environment: '$env'. Use 'sandbox' (default) or 'prod'." >&2
      return 1
      ;;
  esac
}

codeartifact_token() {
  local env="${1:-sandbox}"
  local profile domain
  read -r profile domain <<< "$(_codeartifact_env "$env")" || return 1

  AWS_PROFILE="$profile" aws codeartifact get-authorization-token \
    --domain "$domain" \
    --query authorizationToken \
    --output text
}

cargo_authenticate() {
  local env="${1:-sandbox}"
  local token
  token=$(codeartifact_token "$env") || return 1
  export CARGO_REGISTRIES_NAKOMIS_CODEARTIFACT_TOKEN="Bearer ${token}"
  echo "==> CARGO_REGISTRIES_NAKOMIS_CODEARTIFACT_TOKEN set (valid 12 hours)" >&2
}

cargo_publish() {
  local package="${1:?Usage: cargo_publish <package> [prod]}"
  local env="${2:-sandbox}"
  cargo_authenticate "$env" || return 1
  cargo publish -p "$package" --registry nakomis-codeartifact
}

# Allow direct execution as well as sourcing.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This file is intended to be sourced, not run directly." >&2
  echo "  source ${0}" >&2
  echo "  cargo_authenticate [prod]" >&2
  echo "  cargo_publish <package> [prod]" >&2
  exit 1
fi
