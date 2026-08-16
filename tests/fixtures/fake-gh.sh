#!/bin/sh
# Fake gh CLI for testing aptu action.
# Handles the specific gh commands the action makes without real network calls.
case "$*" in
  *"repos/clouatre-labs/aptu/releases"*)
    # Return a fake version string (action strips leading 'v' with sed)
    echo "0.10.1"
    exit 0
    ;;
  *"release download"*)
    # Extract the -D destination directory from args
    DEST=""
    PREV=""
    for arg in "$@"; do
      if [ "$PREV" = "-D" ]; then
        DEST="$arg"
      fi
      PREV="$arg"
    done
    # Determine arch (matches action logic)
    case "$(uname -m)" in
      aarch64 | arm64) ARCH="aarch64" ;;
      *) ARCH="x86_64" ;;
    esac
    FAKE_VERSION="0.10.1"
    ARCHIVE="aptu-cli-${FAKE_VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
    if [ -n "$DEST" ]; then
      mkdir -p "$DEST"
      cp "/tmp/${ARCHIVE}" "$DEST/${ARCHIVE}"
      cp "/tmp/${ARCHIVE%.tar.gz}.sha256" "$DEST/${ARCHIVE%.tar.gz}.sha256"
    fi
    exit 0
    ;;
  *"attestation verify"*)
    echo "Attestation verification skipped (mock)"
    exit 0
    ;;
  *)
    # Fall through to real gh if available
    if [ -x "/usr/bin/gh" ]; then
      exec /usr/bin/gh "$@"
    fi
    if [ -x "/usr/local/bin/gh" ]; then
      exec /usr/local/bin/gh "$@"
    fi
    echo "gh: unhandled command: $*" >&2
    exit 1
    ;;
esac
