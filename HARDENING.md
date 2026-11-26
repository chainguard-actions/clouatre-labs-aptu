<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) broken: the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run: string. Offending line: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". The expression is filled in by template substitution before the shell parses the line. Fix: map github.action_path to an env var (e.g. ACTION_PATH: ${{ github.action_path }}) and call "$ACTION_PATH/scripts/telemetry-rollup.sh" with the variable in double quotes.

Locations:

- `action.yml:576`

### github-env-injection (severity: high)

The 'Setup PATH' step writes the inherited process env var $HOME to $GITHUB_PATH without sanitizing it first: echo "$HOME/.local/bin" >> "$GITHUB_PATH". HOME is not set inside this run: script, and the calling workflow's env can override it in a composite action. Under rule (e) it counts as workflow-controlled. This is a strict-reading finding: the runner sets HOME, and a newline in it is unlikely in practice. Fix: safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:304`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Telemetry rollup step: moved github.action_path into env ACTION_PATH and invoke "$ACTION_PATH/scripts/telemetry-rollup.sh" quoted. Setup PATH step: strip CR/LF from "$HOME/.local/bin" before appending to $GITHUB_PATH.

