<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.12.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.12.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A `${{ ... }}` expression is interpolated directly inside a `run:` shell command string. In the "Roll up anonymized review-context telemetry" step, the `run:` value is: `"${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. The `${{ github.action_path }}` expression is expanded by the GitHub Actions template engine before the shell ever sees the string, making it a script-injection vector. Even though `github.action_path` is not directly attacker-controlled, the check requires that no `${{ ... }}` expression appear anywhere inside a `run:` shell command string. The fix is to pass the path via an `env:` variable (e.g. `ACTION_PATH: ${{ github.action_path }}`) and reference it as `"$ACTION_PATH"/scripts/telemetry-rollup.sh` in the run block.

Locations:

- `action.yml:430`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection finding in action.yml at the 'Roll up anonymized review-context telemetry' step. Moved `${{ github.action_path }}` from the `run:` shell command string into the `env:` block as `ACTION_PATH: ${{ github.action_path }}`, and updated the run command to reference `$ACTION_PATH/scripts/telemetry-rollup.sh` instead. All other env variables in the step were already properly defined in the env: block.

