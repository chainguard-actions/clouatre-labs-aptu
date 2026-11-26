<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation in the 'Roll up anonymized review-context telemetry' step: a GitHub Actions expression is placed straight into the run: shell string: run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true". Fix: move github.action_path into an env: variable (e.g. ACTION_PATH), or use the GITHUB_ACTION_PATH env var the runner already sets, and quote it: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh".

Locations:

- `action.yml:620`

### github-env-injection (severity: high)

The 'Setup PATH' step writes a value built from an inherited process env var to $GITHUB_PATH with no sanitization: echo "$HOME/.local/bin" >> "$GITHUB_PATH". In a composite action the calling workflow can override HOME, and this run: block does not compute it, so under this check it counts as workflow-controlled. Fix: sanitize it first, e.g. safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:327`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml. Nothing was run to test them.

- **script-injection:** The telemetry rollup step no longer puts the `github.action_path` expression into its `run:` line. It now calls the script through the quoted runner variable instead: `"$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh"`. The arguments and the trailing `|| true` are unchanged.
- **github-env-injection:** The Setup PATH step now strips newline and carriage-return characters from `$HOME/.local/bin` before writing it to `$GITHUB_PATH`.

