#!/bin/sh
# Fake gh wrapper: intercepts clouatre-labs/aptu API and release calls.
# Falls through to the real gh for everything else.
# REAL_GH_PATH is substituted at install time.

REAL_GH="${REAL_GH_PATH:-/usr/bin/gh}"

# List releases for clouatre-labs/aptu (handles --jq flag by outputting raw tag name)
case "$*" in
  *"repos/clouatre-labs/aptu/releases"*)
    # The action uses: gh api repos/clouatre-labs/aptu/releases --jq '...' | sed 's/^v//'
    # gh api --jq outputs raw strings (no quotes). We output the tag name directly.
    printf 'v0.10.3\n'
    exit 0
    ;;
esac

# Release download
if [ "$1" = "release" ] && [ "$2" = "download" ]; then
  dest=""
  prev=""
  for a in "$@"; do
    [ "$prev" = "-D" ] && dest="$a"
    prev="$a"
  done
  if [ -n "$dest" ]; then
    mkdir -p "$dest"
    archive=""
    sha256=""
    prev=""
    for a in "$@"; do
      if [ "$prev" = "--pattern" ]; then
        case "$a" in
          *.sha256) sha256="$a" ;;
          *.tar.gz) archive="$a" ;;
        esac
      fi
      prev="$a"
    done
    if [ -n "$archive" ]; then
      cp /tmp/fake-aptu-release/fake.tar.gz "$dest/$archive"
      if [ -n "$sha256" ]; then
        (cd "$dest" && sha256sum "$archive" > "$sha256")
      fi
    fi
  fi
  exit 0
fi

# Attestation verify — always succeed
if [ "$1" = "attestation" ] && [ "$2" = "verify" ]; then
  echo "Attestation verified (fake)"
  exit 0
fi

# Fall through to real gh
exec "$REAL_GH" "$@"
