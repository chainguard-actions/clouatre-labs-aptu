<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.14.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.14.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run script: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. Fix: use the `$GITHUB_ACTION_PATH` environment variable instead, double-quoted.

Locations:

- `action.yml:491`

### github-env-injection (severity: high)

The 'Setup PATH' step runs `echo "$HOME/.local/bin" >> "$GITHUB_PATH"`. `$HOME` is an inherited process environment variable that the calling workflow can override, and this run block does not set it. The value is written to GITHUB_PATH without first sanitizing it with `printf '%s' ... | tr -d '\n\r'`. The zizmor ignore comment suppresses the warning but does not fix the problem.

Locations:

- `action.yml:245`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

script-injection: the telemetry rollup step no longer puts ${{ github.action_path }} in its run script. It now calls "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh" in double quotes and keeps the same arguments and the '|| true'. github-env-injection: the Setup PATH step now strips newlines and carriage returns from $HOME/.local/bin before writing it to $GITHUB_PATH. I also removed the zizmor ignore comment. Nothing was run or tested.

