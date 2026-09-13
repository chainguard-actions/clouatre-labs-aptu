<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.19

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.19** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Roll up anonymized review-context telemetry' step directly interpolates `${{ github.action_path }}` inside a `run:` shell command string. Per the check rules, ANY `${{ ... }}` expression directly inside a `run:` block is a script-injection finding, because the value flows through YAML template substitution before the shell ever sees it. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The fix is to expose `github.action_path` via an `env:` variable (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference it as `"$ACTION_PATH"/scripts/telemetry-rollup.sh` in the run block.

Locations:

- `action.yml:563`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the 'Roll up anonymized review-context telemetry' step in action.yml (line 563): moved `${{ github.action_path }}` out of the `run:` block into the step's `env:` block as `ACTION_PATH: ${{ github.action_path }}`, and updated the shell command to reference `$ACTION_PATH/scripts/telemetry-rollup.sh` instead.

