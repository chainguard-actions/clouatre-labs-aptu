<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.20

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.20** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a) violation: The 'Roll up anonymized review-context telemetry' step interpolates `${{ github.action_path }}` directly inside the `run:` shell command string. Any `${{ ... }}` expression inside a `run:` block is a script-injection risk because YAML template substitution occurs before the shell ever sees the value. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The fix is to move `github.action_path` into an `env:` variable (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference it as `"$ACTION_PATH/scripts/telemetry-rollup.sh ..."` in the `run:` block.

Locations:

- `action.yml:370`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection vulnerability in the 'Roll up anonymized review-context telemetry' step of hardened/action/action.yml. Moved `${{ github.action_path }}` from the `run:` shell command string into the step's `env:` block as `ACTION_PATH: ${{ github.action_path }}`, and updated the `run:` command to reference it as the plain environment variable `$ACTION_PATH`.

