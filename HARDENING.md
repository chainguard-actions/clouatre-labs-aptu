<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.11.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.11.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a), direct expression interpolation: the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run: string: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". The expression is substituted into the script text before the shell parses it. Fix: use the runner-provided env var and quote it: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh" (or pass action_path through an env: entry).

Locations:

- `action.yml:580`

### github-env-injection (severity: high)

The 'Setup PATH' step writes an inherited process env var to $GITHUB_PATH with no sanitization: echo "$HOME/.local/bin" >> "$GITHUB_PATH". HOME is not set inside this run: script. In a composite action the calling workflow can override it, so under check rule (e) it counts as workflow-controlled. A value containing a newline could add extra PATH entries. Fix: sanitize before writing, e.g. safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:309`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Telemetry rollup step: swapped the inline github.action_path expression for a quoted "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh". Setup PATH step: newlines and carriage returns are now stripped from $HOME/.local/bin before it is written to $GITHUB_PATH.

