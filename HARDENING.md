<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is interpolated directly inside a `run:` shell command string in the "Roll up anonymized review-context telemetry" step. The offending line is:

  run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"

The `${{ github.action_path }}` expression is substituted by the Actions template engine before the shell executes the command. Although `github.action_path` is not directly attacker-controlled, any `${{ ... }}` expression directly inside a `run:` block is a script-injection finding per the check rules. The fix is to move the path into an `env:` variable (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference it as `"$ACTION_PATH"` in the run script.

Locations:

- `action.yml:530`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in action.yml line 530 ("Roll up anonymized review-context telemetry" step): moved `${{ github.action_path }}` from the `run:` shell command string into the step's `env:` block as `ACTION_PATH: ${{ github.action_path }}`, and updated the run command to reference it as `$ACTION_PATH`.

