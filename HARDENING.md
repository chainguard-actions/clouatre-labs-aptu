<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.21

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.21** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a), direct expression interpolation: the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run: script: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". Fix: pass the path through an env: variable (e.g. ACTION_PATH: ${{ github.action_path }}) or use the $GITHUB_ACTION_PATH env var, and quote it: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh" ...

Locations:

- `action.yml:724`

### github-env-injection (severity: high)

Case (e): the 'Setup PATH' step writes a value built from the inherited process env var $HOME to $GITHUB_PATH without sanitizing it first: echo "$HOME/.local/bin" >> "$GITHUB_PATH". This is a composite action, so the calling workflow controls HOME. Fix: clean the value just before the write, e.g. safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:403`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

In action.yml, the telemetry rollup step no longer puts the ${{ github.action_path }} expression into its run: script. It now runs the script through the quoted runner variable "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh", with the same arguments and the same '|| true' as before. The Setup PATH step now strips newlines from $HOME/.local/bin before writing it to $GITHUB_PATH. Nothing was run to test either change.

