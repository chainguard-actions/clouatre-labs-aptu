#!/bin/sh
# Mock gh CLI for aptu action tests.
# Handles the specific gh calls made by the action without network access.

APTU_VERSION="0.99.0"
ARCH="x86_64"
ARCHIVE="aptu-cli-${APTU_VERSION}-${ARCH}-unknown-linux-musl.tar.gz"

# Use $1 $2 to match subcommands reliably
CMD1="${1:-}"
CMD2="${2:-}"

if [ "$CMD1" = "api" ]; then
  # Match: gh api repos/clouatre-labs/aptu/releases --jq '...'
  # The action uses --jq to extract the tag_name; gh api --jq outputs raw strings
  printf 'v%s\n' "$APTU_VERSION"
  exit 0
fi

if [ "$CMD1" = "release" ] && [ "$CMD2" = "download" ]; then
  # Parse -D destination directory from remaining args
  DEST_DIR="."
  prev=""
  for arg in "$@"; do
    case "$prev" in
      -D) DEST_DIR="$arg" ;;
    esac
    prev="$arg"
  done
  mkdir -p "$DEST_DIR"
  cp "/tmp/aptu-mock/${ARCHIVE}" "$DEST_DIR/${ARCHIVE}"
  cp "/tmp/aptu-mock/${ARCHIVE%.tar.gz}.sha256" "$DEST_DIR/${ARCHIVE%.tar.gz}.sha256"
  exit 0
fi

if [ "$CMD1" = "attestation" ] && [ "$CMD2" = "verify" ]; then
  echo "Attestation verification succeeded (mock)"
  exit 0
fi

# Fall through to real gh if available
if [ -x /usr/bin/gh ]; then
  exec /usr/bin/gh "$@"
fi

echo "mock gh: $*" >&2
exit 0
