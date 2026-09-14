#!/bin/sh
# Fake gh wrapper: intercepts aptu-specific calls, passes everything else to real gh.
# Used in act-based tests to mock the aptu binary installation without requiring
# gh attestation verify (which may not be available in the act environment).

case "$*" in
  *"repos/clouatre-labs/aptu/releases"*)
    # Return the version tag (already jq-processed output — the action pipes through sed)
    printf 'v0.10.20\n'
    exit 0
    ;;
  *"release download"*"clouatre-labs/aptu"*)
    # Parse -D flag for destination directory
    DEST=""
    prev=""
    for arg in "$@"; do
      case "$prev" in
        -D) DEST="$arg" ;;
      esac
      prev="$arg"
    done
    if [ -n "$DEST" ]; then
      ARCH=$(uname -m)
      case "$ARCH" in
        aarch64|arm64) ARCH="aarch64" ;;
        *) ARCH="x86_64" ;;
      esac
      ARCHIVE="aptu-cli-0.10.20-${ARCH}-unknown-linux-musl.tar.gz"
      # Create a minimal fake aptu binary
      printf '#!/bin/sh\necho "aptu 0.10.20 (fake)"\n' > "$DEST/aptu"
      chmod +x "$DEST/aptu"
      # Create a real tar.gz archive containing the fake binary
      tar -czf "$DEST/$ARCHIVE" -C "$DEST" aptu
      # Create the SHA256 checksum file (sha256sum -c expects this format)
      (cd "$DEST" && sha256sum "$ARCHIVE" > "${ARCHIVE%.tar.gz}.sha256")
    fi
    exit 0
    ;;
  *"attestation verify"*)
    echo "Verified attestation (mocked)"
    exit 0
    ;;
esac

# Pass through to real gh for all other commands.
# Try common locations; fall back to PATH search excluding our fake-bin dir.
for candidate in /usr/bin/gh /usr/local/bin/gh; do
  if [ -x "$candidate" ] && [ "$candidate" != "$0" ]; then
    exec "$candidate" "$@"
  fi
done
# Last resort: search PATH excluding the directory containing this script
SCRIPT_DIR=$(dirname "$0")
REAL_GH=$(PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -v "^${SCRIPT_DIR}$" | tr '\n' ':') command -v gh 2>/dev/null || true)
if [ -n "$REAL_GH" ]; then
  exec "$REAL_GH" "$@"
fi
echo "fake-gh: no real gh found for: $*" >&2
exit 1
