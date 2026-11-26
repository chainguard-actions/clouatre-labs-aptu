<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Roll up anonymized review-context telemetry' step puts a GitHub expression straight into its run: string: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The expression is filled in by template substitution before the shell parses the line. Fix: use the shell-quoted env var instead, e.g. "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh".

Locations:

- `action.yml:635`

### github-env-injection (severity: high)

The 'Setup PATH' step writes an inherited process env var to $GITHUB_PATH without sanitizing it first: `echo "$HOME/.local/bin" >> "$GITHUB_PATH"`. The calling workflow can set HOME, so a composite action must treat it as workflow-controlled. Under rule (e), the value needs `printf '%s' ... | tr -d '\n\r'` before the write.

Locations:

- `action.yml:334`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml.

1. Script injection: the telemetry roll-up step now runs "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh" (quoted) instead of putting the github.action_path expression directly in the run: line. The arguments and the trailing '|| true' are unchanged.

2. GITHUB_PATH write: the Setup PATH step now removes newline and carriage-return characters from "$HOME/.local/bin" (piped through tr -d '\n\r') before appending it to $GITHUB_PATH.

Nothing has been run or re-analysed yet.

