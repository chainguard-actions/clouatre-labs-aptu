<!-- markdownlint-disable -->

# Hardening Report: clouatre-labs--aptu/v0.10.21

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **clouatre-labs--aptu/v0.10.21** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a) violation: The step 'Roll up anonymized review-context telemetry' interpolates `${{ github.action_path }}` directly inside the `run:` shell command string. Any `${{ ... }}` expression directly inside a `run:` block is a script-injection risk because the value is substituted into the shell command before the shell parses it. The offending line is: `run: "${{ github.action_path }}/scripts/telemetry-rollup.sh \"$APTU_CONTEXT_FILE\" \"$TELEMETRY_ROLLUP_PATH\" || true"`. This should be replaced by setting `ACTION_PATH: ${{ github.action_path }}` in the step's `env:` block and then referencing `"$ACTION_PATH"` in the run script.

Locations:

- `action.yml:534`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in the 'Roll up anonymized review-context telemetry' step of action.yml. Moved `${{ github.action_path }}` from the `run:` shell command string into the step's `env:` block as `ACTION_PATH: ${{ github.action_path }}`, then updated the run command to reference `$ACTION_PATH` instead. This prevents the expression from being substituted directly into the shell command before parsing.

