<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.11.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.11.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Roll up anonymized review-context telemetry' step's `run:` value directly interpolates `${{ github.action_path }}` inside the shell command string. Any `${{ ... }}` expression interpolated directly into a `run:` block is a script-injection risk because the expression is substituted by the Actions template engine before the shell ever sees the string, bypassing shell quoting. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The fix is to use the `$GITHUB_ACTION_PATH` environment variable instead: `run: "$GITHUB_ACTION_PATH/scripts/telemetry-rollup.sh ..."`.

Locations:

- `action.yml:530`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Replaced `${{ github.action_path }}` with `$GITHUB_ACTION_PATH` in the 'Roll up anonymized review-context telemetry' step's `run:` field (action.yml line 530). The `$GITHUB_ACTION_PATH` environment variable is always available in GitHub Actions runners and avoids the template-engine substitution that makes `${{ ... }}` expressions in `run:` blocks a script-injection risk.

