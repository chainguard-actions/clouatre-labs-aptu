<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.14.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.14.3** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violated: a GitHub Actions expression is placed directly inside a run: shell command in the 'Roll up anonymized review-context telemetry' step. Offending line: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". Fix: pass github.action_path through an env: variable (e.g. ACTION_PATH) and call "$ACTION_PATH/scripts/telemetry-rollup.sh" with double quotes, or use the existing $GITHUB_ACTION_PATH env var.

Locations:

- `action.yml:526`

### github-env-injection (severity: high)

The 'Setup PATH' step writes a value built from the inherited process env var $HOME to $GITHUB_PATH without sanitizing it first: echo "$HOME/.local/bin" >> "$GITHUB_PATH". This is a composite action, so HOME comes from the calling workflow's environment (a workflow can override it) and the script does not set it itself. Fix: sanitize before writing, e.g. safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:299`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Moved github.action_path into env ACTION_PATH for telemetry rollup step and invoked via quoted "$ACTION_PATH/scripts/telemetry-rollup.sh". Sanitized $HOME/.local/bin with tr -d '\n\r' before writing to GITHUB_PATH.

