<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.14.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.14.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): a GitHub Actions expression is placed directly inside a run: script in the 'Roll up anonymized review-context telemetry' step: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". Fix: pass github.action_path through an env: variable (e.g. ACTION_PATH) and call "$ACTION_PATH/scripts/telemetry-rollup.sh" with the variable double-quoted.

Locations:

- `action.yml:530`

### github-env-injection (severity: high)

The 'Setup PATH' step runs echo "$HOME/.local/bin" >> "$GITHUB_PATH". It writes the inherited process env var $HOME to GITHUB_PATH without the required sanitization. In a composite action, the calling workflow controls the env and can override HOME. Fix: safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:282`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Moved github.action_path to env ACTION_PATH and invoked "$ACTION_PATH/scripts/telemetry-rollup.sh" (bash shell). Setup PATH now strips CR/LF from "$HOME/.local/bin" before writing to GITHUB_PATH.

