<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.20

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.20** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Roll up anonymized review-context telemetry' step puts a GitHub Actions expression straight into its run: string: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. Expressions are substituted into the script text before the shell parses it. Fix: pass the path through env (e.g. ACTION_PATH: ${{ github.action_path }}) and call "$ACTION_PATH/scripts/telemetry-rollup.sh", or use the runner's $GITHUB_ACTION_PATH variable, quoted.

Locations:

- `action.yml:814`

### github-env-injection (severity: high)

The 'Setup PATH' step (id: setup-path) runs `echo "$HOME/.local/bin" >> "$GITHUB_PATH"`. HOME is an inherited process env var that this run: script does not set, and a composite action gets its env from the calling workflow, so this check treats it as workflow-controlled. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write (the zizmor ignore comment does not count as sanitization). Fix: safe=$(printf '%s' "$HOME/.local/bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH".

Locations:

- `action.yml:433`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml.

1. script-injection (telemetry rollup step): the `${{ github.action_path }}` expression no longer sits in the run: string. It is now passed through env as ACTION_PATH, and the step calls `"$ACTION_PATH/scripts/telemetry-rollup.sh"` in quotes. The other arguments and the `|| true` are as upstream had them.

2. github-env-injection (Setup PATH step): `$HOME/.local/bin` now goes through `printf '%s' ... | tr -d '\n\r'` before it is written to $GITHUB_PATH.

