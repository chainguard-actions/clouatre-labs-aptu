<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run: script: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. Template substitution happens before the shell parses the line, so the value is not shell-quoted. Fix: run the script via "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh", or pass github.action_path through an env: variable and expand it in double quotes.

Locations:

- `action.yml:618`

### github-env-injection (severity: high)

The 'Setup PATH' step runs `echo "$HOME/.local/bin" >> "$GITHUB_PATH"`. HOME is a process env var that the composite action inherits. The script reads it but never sets it, so the calling workflow can control it. It is written to $GITHUB_PATH without the `printf '%s' ... | tr -d '\n\r'` sanitization step. Fix: safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:327`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml. I haven't run the action or its tests after the changes.

- **script-injection (telemetry rollup step):** the step now runs "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh", quoted, instead of putting the github.action_path expression straight into run:. The arguments and the trailing `|| true` are the same as before.
- **github-env-injection (Setup PATH step):** the value is now passed through `printf '%s' "$HOME/.local/bin" | tr -d '\n\r'` before it is written to $GITHUB_PATH. The existing zizmor ignore comment on that step is unchanged.

